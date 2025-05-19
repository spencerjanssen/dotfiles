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

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      keymap_mode = "auto";
      filter_mode = "directory";
    };
  };
}
