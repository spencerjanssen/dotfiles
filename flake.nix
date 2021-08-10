{
  description = "spencerjanssen's configs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ...}: {
    legacyPackages.linux-x86_64.hello = nixpkgs.hello;
    nixosConfigurations = {
      ungoliant = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./nixos/ungoliant/config.nix
        ];
        specialArgs = { inherit inputs; };
      };
      imladris = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./nixos/imladris/configuration.nix
        ];
        specialArgs = { inherit inputs; };
      };
    };
    hydraJobs = {
      ungoliant = self.nixosConfigurations.ungoliant.config.system.build.toplevel;
      ungoliantx.linux-x86_64 = self.nixosConfigurations.ungoliant.config.system.build.toplevel;
    };
  };
}
