{
  description = "spencerjanssen's configs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-github-runner-node24.url = "github:spencerjanssen/nixpkgs/github-runner-node24";
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
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, agenix, NixVirt, lanzaboote, nixpkgs-github-runner-node24 }:
    let
      formatTools = system: [
        nixpkgs.legacyPackages.${system}.nixpkgs-fmt
        nixpkgs.legacyPackages.${system}.treefmt
        nixpkgs.legacyPackages.${system}.yamlfmt
      ];
      mkTreefmtWrapper = system:
        nixpkgs.legacyPackages.${system}.writeShellApplication {
          name = "treefmt-wrapper";
          runtimeInputs = formatTools system;
          checkPhase = "";
          text = ''
            exec treefmt "$@"
          '';
        };
      mkDevShell = system:
        nixpkgs.legacyPackages.${system}.mkShell {
          buildInputs =
            formatTools system ++
            [
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
      packages.x86_64-linux.treefmt-wrapper = mkTreefmtWrapper "x86_64-linux";
      overlays = { };
      nixosModules = {
        # used for home-manager configurations, on NixOS prefer nixpkgs.flake.setNixPath:
        nixpkgsFromFlake = { ... }:
          {
            nix = {
              nixPath = [ "nixpkgs=${nixpkgs}" ];
              registry = {
                nixpkgs.flake = nixpkgs;
              };
            };
          };
        # for either NixOS or home-manager configurations:
        registry = { ... }:
          {
            nix.registry = {
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
            self.nixosModules.registry
            self.nixosModules.personalOverlays
            ./nixos/me/secret-ssh-config.nix
            ./nixos/machines/ungoliant/config.nix
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
            self.nixosModules.registry
            self.nixosModules.personalOverlays
            self.nixosModules.home-assistant-os
            ./nixos/me/secret-ssh-config.nix
            ./nixos/machines/mithlond
            {
              services.github-runners.dotfiles-builder.package = nixpkgs-github-runner-node24.legacyPackages."x86_64-linux".github-runner;
            }
          ];
          specialArgs = { inherit inputs; };
        };
      };
      homeConfigurations = {
        "sjanssen@samwise" = home-manager.lib.homeManagerConfiguration {
          modules = [ ./home-manager/homes/samwise.nix ];
          pkgs = nixpkgs.legacyPackages."aarch64-linux";
          extraSpecialArgs = { dotfiles = self; };
        };
        "sjanssen@MW-LT-0069" = home-manager.lib.homeManagerConfiguration {
          modules = [ ./home-manager/homes/work.nix ];
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = { dotfiles = self; };
        };
      };
      hydraJobs = {
        ungoliant.toplevel = self.nixosConfigurations.ungoliant.config.system.build.toplevel;
        mithlond.toplevel = self.nixosConfigurations.mithlond.config.system.build.toplevel;
        samwise = self.homeConfigurations."sjanssen@samwise".activationPackage;
        MW-LT-0069 = self.homeConfigurations."sjanssen@MW-LT-0069".activationPackage;
        devShell-aarch64-linux = self.devShells.aarch64-linux.default;
        devShell-x86_64-linux = self.devShells.x86_64-linux.default;
      };
      checks = {
        x86_64-linux = {
          inherit (self.hydraJobs) MW-LT-0069 devShell-x86_64-linux;
          ungoliant = self.hydraJobs.ungoliant.toplevel;
          mithlond = self.hydraJobs.mithlond.toplevel;
        };
        aarch64-linux = {
          inherit (self.hydraJobs) samwise devShell-aarch64-linux;
        };
      };
    };
}
