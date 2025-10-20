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
      direnv = {
        disabled = false;
        format = "[$symbol$loaded]($style) ";
        loaded_msg = "️✔";
        unloaded_msg = "✘";
      };
      nix_shell.format = "[$symbol]($style)";
      haskell.disabled = true;
      git_branch.format = "[$symbol$branch]($style) ";
      git_metrics.disabled = false;
      directory = {
        truncate_to_repo = false;
        fish_style_pwd_dir_length = 1;
        before_repo_root_style = "dimmed";
        repo_root_style = "cyan";
      };
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[✗](bold red)";
      };
      status = {
        disabled = false;
        format = "[\\[$common_meaning$signal_name$maybe_int\\]]($style) ";
      };
    };
  };
}
