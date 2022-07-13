{ ... }:
{
  system.autoUpgrade = {
    enable = true;
    flake = "github:spencerjanssen/dotfiles";
    allowReboot = true;
  };
}
