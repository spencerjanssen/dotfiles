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
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixGL = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, agenix, NixVirt, lanzaboote, nixGL }:
    let
      lib = nixpkgs.lib;
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
              nixpkgs.legacyPackages.${system}.nh
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
            nixpkgs.overlays = lib.attrValues self.outputs.overlays;
          };
        home-assistant-os = ./nixos/home-assistant-os/module.nix;
      };
      nixosConfigurations = {
        ungoliant = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            home-manager.nixosModules.home-manager
            agenix.nixosModules.age
            lanzaboote.nixosModules.lanzaboote
            self.nixosModules.registry
            self.nixosModules.personalOverlays
            ./nixos/me/secret-ssh-config.nix
            ./nixos/machines/ungoliant/config.nix
          ];
          specialArgs = { inherit inputs; };
        };
        mithlond = lib.nixosSystem {
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
      checks =
        let
          foldRecursiveUpdate = lib.foldl' lib.attrsets.recursiveUpdate { };
          mkSystemCheck = name: config: {
            ${config.config.nixpkgs.system}.${name} = config.config.system.build.toplevel;
          };
          mkHomeCheck = name: config: {
            ${config.pkgs.system}.${name} = config.activationPackage;
          };
          mapAttrValues = f: lib.mapAttrs (_name: value: f value);
          mapAttrName = f: lib.mapAttrs' (name: value: { name = f name; value = value; });
          systemsAndHomes = foldRecursiveUpdate (
            (lib.mapAttrsToList mkSystemCheck self.nixosConfigurations)
            ++
            (lib.mapAttrsToList mkHomeCheck self.homeConfigurations)
          );
        in
        foldRecursiveUpdate [
          (mapAttrValues (mapAttrName (name: "devShell-${name}")) self.devShells)
          (mapAttrValues (mapAttrName (name: "package-${name}")) self.packages)
          (lib.mapAttrs
            (system: sh: {
              all-systems-and-homes =
                nixpkgs.legacyPackages.${system}.linkFarm
                  "systems-and-homes-${system}"
                  sh;
            })
            systemsAndHomes)
        ]
      ;
    };
}
