{ config, lib, ... }:

let
  unlockPools = lib.filterAttrs (_: pool: pool.luksUnlock != null) config.boot.zfs.pools;

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

            The LUKS device itself (how to unlock it, discards, ...) is
            configured as usual under boot.initrd.luks.devices.<luksDevice>;
            this only sets its device path and hooks into opening it.

            Requires scripted stage 1 (preLVMCommands/postOpenCommands).
          '';
        };
      }
    );
  };

  config = lib.mkIf (unlockPools != { }) {
    assertions = [
      {
        assertion = !config.boot.initrd.systemd.enable;
        message = "boot.zfs.pools.<name>.luksUnlock requires scripted stage 1 (boot.initrd.systemd.enable = false).";
      }
    ];

    boot.initrd.supportedFilesystems = [ "zfs" ] ++ lib.mapAttrsToList (_: pool: pool.luksUnlock.fsType) unlockPools;

    # Scripted stage 1 doesn't include zfs's udev rules, so /dev/zvol/... links
    # would never appear. The zfs module already copies zvol_id into
    # extra-utils; point the rule at that copy.
    boot.initrd.extraUdevRulesCommands =
      let
        zfs = config.boot.zfs.package;
      in
      ''
        substitute ${zfs}/lib/udev/rules.d/60-zvol.rules $out/60-zvol.rules \
          --replace-fail ${zfs}/lib/udev/zvol_id ${config.system.build.extraUtils}/bin/zvol_id
      '';

    # The zvols only exist once the pools are imported, which must happen
    # before the (postLVM) LUKS containers are opened.
    boot.initrd.preLVMCommands = lib.concatStrings (
      lib.mapAttrsToList
        (name: _: ''
          echo "importing ZFS pool ${name}"
          zpool import ${name}
        '')
        unlockPools
    );

    boot.initrd.luks.devices = lib.mapAttrs'
      (
        name: pool:
          let
            u = pool.luksUnlock;
          in
          lib.nameValuePair u.luksDevice {
            device = "/dev/zvol/${name}/${u.zvol}";
            preLVM = false;
            postOpenCommands = ''
              echo "loading ZFS keys for ${name} from ${u.luksDevice}"
              mkdir -p ${u.mountPoint}
              mount -t ${u.fsType} -o ro /dev/mapper/${u.luksDevice} ${u.mountPoint}
              zfs load-key -r ${name}
              umount ${u.mountPoint}
              rmdir ${u.mountPoint}
            '';
          }
      )
      unlockPools;
  };
}
