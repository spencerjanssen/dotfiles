{ config, pkgs, ... }:

let matchBlocks =
      if builtins.pathExists ./ssh-matchblocks.nix
        then import ./ssh-matchblocks.nix
        else {};
    # can 'inherit pkgs' here to build against channel's nixpkgs
    # but using pinned nixpkgs lets us take advantage of cachix
    all-hies = import <all-hies> {};
in
{
  # required for hydra
  home.username = "sjanssen";
  home.homeDirectory = "/home/sjanssen";

  nixpkgs = {
    config = import ./config.nix;
    overlays = import ../common/overlays.nix;
  };

  xdg.configFile."nixpkgs/config.nix".source = ./config.nix;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Spencer Janssen";
    userEmail = "spencerjanssen@gmail.com";
    extraConfig = {
      color = {
        ui = "auto";
      };
      push = {
        default = "simple";
      };
    };
  };

  programs.ssh = {
    enable = true;
    inherit matchBlocks;
  };

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "vi-mode"
        "history-substring-search"
        "cabal"
        "screen"
      ];
      theme = "robbyrussell";
    };

    shellAliases = {
      vi = "vim";
    };
    # COMPLETION_WAITING_DOTS is for oh-my-zsh and doesn't really belong here
    sessionVariables = {
      EDITOR = "vim";
      LIBVIRT_DEFAULT_URI = "qemu:///system";
      COMPLETION_WAITING_DOTS = "true";
    };
    initExtra = ''
      bindkey '^R' history-incremental-search-backward
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.tmux = {
    enable = true;
    shortcut = "a";
    baseIndex = 1;
  };

  home.keyboard.options = ["caps:escape"];

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
    nix-prefetch-scripts
    xlibs.xmodmap
    cabal2nix
    gdb
    zip
    unzip
    looking-glass-client
    lorri
    entr
    ddcutil
    hicolor-icon-theme
    gnome3.adwaita-icon-theme
    gnome3.defaultIconTheme
    win10-nvme-up
    win10-nvme-sleep
    win10-nvme-down

    (pkgs.haskellPackages.ghcWithPackages (self : [
        self.mtl
        self.xmonad
        self.taffybar
        self.cabal-install
    ]))
  ];

  home.file.".haskeline".text = "editMode: Vi";
  home.file.".inputrc".text = "set editing-mode vi";
}
