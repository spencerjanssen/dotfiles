
{ config, pkgs, ... }:

{
  services.dbus.enable = true;
  services.dbus.packages = [ pkgs.gnome3.dconf ];
  programs.dconf.enable = true;
  services.udisks2.enable = true;
  services.printing.enable = true;

  hardware.pulseaudio.enable = true;

  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.desktopManager.gnome3.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.displayManager.defaultSession = "gnome";

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
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
    gnome3.gnome_settings_daemon
    gnome3.gsettings_desktop_schemas
  ];
}
