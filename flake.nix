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
    flake-utils.url = "github:numtide/flake-utils";
    hydra = {
      # hydra isn't compatible with current nixos-unstable
      url = "github:spencerjanssen/hydra/github-status-more-logging";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, agenix, flake-utils, hydra, ... }:
    let forSystem = system: {
      packages = {
        work-hm = (home-manager.lib.homeManagerConfiguration {
          inherit system;
          configuration = {
            imports = [
              ./nixos/home-manager/general-shell.nix
              ./nixos/home-manager/zsh.nix
            ];
            home.sessionPath = [ "/home/sjanssen/.local/bin" ];
            home.file.".ssh/config".text = ''
              Include /home/sjanssen/.ssh/extra-config
            '';
            programs.zsh.profileExtra = ''
              if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
                . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
              fi
            '';
          };
          homeDirectory = "/home/sjanssen";
          username = "sjanssen";
          pkgs = nixpkgs.legacyPackages.${system};
        }).activationPackage;
      };
      devShells.default =
        nixpkgs.legacyPackages.${system}.mkShell {
          buildInputs =
            [
              nixpkgs.legacyPackages.${system}.nixpkgs-fmt
              nixpkgs.legacyPackages.${system}.treefmt
              nixpkgs.legacyPackages.${system}.nodePackages.prettier
              agenix.defaultPackage.${system}
              (nixpkgs.legacyPackages.${system}.writeShellApplication {
                name = "watch-check";
                runtimeInputs = [
                  nixpkgs.legacyPackages.${system}.entr
                ];
                text = ''
                  while git ls-files | entr -d -c sh -c 'nix flake check' ; [ $? -eq 2 ]; do
                      echo file added or removed, restarting
                      sleep 0.1s
                  done
                '';
              })
            ];
        };
    };
    in
    (flake-utils.lib.eachDefaultSystem forSystem)
    //
    {
      overlays = {
        hydra-master = (final: prev: {
          hydra-master = hydra.defaultPackage.${final.stdenv.system};
        });
      };
      nixosModules = {
        channelAndRegistry = { ... }:
          {
            nix = {
              nixPath = [ "nixpkgs=${nixpkgs}" ];
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
        personalOverlays = { ... }:
          {
            nixpkgs.overlays = nixpkgs.lib.attrValues self.outputs.overlays;
          };
      };
      nixosConfigurations = {
        ungoliant = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            home-manager.nixosModules.home-manager
            agenix.nixosModules.age
            self.nixosModules.channelAndRegistry
            self.nixosModules.personalOverlays
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
            self.nixosModules.personalOverlays
            ./nixos/imladris/configuration.nix
            ./services/hydra-proxy.nix

          ];
          specialArgs = { inherit inputs; };
        };
      };
      hydraJobs = {
        ungoliant = self.lib.hydraJobsFromSystem self.nixosConfigurations.ungoliant;
        work-hm = self.packages.x86_64-linux.work-hm;
        devShell = self.devShells.x86_64-linux.default;
      };
      lib = {
        allSystemPackages = system: builtins.listToAttrs (map (p: { name = (builtins.parseDrvName p.name).name; value = p; }) system.config.environment.systemPackages);
        hydraJobsFromSystem = system: {
          toplevel = system.config.system.build.toplevel;
          kernel = system.config.system.build.kernel;
        } // self.lib.allSystemPackages system;
      };
    };
}
