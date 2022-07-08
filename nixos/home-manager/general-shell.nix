{ pkgs, ... }:
{
  home.stateVersion = "22.05";

  programs.ssh = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.tmux = {
    enable = true;
    shortcut = "a";
    baseIndex = 1;
  };

  home.packages = with pkgs; [
    nix-prefetch-scripts
    zip
    unzip
  ];

  home.file.".haskeline".text = "editMode: Vi";
  home.file.".inputrc".text = "set editing-mode vi";

  programs.mcfly = {
    enable = true;
    enableZshIntegration = true;
    keyScheme = "vim";
  };

  # see https://github.com/nix-community/home-manager/issues/1262
  manual.manpages.enable = false;
}
