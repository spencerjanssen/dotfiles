# just symlink this file to /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ./flexgetservice.nix
      ./packages.nix
      ./users.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sdc";
  boot.loader.grub.extraEntries =
''
menuentry "Windows 10" {
    set root=(hd0,msdos2)
    chainloader +1
}

menuentry "Ubuntu boot partition" {
    insmod ext2
    insmod ext3
    set root=(hd0,0)
    configfile /grub/grub.cfg
}
''
;

  nix.buildCores = 0;

  networking.hostName = "celeborn"; # Define your hostname.

  time.timeZone = "US/Central";

  services.xserver.videoDrivers = [ "nvidia" ];

  # packages that aren't shared with other machines:
  environment.systemPackages = with pkgs; [
    deluge
    python27Packages.flexget
    kodi
    cdrkit
    spice
    qemu
  ];
}
