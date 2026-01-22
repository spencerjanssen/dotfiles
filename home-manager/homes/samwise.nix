{ dotfiles, ... }:
{
  imports = [
    ../modules/general-shell.nix
    ../modules/zsh.nix
    ../modules/nh.nix
    ../modules/nixgl.nix
    ../modules/cache.nix
    dotfiles.nixosModules.nixpkgsFromFlake
    dotfiles.nixosModules.registry
    dotfiles.nixosModules.personalOverlays
  ];
  targets.genericLinux.enable = true;
  home = {
    homeDirectory = "/home/sjanssen";
    username = "sjanssen";
    sessionPath = [ "$HOME/.ghcup/bin" ];
  };
  programs = {
    zsh.profileExtra = ''
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
    '';
  };
}
