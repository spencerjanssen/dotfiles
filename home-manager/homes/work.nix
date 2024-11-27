{ dotfiles, ... }:
{
  imports = [
    ../modules/general-shell.nix
    ../modules/zsh.nix
    dotfiles.nixosModules.nixpkgsFromFlake
    dotfiles.nixosModules.registry
    dotfiles.nixosModules.personalOverlays
  ];
  home = {
    file.".ssh/config".text = ''
      Include /home/sjanssen/.ssh/extra-config
    '';
    sessionPath = [ "$HOME/.local/bin" "$HOME/.ghcup/bin" "$HOME/.dotnet/tools" ];
    homeDirectory = "/home/sjanssen";
    username = "sjanssen";
  };
  programs = {
    zsh.profileExtra = ''
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
    '';
    gh = {
      enable = true;
    };
    git = {
      enable = true;
      userName = "Spencer Janssen";
      extraConfig = {
        user = {
          useConfigOnly = true;
        };
        pull = {
          ff = "only";
        };
        push = {
          autoSetupRemote = true;
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
