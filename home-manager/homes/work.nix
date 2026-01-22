{ dotfiles, pkgs, ... }:
{
  imports = [
    ../modules/general-shell.nix
    ../modules/zsh.nix
    ../modules/allow-unfree.nix
    ../modules/nh.nix
    ../modules/nixgl.nix
    ../modules/cache.nix
    dotfiles.nixosModules.nixpkgsFromFlake
    dotfiles.nixosModules.registry
    dotfiles.nixosModules.personalOverlays
  ];
  targets.genericLinux.enable = true;
  home = {
    file.".ssh/config".text = ''
      Include /home/sjanssen/.ssh/extra-config
    '';
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.ghcup/bin"
      "$HOME/.dotnet/tools"
      "$HOME/.cabal/bin"
    ];
    homeDirectory = "/home/sjanssen";
    username = "sjanssen";
  };
  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 5d";
    };
  };
  programs = {
    zsh.profileExtra = ''
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
    '';
    gh = {
      enable = true;
      gitCredentialHelper.enable = true;
      extensions = [ pkgs.gh-actions-cache ];
    };
    git = {
      enable = true;
      settings = {
        user = {
          name = "Spencer Janssen";
          useConfigOnly = true;
        };
        pull = {
          ff = "only";
        };
        push = {
          autoSetupRemote = true;
        };
        branch = {
          autoSetupMerge = "simple";
        };
      };
      includes = [
        {
          condition = "hasconfig:remote.*.url:https://github.com/MasterWordServices/**";
          contents = {
            user = {
              email = "sjanssen@masterword.com";
            };
          };
        }
        {
          condition = "hasconfig:remote.*.url:https://github.com/spencerjanssen/**";
          contents = {
            user = {
              email = "spencerjanssen@gmail.com";
            };
          };
        }
      ];
    };
  };
}
