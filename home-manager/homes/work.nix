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
    sessionPath = [ "$HOME/.local/bin" "$HOME/.ghcup/bin" ];
    homeDirectory = "/home/sjanssen";
    username = "sjanssen";
  };
  programs.zsh.profileExtra = ''
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
  '';
}
