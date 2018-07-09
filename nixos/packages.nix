{ config, pkgs, ... }:

{
  nix.binaryCachePublicKeys = [
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    "ungoliant-1:SVpigbAekoSnOExbVYT0pQvKWofIRv0Te4ouazLb/BU="
  ];

  # this prevents nix from garbage collecting build dependencies, especially
  # helpful with texlive which has very large source downloads
  nix.extraOptions = ''
    gc-keep-outputs = true
    gc-keep-derivations = true
  '';

  nix.trustedBinaryCaches = [ "http://hydra.nixos.org/" ];

  boot.cleanTmpDir = true;

  security.sudo.wheelNeedsPassword = false;

  networking.networkmanager.enable = true;

  # have to disable firewall to make chromecast work
  networking.firewall.enable = false;

  nixpkgs.config = {
    allowUnfree = true;
    chromium = {
      # enablePepperFlash = true;
      # enablePepperPDF = true;
      # enableWideVine = true;
    };
    firefox = {
      enableAdobeFlash = true;
    };
  };

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
  };

  services.dbus.enable = true;
  services.timesyncd.enable = true;
  services.dbus.packages = [ pkgs.gnome3.gconf pkgs.gnome3.dconf ];
  services.udisks2.enable = true;
  services.printing.enable = true;

  hardware.pulseaudio.enable = true;

  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.windowManager = {
    default = "xmonad";
    xmonad.enable = true;
    xmonad.enableContribAndExtras = true;
    xmonad.extraPackages = haskellPackages: [
      haskellPackages.xmonad-contrib
      haskellPackages.taffybar
    ];
  };
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.desktopManager.default = "none";
  services.xserver.desktopManager.gnome3.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.autoLogin.enable = true;
  services.xserver.displayManager.gdm.autoLogin.user = "sjanssen";

  fonts = {
    fontconfig.ultimate.enable = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      inconsolata
      ttf_bitstream_vera
      dejavu_fonts
    ];
  };

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
    gnome3.gnome_terminal
    gnome3.nautilus
    gnome3.gnome_session
    pavucontrol
    # weston
    gnumake
    evince
    gnumake
    htop
    zip
    unzip
    autoconf
    automake
    gettext
    libtool
    mplayer
    pciutils
    xflux
    binutils
    nix-prefetch-scripts
    pkgconfig
    scrot
    ncdu
    dropbox
    cabal2nix
    atom
    firefox
    flashplayer
    gnome3.gnome-tweak-tool
    gnome3.gnome_settings_daemon
    gnome3.gsettings_desktop_schemas
    gdb
    tmux
    nodejs

    (pkgs.haskellPackages.ghcWithPackages (self : [
        self.mtl
        self.xmonad
        self.taffybar
        self.cabal-install
        # self.ghc-mod
	#self.purescript
    ]))
  ];
}
