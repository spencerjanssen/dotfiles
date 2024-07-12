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
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    NixVirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, agenix, NixVirt, lanzaboote }:
    let
      mkDevShell = system:
        nixpkgs.legacyPackages.${system}.mkShell {
          buildInputs =
            [
              nixpkgs.legacyPackages.${system}.nixpkgs-fmt
              nixpkgs.legacyPackages.${system}.treefmt
              nixpkgs.legacyPackages.${system}.nodePackages.prettier
              nixpkgs.legacyPackages.${system}.nil
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
    in
    {
      devShells.aarch64-linux.default = mkDevShell "aarch64-linux";
      devShells.x86_64-linux.default = mkDevShell "x86_64-linux";
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
        channel = { ... }:
          {
            nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
          };
        registry = { ... }:
          {
            nix.registry = {
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
        personalOverlays = { ... }:
          {
            nixpkgs.overlays = nixpkgs.lib.attrValues self.outputs.overlays;
          };
        home-assistant-os = ./nixos/home-assistant-os/module.nix;
      };
      nixosConfigurations = {
        ungoliant = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            home-manager.nixosModules.home-manager
            agenix.nixosModules.age
            self.nixosModules.channel
            self.nixosModules.registry
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
            NixVirt.nixosModules.default
            lanzaboote.nixosModules.lanzaboote
            self.nixosModules.channel
            self.nixosModules.registry
            self.nixosModules.personalOverlays
            self.nixosModules.home-assistant-os
            ./me/secret-ssh-config.nix
            ./machines/mithlond
          ];
          specialArgs = { inherit inputs; };
        };
      };
      homeConfigurations.work-hm = home-manager.lib.homeManagerConfiguration {
        modules = [
          ./nixos/home-manager/general-shell.nix
          ./nixos/home-manager/zsh.nix
          self.nixosModules.registry
          self.nixosModules.personalOverlays
          {
            home = {
              file.".ssh/config".text = ''
                Include /home/sjanssen/.ssh/extra-config
              '';
              sessionPath = [ "/home/sjanssen/.local/bin" "/home/sjanssen/.ghcup/bin" ];
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
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
      };
      hydraJobs = {
        ungoliant = self.lib.hydraJobsFromSystem self.nixosConfigurations.ungoliant;
        mithlond = self.lib.hydraJobsFromSystem self.nixosConfigurations.mithlond;
        work-hm = self.homeConfigurations.work-hm.activationPackage;
        devShell-aarch64-linux = self.devShells.aarch64-linux.default;
        devShell-x86_64-linux = self.devShells.x86_64-linux.default;
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
