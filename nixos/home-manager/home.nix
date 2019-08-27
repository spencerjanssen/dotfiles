{ pkgs, ... }:

let all-hies = import <all-hies> {};
in
{
  imports = [ ./lightweight.nix ];
  # required for hydra
  home.username = "sjanssen";
  home.homeDirectory = "/home/sjanssen";

  xdg.configFile."nixpkgs/config.nix".source = ./config.nix;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh = {
    sessionVariables = {
      LIBVIRT_DEFAULT_URI = "qemu:///system";
    };
  };

  xsession = {
    enable = true;
    preferStatusNotifierItems = true;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;

      extraPackages = haskellPackages: [
        haskellPackages.xmonad-contrib
        haskellPackages.taffybar
      ];
    };
    pointerCursor = {
      defaultCursor = "left_ptr";
      package = pkgs.gnome3.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };
  };

  services.taffybar.enable = true;
  services.status-notifier-watcher.enable = true;
  services.network-manager-applet.enable = true;

  services.redshift.enable = true;
  services.redshift.latitude = "40.741";
  services.redshift.longitude = "-96.64";

  services.screen-locker.enable = true;
  services.screen-locker.lockCmd = "${pkgs.i3lock}/bin/i3lock -n";

  services.udiskie = {
    enable = true;
    notify = true;
    automount = true;
    tray = "always";
  };

  home.packages = with pkgs; [
    (all-hies.selection {selector = p: {inherit (p) ghc822 ghc865;};})
    nixops
    nodejs
    vscode
    discord
    remmina
    haskellPackages.status-notifier-item
    stack
    haskellPackages.ghcid
    google-chrome
    networkmanagerapplet
    gnome3.gnome-disk-utility
    gnome3.gnome_terminal
    gnome3.nautilus
    gnome3.gnome_session
    gnome3.gnome-tweak-tool
    pavucontrol
    evince
    mplayer
    scrot
    dropbox
    firefox
    flashplayer
    pidgin-with-plugins
    libreoffice
    nodejs
    xlibs.xmodmap
    cabal2nix
    gdb
    looking-glass-client
    ddcutil
    hicolor-icon-theme
    gnome3.adwaita-icon-theme
    gnome3.defaultIconTheme
    win10-nvme-up
    win10-nvme-sleep
    win10-nvme-down
    lorri
    entr

    (pkgs.haskellPackages.ghcWithPackages (self : [
        self.mtl
        self.xmonad
        self.taffybar
        self.cabal-install
    ]))
  ];
}
