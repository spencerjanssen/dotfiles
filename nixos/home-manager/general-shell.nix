{ pkgs, ... }:
{
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
    enableLightTheme = true;
  };
}
