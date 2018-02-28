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

  networking.hostName = "ungoliant"; # Define your hostname.

  time.timeZone = "US/Central";

  services.xserver.videoDrivers = [ "nvidia" ];

  environment.systemPackages = with pkgs; [
    nixopsUnstable
    awscli
    nodejs
  ];
}
