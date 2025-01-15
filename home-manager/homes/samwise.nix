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
    homeDirectory = "/home/sjanssen";
    username = "sjanssen";
  };
  programs = {
    zsh.profileExtra = ''
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
    '';
  };
}
