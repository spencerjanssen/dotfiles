# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./eee-hardware-configuration.nix
      ./packages.nix
      ./users.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.extraEntries =
''
menuentry "Windows 7" {
set root=(hd0,1)
chainloader +1
}
''
;

  networking.hostName = "nixee"; # Define your hostname.
  networking.hostId = "8afa1704";

  time.timeZone = "US/Central";

  services.acpid.enable = true;
  services.acpid.lidEventCommands = ''
    LID="/proc/acpi/button/lid/LID/state"
    state=`cat $LID | ${pkgs.gawk}/bin/awk '{print $2}'`
    case "$state" in
      *open*) ;;
      *close*) ${pkgs.pmutils}/sbin/pm-suspend ;;
      *) logger -t lid-handler "Failed to detect lid state ($state)" ;;
    esac
  '';

  services.wakeonlan.interfaces = [ { interface = "enp1s0"; method = "magicpacket"; } ];
  services.xserver.synaptics.enable = true;

  nix.binaryCaches = [
    "http://192.168.1.200"
    "https://cache.nixos.org/"
  ];

  nix.binaryCachePublicKeys = [
    "celeborn-1:aECgTP22b6+Ar1lUfjBY2EwwoEp19+Nxr9FUMXkZ3gk="
  ];

  # nix.extraOptions = "ssh-substituter-hosts = nix-ssh@192.168.1.200";
  nix.distributedBuilds = false;
  # nix.buildMachines = [ { hostName = "192.168.1.200"; maxJobs = 4; sshKey = "/home/sjanssen/.ssh/id_rsa"; sshUser = "sjanssen"; system = "x86_64-linux"; } ];
}
