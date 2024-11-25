{ config, ... }:

{
  services.nix-serve = {
    enable = true;
    secretKeyFile = config.age.secrets.nix-serve.path;
  };
  age.secrets.nix-serve = {
    file = ../../secrets/nix-serve-${config.networking.hostName}.age;
    owner = "nix-serve";
    group = "nix-serve";
  };
}
