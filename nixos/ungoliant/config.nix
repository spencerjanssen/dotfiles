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
      ./hydra.nix
      ../cachix
      ../../system/magic-sysrq.nix
      ../../system/enable-flakes.nix
      ../../hardware/acs.nix
      ../../hardware/moonlander.nix
    ];

  system.stateVersion = "21.11";

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

  networking.hostName = "ungoliant"; # Define your hostname.
  networking.hostId = "9fd4ccb9";

  time.timeZone = "US/Central";

  nixpkgs.overlays = import ../common/overlays.nix;

  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt"
    "amdgpu.dc=1"
    "kvm.ignore_msrs=1"
    "kvm.report_ignored_msrs=0"
    "pcie_acs_override=downstream,multifunction"
  ];

  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:1401,10de:0fba,10ec:5760
  '';
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelModules = [
    "vfio_pci"
    "nct6775" # for motherboard fan control
    "i2c-dev" # for ddcutil
  ];

  security.tpm2.enable = true;

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
      umount /media/tank-keys
      rmdir /media-tank-keys
    '';
  };


  fileSystems."/media/spinning".options = ["noauto"];

  services.xserver.videoDrivers = [ "amdgpu" ];

  networking.interfaces.enp10s0.wakeOnLan.enable = true;

  virtualisation.docker = {
    autoPrune.enable = true;
    enable = true;
    storageDriver = "zfs";
    extraOptions = "--storage-opt zfs.fsname=tank/local/docker";
  };
  users.users.sjanssen.extraGroups = ["docker"];

  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.verbatimConfig = ''
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
                grid = "1x1h(keep=all) | 24x1h | 10x1d | 5x1w | 3x30d";
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
                grid = "1x1h(keep=all) | 24x1h | 10x1d | 5x1w | 3x30d";
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

  services.zfs.zed.settings = {
    ZED_SYSLOG_SUBCLASS_EXCLUDE="statechange|config_*|history_event";
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

  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.extraModules = [pkgs.pulseaudio-modules-bt];

  programs.wireshark.enable = true;

  services.resolved.enable = true;
  
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

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users = {
      sjanssen = {
        imports = [
          ../home-manager/ungoliant.nix
          ../home-manager/allow-unfree.nix
          ../home-manager/general-shell.nix
          ../home-manager/git-username.nix
          ../home-manager/xsession.nix
          ../home-manager/zsh.nix
          ../home-manager/sign-commits.nix
        ];
      };
    };
  };
}
