{ config, ... }:

{
  services.harmonia = {
    enable = true;
    signKeyPaths = [ config.age.secrets.harmonia.path ];
  };
  age.secrets.harmonia = {
    file = ../../secrets/nix-serve-${config.networking.hostName}.age;
  };
}
