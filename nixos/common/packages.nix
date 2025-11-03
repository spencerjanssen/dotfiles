{ pkgs, lib, ... }:

{
  nix.settings.trusted-public-keys = [
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    "mithlond.lan-1:dnJ/CK6UiqB9XwEC9k/Sigw06f7JTUCpfPuqTVfyLDw="
  ];

  # this prevents nix from garbage collecting build dependencies, especially
  # helpful with texlive which has very large source downloads
  nix.extraOptions = ''
    gc-keep-outputs = true
    gc-keep-derivations = true
  '';

  nix.settings.substituters = lib.modules.mkOverride 0 [ "http://mithlond.lan:8501" ];
  nix.settings.trusted-substituters = [ "https://cache.nixos.org" ];

  boot.tmp.cleanOnBoot = true;

  security.sudo.wheelNeedsPassword = false;

  networking.networkmanager.enable = true;

  # have to disable firewall to make chromecast work
  networking.firewall.enable = false;

  nixpkgs.config = {
    allowUnfree = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  services.dbus.enable = true;
  services.timesyncd.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    vim-full
    git
    zsh
    psmisc
    file
    htop
    pciutils
    binutils
    usbutils
    tmux
    rsync
    strace
    pv
    cifs-utils
  ];
}
