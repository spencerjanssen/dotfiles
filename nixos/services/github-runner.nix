{ config, ... }:
{
  services.github-runners.dotfiles-builder = {
    enable = true;
    ephemeral = true;
    url = "https://github.com/spencerjanssen/dotfiles";
    extraLabels = [ "dotfiles-builder" ];
    replace = true;
    tokenFile = config.age.secrets.dotfiles-builder-github-token.path;
    # remove when https://github.com/NixOS/nixpkgs/pull/524856 lands in nixos-unstable:
    nodeRuntimes = [ "node24" ];
  };
  age.secrets = {
    dotfiles-builder-github-token.file = ../../secrets/dotfiles-builder-github-token.age;
  };
}

