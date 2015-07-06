# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
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
  networking.networkmanager.enable = true;

  time.timeZone = "US/Central";

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "lat9w-16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  nixpkgs.config = {
    allowUnfree = true;
    chromium = {
      enablePepperFlash = true;
      enablePepperPDF = true;
    };
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    wget
    vimHugeX
    haskellPackages.cabal2nix
    haskellPackages.xmobar
    git
    zsh
    chromium
    mosh
    networkmanagerapplet
    trayer
    rxvt_unicode
    screen
    nox
    psmisc
    xlibs.xmodmap
    file
    gnome3.gnome-disk-utility
  ];
  programs.zsh.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.dbus.enable = true;
  services.ntp.enable = true;
  services.dbus.packages = [ pkgs.gnome.GConf pkgs.gnome3.dconf ];
  # environment.pathsToLink = [ "/etc/gconf" ];
  services.smartd.enable = true;
  services.udisks2.enable = true;
  services.printing.enable = true;
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

  hardware.pulseaudio.enable = true;

  services.wakeonlan.interfaces = [ { interface = "enp1s0"; method = "magicpacket"; } ];

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.synaptics.enable = true;
  services.xserver.windowManager = {
    default = "xmonad";
    xmonad.enable = true;
    xmonad.enableContribAndExtras = true;
  };
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.desktopManager.gnome3.enable = true;

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      inconsolata
      ttf_bitstream_vera
      dejavu_fonts
    ];
  };

  nix.distributedBuilds = true;
  nix.buildMachines = [ { hostName = "192.168.1.200"; maxJobs = 8; sshKey = "/home/sjanssen/.ssh/id_rsa"; sshUser = "sjanssen"; system = "x86_64-linux"; } ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.extraUsers.guest = {
  #   isNormalUser = true;
  #   uid = 1000;
  # };
  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  users.extraUsers.sjanssen = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = ["wheel" "networkmanager"];
    shell = "/run/current-system/sw/bin/zsh";
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtAvnTjqnz4eYpPYZacgH5y9hAf+wRPCnNGSIA7a1Wm5E0ebqWuoOZp7L++g7SKDQ49ZMcX8fhgHJpS/0kIVDf4ku+L3WiOJN/rnQyZ7NoP3vmM224aN8xJFoSBHfg/rUjiAktcaBRmq6IaX+mxTGn63s1ITP5ls4c1bP7bjZXXlTLmJmY6H6jgvvjK39w9Wci36DldIv0hSsZ/bJyoRynEsXkgWFhGMRc7ZTJRKraaBPqz3377q5k2Uod9DlYy5Tl/BhRL7d1qtwgnMrMLUOkCrykxlP+sByyS05rRDkvdWwZduJavCJAW5ylFR5Fe/6bNWIAU5xsM/G8/zQvxoUFQ== sjanssen@celeborn" ];
  };
}
