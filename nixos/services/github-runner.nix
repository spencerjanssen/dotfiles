{ config, ... }:
{
  services.github-runners.dotfiles-builder = {
    enable = true;
    ephemeral = true;
    url = "https://github.com/spencerjanssen/dotfiles";
    extraLabels = [ "dotfiles-builder" ];
    replace = true;
    tokenFile = config.age.secrets.dotfiles-builder-github-token.path;
  };
  age.secrets = {
    dotfiles-builder-github-token.file = ../../secrets/dotfiles-builder-github-token.age;
  };
}

