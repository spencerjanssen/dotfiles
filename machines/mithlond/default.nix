{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./zrepl.nix
      ./auto-upgrade.nix
      ../../system/enable-flakes.nix
      ../../nixos/common/packages.nix
      ../../nixos/common/users.nix
      ../../nixos/home-assistant-supervisor/module.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "mithlond";
  networking.hostId = "30ba7498";
  time.timeZone = "America/Chicago";
  system.stateVersion = "22.05";
  boot.initrd.secrets = {
    "/keys/swap-luks" = null;
    "/keys/mithlond-system" = null;
    "/keys/mithlond-local" = null;
    "/keys/mithlond-users" = null;
  };
  boot.initrd = {
    systemd.enable = true;
    systemd.emergencyAccess = true;
  };
  i18n.defaultLocale = "en_US.UTF-8";
  nix.settings.trusted-users = [ "@wheel" ];
  services.dbus.enable = true;
  services.timesyncd.enable = true;
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
  virtualisation.docker = {
    autoPrune.enable = true;
    enable = true;
    storageDriver = "zfs";
    extraOptions = "--storage-opt zfs.fsname=mithlond/local/docker";
  };
  users.users.sjanssen.extraGroups = [ "docker" ];
  services.home-assistant-supervisor = {
    enable = true;
    architecture = "amd64";
    machine = "generic-x86-64";
  };
}
