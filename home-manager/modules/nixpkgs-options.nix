{ ... }:
{
  nixpkgs = {
    config = import ./config.nix;
    overlays = import ../../nixos/common/overlays.nix;
  };
}
