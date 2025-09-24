{ pkgs, ... }:
{
  nix = {
    package = pkgs.nix;
    settings = {
      extra-trusted-substituters = [ "https://cache.nixos.org" ];
      substituters = [ "http://192.168.86.37:8501" ];
      extra-trusted-public-keys = [ "mithlond.lan-1:dnJ/CK6UiqB9XwEC9k/Sigw06f7JTUCpfPuqTVfyLDw" ];
    };
  };
}
