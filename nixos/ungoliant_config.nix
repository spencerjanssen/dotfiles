# just symlink this file to /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./ungoliant-hardware-configuration.nix
      ./packages.nix
      ./users.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.systemd-boot.enable = true;

  nix.buildCores = 0;

  nix.extraOptions = "secret-key-files = /root/ungoliant-1.secret";

  networking.hostName = "ungoliant"; # Define your hostname.

  time.timeZone = "US/Central";

  # https://bugs.launchpad.net/linux/+bug/1690085/comments/69
  # https://bugzilla.kernel.org/show_bug.cgi?id=196683
  nixpkgs.config.packageOverrides = pkgs: {
    linux_4_14 = pkgs.linux_4_14.override {
      extraConfig = ''
        RCU_EXPERT y
        RCU_NOCB_CPU y
      '';
    };
  };
  boot.kernelParams = [ "rcu_nocbs=0-15" ];

  services.xserver.videoDrivers = [ "nvidia" ];

  services.wakeonlan.interfaces = [ { interface = "enp11s0"; method = "magicpacket"; } ];

  environment.systemPackages = with pkgs; [
    nixopsUnstable
    awscli
    nodejs
    vscode
  ];
}
