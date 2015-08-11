# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      /home/sjanssen/dotfiles/flexgetservice.nix
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
  nix.trustedBinaryCaches = [ "http://hydra.nixos.org"];

  # have to disable firewall to make chromecast work
  networking.firewall.enable = false;

  networking.hostName = "celeborn"; # Define your hostname.
  networking.networkmanager.enable = true;

  security.sudo.wheelNeedsPassword = false;

  # attempts to get resume working again
  # boot.resumeDevice = "/dev/sda4";

  time.timeZone = "US/Central";

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
    deluge
    python27Packages.flexget
    pavucontrol
    weston
    kodi
    gnumake
    evince
    texLiveFull
    gnumake
    python27Packages.buttersink
    htop
    qemu
    cdrkit
    zip
    unzip
    spice
    autoconf
    automake
    gettext
    libtool
    mplayer
    pciutils
    xflux
    darcs
    binutils
    nix-prefetch-scripts
    pkgconfig
    scrot

    (pkgs.haskellngPackages.ghcWithPackages (self : [
        self.mtl
        self.xmonad
        self.taffybar
        self.cabal-install
    ]))
  ];
  programs.zsh.enable = true;

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
  };

  services.dbus.enable = true;
  services.timesyncd.enable = true;
  services.dbus.packages = [ pkgs.gnome.GConf pkgs.gnome3.dconf ];
  services.udisks2.enable = true;
  services.printing.enable = true;

  hardware.pulseaudio.enable = true;

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.layout = "us";
  services.xserver.windowManager = {
    default = "xmonad";
    xmonad.enable = true;
    xmonad.enableContribAndExtras = true;
    xmonad.extraPackages = haskellPackages: [ haskellPackages.xmonad-contrib haskellPackages.taffybar ];
  };
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.desktopManager.default = "none";
  services.xserver.displayManager.kdm.enable = true;

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

  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  users.extraUsers.sjanssen = {
    isNormalUser = true;
    uid = 1000;
    group = "sjanssen";
    extraGroups = ["wheel" "networkmanager" "weston-launch"];
    shell = "/run/current-system/sw/bin/zsh";
  };
  users.extraGroups.sjanssen = {
    gid = 1000;
  };
}
