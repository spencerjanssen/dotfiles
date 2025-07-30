{ config, ... }:
{
  users.groups.dotfiles-builder = { };
  services.github-runners.dotfiles-builder = {
    enable = true;
    ephemeral = true;
    url = "https://github.com/spencerjanssen/dotfiles";
    extraLabels = [ "dotfiles-builder" ];
    replace = true;
    tokenFile = config.age.secrets.dotfiles-builder-github-token.path;
    serviceOverrides = {
      SupplementaryGroups = [ "dotfiles-builder" ];
    };
  };
  age.secrets = {
    dotfiles-builder-github-token.file = ../../secrets/dotfiles-builder-github-token.age;
  };
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        action.id == "org.freedesktop.systemd1.manage-units" &&
        (action.lookup("unit") == "nixos-upgrade.timer" || action.lookup("unit") == "nixos-upgrade.service") &&
        subject.isInGroup("dotfiles-builder")
      ) {
        return polkit.Result.YES;
      }
    });
  '';
  
  # Allow dotfiles-builder group to run systemctl commands via sudo
  security.sudo.extraRules = [
    {
      groups = [ "dotfiles-builder" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl start nixos-upgrade.service";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl start --wait nixos-upgrade.service";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/etc/nixos/dotfiles/nixos/scripts/trigger-upgrade.sh";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}

