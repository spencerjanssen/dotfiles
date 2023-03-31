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
  };

  outputs = inputs@{ self, nixpkgs, home-manager, agenix, flake-utils, hydra, ... }:
    let
      forSystem = system: {
        packages = {
          work-hm = (home-manager.lib.homeManagerConfiguration {
            modules = [
              ./nixos/home-manager/general-shell.nix
              ./nixos/home-manager/zsh.nix
              {
                home = {
                  file.".ssh/config".text = ''
                    Include /home/sjanssen/.ssh/extra-config
                  '';
                  sessionPath = [ "/home/sjanssen/.local/bin" ];
                  homeDirectory = "/home/sjanssen";
                  username = "sjanssen";
                };
                programs.zsh.profileExtra = ''
                  if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
                    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
                  fi
                '';
              }
            ];
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
                agenix.packages.${system}.agenix
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
    (flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux ] forSystem)
    //
    {
      overlays = {
        patch-hydra = (final: prev: {
          hydra_unstable = prev.hydra_unstable.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [
              ./nixos/patches/hydra-githubstatus-remove-pr.patch
              ./nixos/patches/hydra-mangle-github.patch
            ];
            doCheck = false;
          });
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
        mithlond = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            home-manager.nixosModules.home-manager
            agenix.nixosModules.age
            self.nixosModules.channelAndRegistry
            self.nixosModules.personalOverlays
            ./me/secret-ssh-config.nix
            ./machines/mithlond
          ];
          specialArgs = { inherit inputs; };
        };
      };
      hydraJobs = {
        ungoliant = self.lib.hydraJobsFromSystem self.nixosConfigurations.ungoliant;
        mithlond = self.lib.hydraJobsFromSystem self.nixosConfigurations.mithlond;
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
