{ config
, lib
, utils
, ...
}:

let
  cfgZfs = config.boot.zfs;
  unlockPools = lib.filterAttrs (_: pool: pool.luksUnlock != null) cfgZfs.pools;

  luksUnlockModule =
    { config, ... }:
    {
      options = {
        zvol = lib.mkOption {
          type = lib.types.str;
          example = "keys";
          description = "Name of the zvol within the pool holding the LUKS container.";
        };

        luksDevice = lib.mkOption {
          type = lib.types.str;
          example = "tank-keys";
          description = "Name of the boot.initrd.luks.devices entry for the LUKS container.";
        };

        fsType = lib.mkOption {
          type = lib.types.str;
          example = "ext4";
          description = "Type of the filesystem inside the LUKS container.";
        };

        mountPoint = lib.mkOption {
          type = lib.types.str;
          default = "/media/${config.luksDevice}";
          defaultText = lib.literalExpression ''"/media/''${luksDevice}"'';
          description = "Where to mount the key filesystem; must match the datasets' keylocation.";
        };
      };
    };

  # In stage 1, for each pool:
  #
  #   zfs-preimport-<pool>    imports the pool without mounting or loading keys
  #     -> /dev/zvol/<pool>/<zvol> appears
  #   systemd-cryptsetup@<luksDevice>   from crypttab (boot.initrd.luks.devices)
  #   <mountPoint>.mount      mounts the key filesystem read-only
  #   zfs-import-<pool>       (nixpkgs) finds the pool already imported and
  #                           loads keys from their file:// keylocations
  #
  # The key filesystem is unmounted before switching to stage 2.
  # In stage 1, for each pool:
  #
  #   zfs-preimport-<pool>    imports the pool without mounting or loading keys
  #     -> /dev/zvol/<pool>/<zvol> appears
  #   systemd-cryptsetup@<luksDevice>   from crypttab (boot.initrd.luks.devices)
  #   <mountPoint>.mount      mounts the key filesystem read-only
  #   zfs-import-<pool>       (nixpkgs) finds the pool already imported and
  #                           loads keys from their file:// keylocations
  #
  # The key filesystem is unmounted before switching to stage 2.
  cryptsetupUnit = u: "systemd-cryptsetup@${utils.escapeSystemdPath u.luksDevice}.service";
  importUnit = name: "zfs-import-${name}.service";

  preimportService =
    name: pool:
    let
      u = pool.luksUnlock;
      importCmd = "zpool import -d ${pool.devNodes} -N ${lib.optionalString cfgZfs.forceImportRoot "-f"} ${name}";
    in
    {
      description = "Import ZFS pool \"${name}\" to unlock its key zvol";
      after = [ "systemd-modules-load.service" ];
      before = [
        (cryptsetupUnit u)
        (importUnit name)
        "shutdown.target"
      ];
      requiredBy = [ (importUnit name) ];
      conflicts = [ "shutdown.target" ];
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      # Like the nixpkgs import: wait for all devices so a pool isn't imported
      # degraded just because a disk was slow to appear, then try once more
      # regardless.
      script = ''
        for _ in $(seq 1 60); do
          if zpool list ${name} >/dev/null 2>&1; then
            exit 0
          fi
          state="$(zpool import -d ${pool.devNodes} 2>/dev/null | awk '/pool: ${name}$/ { found = 1 }; /state:/ { if (found) { print $2; exit } }')"
          if [ "$state" = ONLINE ] && ${importCmd}; then
            exit 0
          fi
          sleep 1
        done
        ${importCmd}
      '';
    };

  keysMount =
    u:
    let
      stage2Conflicts = [
        "initrd-switch-root.target"
        "shutdown.target"
      ];
    in
    {
      what = "/dev/mapper/${u.luksDevice}";
      where = u.mountPoint;
      type = u.fsType;
      options = "ro";
      unitConfig.DefaultDependencies = false;
      requires = [ (cryptsetupUnit u) ];
      after = [ (cryptsetupUnit u) ];
      before = stage2Conflicts;
      conflicts = stage2Conflicts;
    };
in
{
  # Extends the nixpkgs zfs module's boot.zfs.pools submodule.
  options.boot.zfs.pools = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options.luksUnlock = lib.mkOption {
          type = lib.types.nullOr (lib.types.submodule luksUnlockModule);
          default = null;
          description = ''
            Load this pool's encryption keys in stage 1 from a filesystem inside
            a LUKS container on one of the pool's (unencrypted) zvols. The
            pool's encryption roots must use keylocation=file://<mountPoint>/...
            and the pool must be imported in stage 1 (i.e. hold a filesystem
            needed for boot).

            The LUKS device itself (how to unlock it, discards, ...) is
            configured as usual under boot.initrd.luks.devices.<luksDevice>;
            this only sets its device path.

            Requires systemd stage 1.
          '';
        };
      }
    );
  };

  config = lib.mkIf (unlockPools != { }) {
    assertions = [
      {
        assertion = config.boot.initrd.systemd.enable;
        message = "boot.zfs.pools.<name>.luksUnlock requires systemd stage 1 (boot.initrd.systemd.enable).";
      }
    ];

    boot.initrd.supportedFilesystems = [ "zfs" ] ++ lib.mapAttrsToList (_: pool: pool.luksUnlock.fsType) unlockPools;

    boot.initrd.luks.devices = lib.mapAttrs'
      (
        name: pool: lib.nameValuePair pool.luksUnlock.luksDevice { device = "/dev/zvol/${name}/${pool.luksUnlock.zvol}"; }
      )
      unlockPools;

    boot.initrd.systemd.services = lib.mkMerge [
      (lib.mapAttrs' (name: pool: lib.nameValuePair "zfs-preimport-${name}" (preimportService name pool)) unlockPools)
      (lib.mapAttrs'
        (
          name: pool: lib.nameValuePair "zfs-import-${name}" { unitConfig.RequiresMountsFor = pool.luksUnlock.mountPoint; }
        )
        unlockPools)
    ];

    boot.initrd.systemd.mounts = lib.mapAttrsToList (_: pool: keysMount pool.luksUnlock) unlockPools;
  };
}
