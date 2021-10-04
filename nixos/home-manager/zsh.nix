{pkgs, ...}:
{
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
    sessionVariables = {
      EDITOR = "vim";
      COMPLETION_WAITING_DOTS = "true";
    };
  };
}
