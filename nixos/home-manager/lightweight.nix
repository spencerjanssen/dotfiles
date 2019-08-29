{ pkgs, ... }:

let matchBlocks =
      if builtins.pathExists ./ssh-matchblocks.nix
        then import ./ssh-matchblocks.nix
        else {};
    # can 'inherit pkgs' here to build against channel's nixpkgs
    # but using pinned nixpkgs lets us take advantage of cachix
in
{
  nixpkgs = {
    config = import ./config.nix;
    overlays = import ../common/overlays.nix;
  };

  xdg.configFile."nixpkgs/config.nix".source = ./config.nix;

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
      custom = builtins.toPath (pkgs.callPackage ./oh-my-zsh-custom.nix {});
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

  home.packages = with pkgs; [
    nix-prefetch-scripts
    zip
    unzip
  ];

  home.file.".haskeline".text = "editMode: Vi";
  home.file.".inputrc".text = "set editing-mode vi";
}
