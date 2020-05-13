# just symlink this file to /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../common/packages.nix
      ../common/desktop.nix
      ../common/users.nix
      ../common/nix-serve.nix
      ./hydra.nix
      ./btrfs-backup-sync.nix
      ../cachix
      ./arm-crosscompile.nix
      ((import ../nix/sources.nix {}).hercules-ci-agent + "/module.nix")
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
    linux_5_6 = pkgs.linux_5_6.override {
      kernelPatches =
        pkgs.linux_5_6.kernelPatches ++
        [
        # https://queuecumber.gitlab.io/linux-acs-override/
        {
          name = "ACS override";
          patch = pkgs.fetchurl {
            url = "https://gitlab.com/Queuecumber/linux-acs-override/raw/master/workspaces/5.6.12/acso.patch";
            sha256 = "13jdfpvc0k98hr82g1nxkzfgs37xq4gp1mpmflqk43z3nyqvszql";
          };
        }
        ];
    };
  };

  nixpkgs.overlays = import ../common/overlays.nix;

  boot.kernelParams = [ "amd_iommu=on iommu=pt amdgpu.dc=1 kvm.ignore_msrs=1 kvm.report_ignored_msrs=0 pcie_acs_override=downstream,multifunction" ];
  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:1401,10de:0fba,10ec:5760
  '';
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelModules = [
    "vfio_pci"
    "nct6775" # for motherboard fan control
    "i2c-dev" # for ddcutil
  ];

  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_5_6;

  boot.initrd.luks.devices."blue" = {
    allowDiscards = true;
    keyFileSize = 4096;
    keyFile = "/dev/disk/by-partuuid/c59a413a-01";
    fallbackToPassword = true;
  };

  boot.initrd.luks.devices."nvmeswap" = {
    device = "/dev/disk/by-uuid/637cf5c2-af86-471a-b8ed-9bd8efb5f256";
    allowDiscards = true;
    keyFileSize = 4096;
    keyFile = "/dev/disk/by-partuuid/c59a413a-01";
    fallbackToPassword = true;
  };

  boot.initrd.luks.devices."pro" = {
    allowDiscards = true;
    keyFileSize = 4096;
    keyFile = "/dev/disk/by-partuuid/c59a413a-01";
    fallbackToPassword = true;
  };

  boot.kernel.sysctl = {
    "kernel.sysrq" =
      4 # keyboard control
      + 16 # sync
      + 32 # remount read-only
      + 64 # signal processes
      + 128 # reboot/poweroff
    ;
  };

  fileSystems."/media/spinning".options = ["noauto"];

  services.xserver.videoDrivers = [ "amdgpu" ];

  services.wakeonlan.interfaces = [ { interface = "enp10s0"; method = "magicpacket"; } ];

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

  services.fwupd.enable = true;

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

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "gnome-session";

  hardware.bluetooth.enable = true;
  hardware.bluetooth.config = {
    General = {
      Enable = "Source,Sink,Headset,Media,Socket";
    };
  };
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.extraModules = [pkgs.pulseaudio-modules-bt];

  security.wrappers.spice-client-glib-usb-acl-helper.source =
    "${pkgs.spice-gtk}/bin/spice-client-glib-usb-acl-helper.real";
  
  programs.wireshark.enable = true;

  networking.extraHosts = 
    if builtins.pathExists ./extra-hosts.txt
      then builtins.readFile ./extra-hosts.txt
      else "";
  
  services.samba = {
    enable = true;
    shares = {
      blue = {
        browseable = "yes";
        comment = "Bulk storage";
        "guest ok" = "no";
        path = "/media/blue/smbshare";
        "read only" = false;
      };
      homes = {
        browseable = "no";
        comment = "Home directories";
        writable = "yes";
        "valid users" = "%S";
      };
    };
  };

  services.hercules-ci-agent.enable = true;
  services.hercules-ci-agent.concurrentTasks = 4;
}
