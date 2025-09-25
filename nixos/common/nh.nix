{ ... }:
{
  programs.nh = {
    enable = true;
    flake = "github:spencerjanssen/dotfiles";
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d";
      dates = "weekly";
    };
  };
}
