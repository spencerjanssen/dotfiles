{ config, pkgs, ... }:

{
  services.dbus.enable = true;
  services.dbus.packages = [ pkgs.dconf ];
  programs.dconf.enable = true;
  services.udisks2.enable = true;
  services.printing.enable = true;

  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.displayManager.defaultSession = "gnome";

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      corefonts
      inconsolata
      ttf_bitstream_vera
      dejavu_fonts
      hasklig
      fira-code
      fira-mono
    ];
  };

  environment.systemPackages = with pkgs; [
    gnome-settings-daemon
    gsettings-desktop-schemas
  ];
}
