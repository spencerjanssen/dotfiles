{ ... }:
{
  nixpkgs = {
    config = import ./config.nix;
    overlays = import ../common/overlays.nix;
  };
}
