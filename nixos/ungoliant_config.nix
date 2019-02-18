# just symlink this file to /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./ungoliant-hardware-configuration.nix
      ./packages.nix
      ./users.nix
      ./mediaserver.nix
      ./hydra.nix
      ./btrfs-backup-sync.nix
    ];

  system.stateVersion = "18.03";

  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = null;

  nix.buildCores = 0;

  nix.extraOptions = "secret-key-files = /root/ungoliant-1.secret";

  nix.gc.automatic = true;
  nix.gc.dates = "weekly";

  networking.hostName = "ungoliant"; # Define your hostname.

  time.timeZone = "US/Central";

  # https://bugs.launchpad.net/linux/+bug/1690085/comments/69
  # https://bugzilla.kernel.org/show_bug.cgi?id=196683
  nixpkgs.config.packageOverrides = pkgs: {
    linux_latest = pkgs.linux_latest.override {
      kernelPatches =
        pkgs.linux_latest.kernelPatches ++ 
        [
        # https://queuecumber.gitlab.io/linux-acs-override/
        {
          name = "ACS override";
          patch = pkgs.fetchurl {
            url = "https://gitlab.com/Queuecumber/linux-acs-override/raw/master/workspaces/4.20/acso.patch";
            sha256 = "14garkj80g7jyi7acvp5zx447328yqwy6ll2qm79j7mm8x2k5r87";
          };
        }];
    };
  };

  nixpkgs.overlays = import ./overlays.nix;

  boot.kernelParams = [ "amd_iommu=on iommu=pt amdgpu.dc=1 pcie_acs_override=downstream,multifunction" ];
  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:1401,10de:0fba
  '';
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelModules = [ "vfio_pci" ];

  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_latest;

  boot.initrd.luks.devices."blue" = {
    allowDiscards = true;
    keyFileSize = 4096;
    keyFile = "/dev/disk/by-partuuid/c59a413a-01";
  };

  boot.initrd.luks.devices."nvmeswap" = {
    device = "/dev/disk/by-uuid/637cf5c2-af86-471a-b8ed-9bd8efb5f256";
    allowDiscards = true;
    keyFileSize = 4096;
    keyFile = "/dev/disk/by-partuuid/c59a413a-01";
  };

  fileSystems."/media/spinning".options = ["noauto"];

  services.xserver.videoDrivers = [ "amdgpu" ];

  services.wakeonlan.interfaces = [ { interface = "enp42s0"; method = "magicpacket"; } ];

  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemuVerbatimConfig = ''
namespaces = []
cgroup_controllers = [ "cpu", "devices", "memory", "blkio", "cpuset", "cpuacct" ]
cgroup_device_acl = [
    "/dev/null", "/dev/full", "/dev/zero",
    "/dev/random", "/dev/urandom",
    "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
    "/dev/rtc","/dev/hpet",
    "/dev/input/by-id/usb-Microsoft_Microsoft®_2.4GHz_Transceiver_v9.0-if01-event-mouse",
    "/dev/input/by-id/usb-Microsoft_Microsoft®_2.4GHz_Transceiver_v9.0-event-kbd"
]
  '';

  environment.systemPackages = with pkgs; [
    qemu
    libvirt
    virtmanager
    spice-gtk
    openconnect
    iptables
    flatpak
    snapper
    cryptsetup
  ];
  environment.unixODBCDrivers = [ pkgs.unixODBCDrivers.msodbcsql17];

  services.flatpak.enable = true;

  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.interval = "weekly";
  services.btrfs.autoScrub.fileSystems = ["/" "/media/blue"];

  services.snapper.configs = {
    home = {
      subvolume = "/media/evo/@home";
      extraConfig = ''
        TIMELINE_CREATE="yes"
        TIMELINE_CLEANUP="yes"
        TIMELINE_LIMIT_YEARLY="0"
      '';
    };
    nixos = {
      subvolume = "/media/evo/@nixos";
      extraConfig = ''
        TIMELINE_CREATE="yes"
        TIMELINE_CLEANUP="yes"
        TIMELINE_LIMIT_DAILY="5"
        TIMELINE_LIMIT_MONTHLY="0"
        TIMELINE_LIMIT_YEARLY="0"
      '';
    };

    home-blue = {
      subvolume = "/media/blue/backups/ungoliant/@home";
      extraConfig = ''
        TIMELINE_CLEANUP="yes"
        TIMELINE_LIMIT_HOURLY="72"
        TIMELINE_LIMIT_DAILY="31"
        TIMELINE_LIMIT_WEEKLY="6"
        TIMELINE_LIMIT_MONTHLY="12"
        TIMELINE_LIMIT_YEARLY="5"
      '';
    };

    nixos-blue = {
      subvolume = "/media/blue/backups/ungoliant/@nixos";
      extraConfig = ''
        TIMELINE_CLEANUP="yes"
        TIMELINE_LIMIT_HOURLY="72"
        TIMELINE_LIMIT_DAILY="7"
        TIMELINE_LIMIT_WEEKLY="6"
        TIMELINE_LIMIT_MONTHLY="0"
        TIMELINE_LIMIT_YEARLY="0"
      '';
    };
  };

  security.wrappers.spice-client-glib-usb-acl-helper.source =
    "${pkgs.spice-gtk}/bin/spice-client-glib-usb-acl-helper.real";
  
  programs.wireshark.enable = true;
}
