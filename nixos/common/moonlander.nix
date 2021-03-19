{ pkgs, ... }:
{
  services.udev.packages = [
    (
      pkgs.writeTextFile {
        name = "moonlander-udev-rules";
        text = ''
          SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="1969", TAG+="uaccess"
        '';
        destination = "/etc/udev/rules.d/50-zsa-moonlander.rules";
      }
    )
  ];
  environment.systemPackages = with pkgs; [
    wally-cli
  ];
}
