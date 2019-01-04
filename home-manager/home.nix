{ config, pkgs, ... }:

let matchBlocks =
      if config._module.args ? dummySecrets
        then {}
        else import ./ssh-matchblocks.nix;
    # can 'inherit pkgs' here to build against channel's nixpkgs
    # but using pinned nixpkgs lets us take advantage of cachix
    hie = import <hie> {};
in
{
  # required for hydra
  home.username = "sjanssen";
  home.homeDirectory = "/home/sjanssen";

  nixpkgs = {
    config = import ./config.nix;
    overlays = [ (import ../nixos/ghc-8.6-fixes.nix) ];
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
        "zsh-syntax-highlighting"
      ];
      theme = "robbyrussell";
    };

    shellAliases = {
      vi = "vim";
    };
    # COMPLETION_WAITING_DOTS is for oh-my-zsh and doesn't really belong here
    sessionVariables = {
      EDITOR = "vim";
      LIBVIRT_DEFAULT_URI = "qemu://system";
      COMPLETION_WAITING_DOTS = "true";
    };
    initExtra = ''
      bindkey '^R' history-incremental-search-backward
    '';
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

  services.udiskie = {
    enable = true;
    notify = true;
    automount = true;
    tray = "always";
  };

  home.packages = with pkgs; [
    taffybar
    hie.hies
    nixopsUnstable
    awscli
    nodejs
    vscode
    discord
    remmina
    haskellPackages.status-notifier-item
    stack
    haskellPackages.ghcid
    chromium
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
  ];
}
