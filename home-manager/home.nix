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
}
