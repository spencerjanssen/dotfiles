{ ... }:
{
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
    sessionVariables = {
      EDITOR = "vim";
      COMPLETION_WAITING_DOTS = "true";
    };
  };
}
