{ config, ... }:

{
  services.ncps = {
    enable = true;
    server.addr = ":8501";
    cache = {
      hostName = "mithlond.lan";
      secretKeyPath = config.age.secrets.ncps.path;
      maxSize = "100G";
      lru = {
        schedule = "0 2 * * *";
        scheduleTimeZone = "America/Chicago";
      };
      upstream = {
        urls = [
          "http://127.0.0.1:5000"
          "https://cache.nixos.org"
        ];
        publicKeys = [
          "mithlond.lan-1:dnJ/CK6UiqB9XwEC9k/Sigw06f7JTUCpfPuqTVfyLDw"
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];
      };
    };
  };
  age.secrets.ncps = {
    file = ../../secrets/nix-serve-${config.networking.hostName}.age;
    owner = "ncps";
    group = "ncps";
  };
}
