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
    };

    shellAliases = {
      vi = "vim";
    };
    sessionVariables = {
      EDITOR = "vim";
      COMPLETION_WAITING_DOTS = "true";
    };
  };
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      time = { disabled = false; };
      direnv = { disabled = false; };
    };
  };
}
