{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./zrepl.nix
      ./auto-upgrade.nix
      ./wireguard.nix
      ../../system/enable-flakes.nix
      ../../common/packages.nix
      ../../common/users.nix
      ../../services/hydra.nix
      ../../services/hydra-proxy.nix
      ../../services/nix-serve.nix
      ../../services/nix-gc.nix
      ../../services/grafana.nix
      ../../services/prometheus.nix
      ../../services/github-runner.nix
    ];

  boot = {
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
    loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      systemd.enable = true;
      systemd.emergencyAccess = true;
      secrets = {
        "/keys/swap-luks" = null;
        "/keys/mithlond-system" = null;
        "/keys/mithlond-local" = null;
        "/keys/mithlond-users" = null;
      };
    };
    # we don't mount any filesystems from this pool, but zrepl does need it for backups
    zfs = {
      extraPools = [ "aman" ];
      requestEncryptionCredentials = [
        "mithlond/local"
        "mithlond/system"
        "mithlond/users"
      ];
    };
  };
  networking = {
    hostName = "mithlond";
    hostId = "30ba7498";
  };
  systemd.network = {
    enable = true;
    netdevs = {
      "20-br0" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br0";
          MACAddress = "7c:83:34:b1:c2:d1";
        };
      };
    };
    networks = {
      "30-enp2s0" = {
        matchConfig.Name = "enp2s0";
        networkConfig.Bridge = "br0";
        linkConfig.RequiredForOnline = "enslaved";
      };
      "40-br0" = {
        matchConfig.Name = "br0";
        bridgeConfig = { };
        networkConfig = {
          DHCP = true;
        };
        linkConfig = {
          RequiredForOnline = "routable";
        };
      };
    };
  };

  time.timeZone = "America/Chicago";
  system.stateVersion = "22.05";
  i18n.defaultLocale = "en_US.UTF-8";
  nix.settings.trusted-users = [ "@wheel" ];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users = {
      sjanssen = {
        imports = [
          ../../../home-manager/modules/allow-unfree.nix
          ../../../home-manager/modules/general-shell.nix
          ../../../home-manager/modules/git-username.nix
          ../../../home-manager/modules/zsh.nix
        ];
      };
    };
  };
  # for vscode-server:
  programs.nix-ld.enable = true;
  virtualisation.docker = {
    autoPrune.enable = true;
    enable = true;
    storageDriver = "zfs";
    extraOptions = "--storage-opt zfs.fsname=mithlond/local/docker";
  };
  virtualisation.libvirtd = {
    allowedBridges = [ "br0" ];
    onShutdown = "shutdown";
  };
  programs.virt-manager.enable = true;
  users.users.sjanssen.extraGroups = [ "docker" ];
  services = {
    dbus.enable = true;
    timesyncd.enable = true;
    tailscale.enable = true;
    iperf3.enable = true;
    home-assistant-os.enable = true;
  };
  environment.systemPackages = [ pkgs.sbctl ];
}
