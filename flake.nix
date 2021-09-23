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
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, agenix, ...}: {
    nixosModules = {
      channelAndRegistry = {...}:
      {
        nix = {
          nixPath = ["nixpkgs=${nixpkgs}"];
          registry = {
            built-nixpkgs = {
              flake = nixpkgs;
            };
            built-dotfiles = {
              flake = self;
            };
            dotfiles = {
              to = {
                owner = "spencerjanssen";
                repo = "dotfiles";
                type = "github";
              };
            };
          };
        };
      };
    };
    nixosConfigurations = {
      ungoliant = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          agenix.nixosModules.age
          self.nixosModules.channelAndRegistry
          ./me/secret-ssh-config.nix
          ./nixos/ungoliant/config.nix
        ];
        specialArgs = { inherit inputs; };
      };
      imladris = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          self.nixosModules.channelAndRegistry
          ./nixos/imladris/configuration.nix
        ];
        specialArgs = { inherit inputs; };
      };
    };
    hydraJobs = {
      imladris = self.lib.hydraJobsFromSystem self.nixosConfigurations.imladris;
      ungoliant = self.lib.hydraJobsFromSystem self.nixosConfigurations.ungoliant;
    };
    packages = {
      x86_64-linux = {
        work-hm = (home-manager.lib.homeManagerConfiguration {
          configuration = {
            imports = [
              ./nixos/home-manager/general-shell.nix
              ./nixos/home-manager/zsh.nix
            ];
          };
          system = "x86_64-linux";
          homeDirectory = "/home/sjanssen";
          username = "sjanssen";
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        }).activationPackage;
      };
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
