{
  description = "spencerjanssen's configs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, agenix, ...}: {
    legacyPackages.linux-x86_64.hello = nixpkgs.hello;
    nixosConfigurations = {
      ungoliant = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          agenix.nixosModules.age
          ./me/secret-ssh-config.nix
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
      imladris = self.lib.hydraJobsFromSystem self.nixosConfigurations.imladris;
      ungoliant = self.lib.hydraJobsFromSystem self.nixosConfigurations.ungoliant;
    };
    lib = {
      allSystemPackages = system: builtins.listToAttrs (map (p: {name = (builtins.parseDrvName p.name).name; value = p;}) system.config.environment.systemPackages);
      hydraJobsFromSystem = system: {
        toplevel = system.config.system.build.toplevel;
        kernel = system.config.system.build.kernel;
      } // self.lib.allSystemPackages system;
    };
  };
}
