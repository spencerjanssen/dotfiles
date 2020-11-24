{
  description = "spencerjanssen's configs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ nixpkgs, ...}: {
    nixosConfigurations = {
      ungoliant = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixos/ungoliant/config.nix
        ];
        specialArgs = { inherit inputs; };
      };
    };
  };
}
