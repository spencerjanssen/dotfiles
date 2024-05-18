{ config, lib, ... }:
let cfg = config.services.home-assistant-os;
in
{
  options.services.home-assistant-os = {
    enable = lib.mkEnableOption "Home Assistant OS";
  };
  config = lib.mkIf cfg.enable {
    virtualisation.libvirt.enable = true;
    virtualisation.libvirt.connections."qemu:///system".domains = [{
      definition = ./hass.xml;
      active = true;
    }];
  };
}
