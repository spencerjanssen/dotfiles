{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./zrepl.nix
      ./auto-upgrade.nix
      ./wireguard.nix
      ../../system/enable-flakes.nix
      ../../nixos/common/packages.nix
      ../../nixos/common/users.nix
      ../../nixos/home-assistant-supervisor/module.nix
      ../../services/hydra.nix
      ../../services/hydra-proxy.nix
      ../../services/nix-serve.nix
      ../../services/nix-gc.nix
      ../../services/grafana.nix
      ../../services/prometheus.nix
    ];

  boot = {
    loader = {
      systemd-boot.enable = true;
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
    # zfs.extraPools = [ "aman" ];
  };
  networking.hostName = "mithlond";
  networking.hostId = "30ba7498";
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
          ../../nixos/home-manager/allow-unfree.nix
          ../../nixos/home-manager/general-shell.nix
          ../../nixos/home-manager/git-username.nix
          ../../nixos/home-manager/zsh.nix
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
  users.users.sjanssen.extraGroups = [ "docker" ];
  services = {
    dbus.enable = true;
    timesyncd.enable = true;
    tailscale.enable = true;
    iperf3.enable = true;
    home-assistant-supervisor = {
      enable = true;
      architecture = "amd64";
      machine = "generic-x86-64";
    };
  };
}
