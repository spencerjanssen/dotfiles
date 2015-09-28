{ config, pkgs, ... }:

{
  nix.trustedBinaryCaches = [ "http://hydra.nixos.org"];

  # this prevents nix from garbage collecting build dependencies, especially
  # helpful with texlive which has very large source downloads
  nix.extraOptions = ''
    gc-keep-outputs = true
    gc-keep-derivations = true
  '';

  boot.cleanTmpDir = true;

  security.sudo.wheelNeedsPassword = false;

  networking.networkmanager.enable = true;

  # have to disable firewall to make chromecast work
  networking.firewall.enable = false;

  nixpkgs.config = {
    allowUnfree = true;
    chromium = {
      enablePepperFlash = true;
      enablePepperPDF = true;
    };
  };

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
  };

  services.dbus.enable = true;
  services.timesyncd.enable = true;
  services.dbus.packages = [ pkgs.gnome.GConf pkgs.gnome3.dconf ];
  services.udisks2.enable = true;
  services.printing.enable = true;

  hardware.pulseaudio.enable = true;

  services.xserver.enable = true;
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
    pavucontrol
    weston
    gnumake
    evince
    gnumake
    python27Packages.buttersink
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
    darcs
    binutils
    nix-prefetch-scripts
    pkgconfig
    scrot
    ncdu
    dropbox
    cabal2nix
    vimPlugins.ghc-mod-vim
    # required for ghc-mod-vim
    vimPlugins.vimproc

    (pkgs.haskellngPackages.ghcWithPackages (self : [
        self.mtl
        self.xmonad
        self.taffybar
        self.cabal-install
        self.ghc-mod
    ]))
  ];
}
