# just symlink this file to /etc/nixos/configuration.nix
{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../common/packages.nix
      ../common/desktop.nix
      ../common/users.nix
      ../common/nix-serve.nix
      ../common/moonlander.nix
      ./hydra.nix
      ../cachix
    ];

  system.stateVersion = "18.03";

  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 30;

  boot = {
    supportedFilesystems = [ "zfs" ];
    initrd = {
      supportedFilesystems = [ "zfs" "vfat" ];
    };
  };

  nix.buildCores = 0;

  nix.extraOptions = ''
    secret-key-files = /root/ungoliant-1.secret
    experimental-features = nix-command flakes
  '';

  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.package = pkgs.nixUnstable;

  networking.hostName = "ungoliant"; # Define your hostname.
  networking.hostId = "9fd4ccb9";

  time.timeZone = "US/Central";

  # https://bugs.launchpad.net/linux/+bug/1690085/comments/69
  # https://bugzilla.kernel.org/show_bug.cgi?id=196683
  nixpkgs.config.packageOverrides = pkgs: {
    linux_5_10 = pkgs.linux_5_10.override {
      kernelPatches =
        pkgs.linux_5_10.kernelPatches ++
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

  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_5_10;

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

  boot.initrd.preLVMCommands = ''
    echo importing tank
    zpool import tank
    echo tank imported
  '';
  boot.initrd.luks.devices."tank-keys" = {
    device = "/dev/disk/by-uuid/4762fb6d-bf46-44fd-bd00-e607e7f77606";
    allowDiscards = true;
    keyFileSize = 4096;
    keyFile = "/dev/disk/by-partuuid/c59a413a-01";
    fallbackToPassword = true;
    preLVM = false;
    postOpenCommands = ''
      echo creating /media/tank-keys
      mkdir -p /media/tank-keys || echo failed to mkdir
      mount /dev/disk/by-id/dm-name-tank-keys /media/tank-keys || ( echo dm-name-tank-keys mount failed ; sleep 5s; mount /dev/disk/by-id/dm-name-tank-keys /media/tank-keys || echo failed again)
      echo mounted tank-keys
      echo loading keys
      zfs load-key -a
      echo loaded keys
    '';
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

  virtualisation.docker = {
    autoPrune.enable = true;
    enable = true;
    storageDriver = "zfs";
  };
  users.users.sjanssen.extraGroups = ["docker"];

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
    "/dev/input/by-id/usb-Microsoft_Microsoft®_2.4GHz_Transceiver_v9.0-event-kbd",
    "/dev/input/by-id/usb-MOSART_Semi._2.4G_Wireless_Mouse-event-mouse"
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
    zfs
    zrepl
  ];
  environment.unixODBCDrivers = [ pkgs.unixODBCDrivers.msodbcsql17];

  services.flatpak.enable = true;

  services.zrepl =
  let
    imladrisConnect = {
      type = "tls";
      address = "imladris.lan:9341";
      ca = "/root/zrepl/imladris.crt";
      cert = "/root/zrepl/ungoliant.crt";
      key = "/root/zrepl/ungoliant.key";
      server_cn = "imladris";
    };
    snapshotPrefix = "zrepl_";
    prefixRegex = "^${snapshotPrefix}.*";
    keepNotReplicated = {
      type = "not_replicated";
    };
    keepNotZrepl = {
      type = "regex";
      negate = true;
      regex = "^${snapshotPrefix}.*";
    };
  in
  {
    enable = true;
    settings = {
      jobs = [
        {
          name = "system-to-imladris";
          type = "push";
          connect = imladrisConnect;
          filesystems = {
            "tank/system<" = true;
          };
          send = {
            encrypted = true;
          };
          snapshotting = {
            type = "periodic";
            prefix = snapshotPrefix;
            interval = "10m";
          };
          pruning = {
            keep_sender = [
              keepNotReplicated
              keepNotZrepl
              {
                type = "grid";
                grid = "1x1h(keep=all) | 23x1h | 7x1d";
                regex = prefixRegex;
              }
            ];
            keep_receiver = [
              keepNotZrepl
              {
                type = "grid";
                grid = "1x1h(keep=all) | 24x1h | 30x1d | 144x30d";
                regex = prefixRegex;
              }
            ];
          };
        }
        {
          name = "sjanssen-to-imladris";
          type = "push";
          connect = imladrisConnect;
          filesystems = {
            "tank/users/sjanssen<" = true;
          };
          send = {
            encrypted = true;
          };
          snapshotting = {
            type = "periodic";
            prefix = snapshotPrefix;
            interval = "5m";
          };
          pruning = {
            keep_sender = [
              keepNotReplicated
              keepNotZrepl
              {
                type = "grid";
                grid = "1x1h(keep=all) | 24x1h | 30x1d | 52x1w | 144x30d";
                regex = prefixRegex;
              }
            ];
            keep_receiver = [
              keepNotZrepl
              {
                type = "grid";
                grid = "1x1h(keep=all) | 24x1h | 30x1d | 52x1w | 144x30d";
                regex = prefixRegex;
              }
            ];
          };
        }
        {
          name = "from-blue-to-imladris";
          type = "push";
          connect = imladrisConnect;
          filesystems = {
            "tank/from-blue<" = true;
          };
          send = {
            encrypted = true;
          };
          snapshotting = {
            type = "periodic";
            prefix = snapshotPrefix;
            interval = "1h";
          };
          pruning = {
            keep_sender = [
              keepNotReplicated
              keepNotZrepl
              {
                type = "grid";
                grid = "1x1h(keep=all) | 24x1h | 30x1d | 52x1w | 144x30d";
                regex = prefixRegex;
              }
            ];
            keep_receiver = [
              keepNotZrepl
              {
                type = "grid";
                grid = "1x1h(keep=all) | 24x1h | 30x1d | 52x1w | 144x30d";
                regex = prefixRegex;
              }
            ];
          };
        }
      ];
    };
  };

  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.interval = "weekly";
  services.btrfs.autoScrub.fileSystems = ["/media/blue"];

  services.zfs.autoScrub = {
    enable = true;
    interval = "weekly";
    pools = ["tank"];
  };

  services.fwupd.enable = true;

  services.snapper.configs = {
    home = {
      subvolume = "/media/blue/@home";
      extraConfig = ''
        TIMELINE_CREATE="yes"
        TIMELINE_CLEANUP="yes"
        TIMELINE_LIMIT_YEARLY="0"
      '';
    };
    nixos = {
      subvolume = "/media/blue/@nixos";
      extraConfig = ''
        TIMELINE_CREATE="yes"
        TIMELINE_CLEANUP="yes"
        TIMELINE_LIMIT_HOURLY="4"
        TIMELINE_LIMIT_DAILY="0"
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
}
