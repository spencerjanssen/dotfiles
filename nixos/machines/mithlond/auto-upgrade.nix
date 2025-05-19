{ ... }:
{
  system.autoUpgrade = {
    enable = true;
    flake = "github:spencerjanssen/dotfiles";
    allowReboot = true;
    # 04:40 is the default. Explicitly written out to ensure it's within the reboot window.
    dates = "04:40";
    rebootWindow = {
      lower = "00:00";
      upper = "06:00";
    };
  };
}
