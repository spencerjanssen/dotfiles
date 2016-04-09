# just symlink this file to /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./surface-hardware-configuration.nix
      ./packages.nix
      ./users.nix
      ./btrfs_backup.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.gummiboot.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    linux_4_4 = pkgs.linux_4_4.override {
        kernelPatches =
            [ pkgs.kernelPatches.bridge_stp_helper
              { patch = /home/sjanssen/debian-mssp4/patches/001_typing-cover.patch;
                name = "surface_touchpad"; }
            ];
    };
  };
  nix.buildCores = 0;

  networking.hostName = "surface"; # Define your hostname.

  time.timeZone = "US/Central";

  services.xserver.videoDrivers = [ "nvidia" ];
  users.extraGroups.vboxusers.members = [ "sjanssen" ];

}
