{ config, pkgs, ... }:

{
  services.samba = {
    enable = true;
    shares = {
      homes = {
        comment = "Home Directories";
        browseable = "yes";
        "valid users" = "%S";
        path = "/home/%S";
      };
      tv = {
        comment = "TV";
        path = "/media/tb/@tv";
        "read only" = "yes";
        browseable = "yes";
        "guest only" = "no";
        "guest ok" = "yes";
      };
    };
    syncPasswordsByPam = true;
    extraConfig = ''
    guest account = nobody
    invalid users = root
    map to guest = bad user
    '';
  };
}
