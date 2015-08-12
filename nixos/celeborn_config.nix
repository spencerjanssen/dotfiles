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
  # nix.sshServe.enable = true;
  # nix.sshServe.keys =
    # ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEverbtaMH0WCt25dBry8lyUkNKk6K3/sU8qDCpvKsF8SLe+Mbhr5GPqj3LEyWdK23cSHlPbxKDxAFfqAuYvJgErT//i9lJkVxvZlMC9Xhu6czzTWluSyvHaP8VqxwlAV67TCO8Cb4VnNR+CHTE6hkM94nk43zGrjCYYlPSOx+yHG7NQ/3wxZnrnE6hazZG9s6Rb2vgY9fKXPgtFJHrxn8vyW4tOnIogVh1vaevOg/MwB5wOm31++jRPajbfaB0cAkBXl7Y/u0GeD33XXymwrfG5/DAgX9IytVs5mR0k04I5zA2Ofn8zu+9llnKws7fJBK2X/QhecjZLCBTcSMvLrt sjanssen@nixee"
    # "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvspwqQrPt0Gbq108Ps8n/kuGqrzUsNI+xHlQKoWdAdqHmQTrsHw+B9cHTHyLUbcARqeDEFDtUkpfiDHwXHE2JLEpoHYoio8/O/iXU7/ne1W3ZIxaDOhDlFIFG7Y0ofwralYsFPffZMaIj5JxX+vupmxDyiblGpXtw6g0/EyHf8VsI5QjWD+irH/kKWA1QBMCAUMgvMFPcdP66TVz7VDu5JLr+aqoA9bCaKIWvJQeZzhyRmm98t6t4D0NtK/qMVlgK3Ze2EBjeiu/Yx9gY0bZIOKbYyAcdWqZFiOBSqKFbA7mgbsgF10h8ILTFjKo93CiuIyC8L7X0YpsuUAfnJsfP root@nixee"
    # ];

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
    texLiveFull
  ];
}
