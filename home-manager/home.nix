{ config, pkgs, ... }:

let secrets = import ./secrets.nix;
in
{
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
    matchBlocks = secrets.sshHosts;
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
  ];
}
