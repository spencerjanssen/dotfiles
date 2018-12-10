{ config, pkgs, ... }:

{
  nix.binaryCachePublicKeys = [
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    "ungoliant-1:SVpigbAekoSnOExbVYT0pQvKWofIRv0Te4ouazLb/BU="
    "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI="
    "hie-nix.cachix.org-1:EjBSHzF6VmDnzqlldGXbi0RM3HdjfTU3yDRi9Pd0jTY="
  ];

  # this prevents nix from garbage collecting build dependencies, especially
  # helpful with texlive which has very large source downloads
  nix.extraOptions = ''
    gc-keep-outputs = true
    gc-keep-derivations = true
  '';

  nix.binaryCaches = [
    "https://cache.nixos.org/"
    "https://nixcache.reflex-frp.org/"
    "https://hie-nix.cachix.org"
  ];
  nix.trustedBinaryCaches = [
    "http://hydra.nixos.org/"
    "https://nixcache.reflex-frp.org"
    "https://hie-nix.cachix.org"
    ];

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
  services.dbus.packages = [ pkgs.gnome3.dconf ];
  programs.dconf.enable = true;
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
  services.xserver.displayManager.gdm.wayland = false;
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
      hasklig
      fira-code
      fira-mono
      monoid
    ];
  };

  environment.systemPackages = with pkgs; [
    wget
    vimHugeX
    git
    zsh
    mosh
    rxvt_unicode
    screen
    nox
    psmisc
    xlibs.xmodmap
    file
    # weston
    gnumake
    gnumake
    htop
    zip
    unzip
    autoconf
    automake
    gettext
    libtool
    pciutils
    binutils
    nix-prefetch-scripts
    pkgconfig
    ncdu
    cabal2nix
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
    ]))
  ];
}
