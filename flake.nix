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

  outputs = inputs@{ self, nixpkgs, home-manager, agenix, flake-utils, ...}:
    let forSystem = system: {
          packages = {
              work-hm = (home-manager.lib.homeManagerConfiguration {
                inherit system;
                configuration = {
                  imports = [
                    ./nixos/home-manager/general-shell.nix
                    ./nixos/home-manager/zsh.nix
                  ];
                  home.sessionPath = ["/home/sjanssen/.local/bin"];
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
    };
    in
    (flake-utils.lib.eachDefaultSystem forSystem)
    //
    {
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
      work-hm = self.packages.x86_64-linux.work-hm;
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
