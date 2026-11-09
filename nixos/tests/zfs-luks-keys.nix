# Boots nixos/system/zfs-luks-keys.nix in a VM: the pool "tank" holds the zvol
# tank/keys, a LUKS container (unlocked by a raw keyfile partition) whose ext4
# filesystem holds the keyfiles for tank's encryption roots.
{ lib, ... }:

let
  keyPartition = "/dev/disk/by-partuuid/0badc0de-01";

  fileSystems = {
    # neededForBoot makes "tank" a root pool, so it is imported (and its keys
    # loaded) in stage 1.
    "/tank-root" = {
      device = "tank/system/root";
      fsType = "zfs";
      neededForBoot = true;
    };
    # Mounted in stage 2; its key must already be loaded.
    "/tank-home" = {
      device = "tank/users/test";
      fsType = "zfs";
    };
  };
in
{
  name = "zfs-luks-keys";

  nodes.machine =
    { pkgs, ... }:
    {
      virtualisation = {
        # vdb: keyfile partition, vdc: tank vdev
        emptyDiskImages = [
          16
          512
        ];
        useBootLoader = true;
        useEFIBoot = true;
      };
      boot.loader.systemd-boot.enable = true;
      boot.loader.timeout = 0;
      # Make the serial port the primary console so stage 1 output shows up
      # in the test log.
      boot.kernelParams = lib.mkAfter [ "console=ttyS0" ];

      networking.hostId = "deadbeef";
      boot.supportedFilesystems = [ "zfs" ];
      boot.initrd.systemd.enable = false;
      # /dev/disk/by-id doesn't get populated in the NixOS test framework
      boot.zfs.devNodes = "/dev/disk/by-uuid";

      environment.systemPackages = [ pkgs.cryptsetup ];

      # The base system only creates the disks.
      specialisation.zfs-luks-keys.configuration =
        { config, ... }:
        {
          imports = [ ../system/zfs-luks-keys.nix ];
          boot.initrd.luks.devices."tank-keys" = {
            keyFile = keyPartition;
            keyFileSize = 4096;
          };
          boot.zfs.pools.tank.luksUnlock = {
            zvol = "keys";
            luksDevice = "tank-keys";
            fsType = "ext4";
          };

          # With the default filesystems, the qemu-vm module discards all
          # boot.initrd.luks.devices (mkVMOverride { }). The disk image is
          # still created by the base system, so only "/" needs restating.
          virtualisation.useDefaultFilesystems = false;
          virtualisation.fileSystems = fileSystems // {
            "/" = {
              device = config.virtualisation.rootDevice;
              fsType = "ext4";
            };
          };
        };
    };

  testScript =
    { nodes, ... }:
    let
      toplevel = nodes.machine.specialisation.zfs-luks-keys.configuration.system.build.toplevel;
    in
    # python
    ''
      def check_tank():
          assert machine.succeed("findmnt -no FSTYPE,SOURCE /tank-root").split() == ["zfs", "tank/system/root"]
          assert machine.succeed("findmnt -no FSTYPE,SOURCE /tank-home").split() == ["zfs", "tank/users/test"]
          machine.succeed(
              "grep -qx root-marker /tank-root/marker",
              "grep -qx home-marker /tank-home/marker",
              "test -b /dev/mapper/tank-keys",
          )
          keystatus = machine.succeed("zfs get -Ho value keystatus tank/system tank/users").split()
          assert keystatus == ["available", "available"], keystatus
          # The key filesystem must not leak into stage 2.
          machine.fail("findmnt -S /dev/mapper/tank-keys")

      with subtest("Create keyfile partition, tank pool and tank/keys LUKS zvol"):
          machine.wait_for_unit("multi-user.target")
          machine.succeed(
              "printf 'label: dos\\nlabel-id: 0x0badc0de\\nstart=2048, size=4096, type=83\\n' | sfdisk /dev/vdb",
              "udevadm settle",
              "head -c 4096 /dev/urandom > ${keyPartition}",
              "zpool create -O mountpoint=none tank /dev/vdc",
              "zfs create -V 64M tank/keys",
              "udevadm settle",
              "cryptsetup luksFormat -q --pbkdf=pbkdf2 --iter-time=1"
              + " --keyfile-size=4096 /dev/zvol/tank/keys ${keyPartition}",
              "cryptsetup open --keyfile-size=4096 --key-file=${keyPartition} /dev/zvol/tank/keys tank-keys",
              "mkfs.ext4 -q /dev/mapper/tank-keys",
              "mkdir -p /media/tank-keys",
              "mount /dev/mapper/tank-keys /media/tank-keys",
              "head -c 32 /dev/urandom > /media/tank-keys/system.key",
              "head -c 32 /dev/urandom > /media/tank-keys/users.key",
              "zfs create -o encryption=on -o keyformat=raw"
              + " -o keylocation=file:///media/tank-keys/system.key tank/system",
              "zfs create -o mountpoint=legacy tank/system/root",
              "zfs create -o encryption=on -o keyformat=raw"
              + " -o keylocation=file:///media/tank-keys/users.key tank/users",
              "zfs create -o mountpoint=legacy tank/users/test",
              "mkdir /mnt",
              "mount -t zfs tank/system/root /mnt",
              "echo root-marker > /mnt/marker",
              "umount /mnt",
              "mount -t zfs tank/users/test /mnt",
              "echo home-marker > /mnt/marker",
              "umount /mnt",
              "umount /media/tank-keys",
              "cryptsetup close tank-keys",
              "zpool export tank",
          )

      with subtest("Boot with zfs-luks-keys"):
          machine.succeed("${toplevel}/bin/switch-to-configuration boot", "sync")
          machine.shutdown()
          machine.start()
          machine.wait_for_unit("multi-user.target")
          booted = machine.succeed("readlink -f /run/booted-system").strip()
          assert booted == "${toplevel}", f"booted {booted}"
          check_tank()
    '';
}
