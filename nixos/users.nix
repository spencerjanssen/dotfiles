{ config, pkgs, ... }:

{
  programs.zsh.enable = true;

  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  users.extraUsers.sjanssen = {
    isNormalUser = true;
    uid = 1000;
    group = "sjanssen";
    extraGroups = ["wheel" "networkmanager"];
    shell = "/run/current-system/sw/bin/zsh";
  };
  users.extraGroups.sjanssen = {
    gid = 1000;
  };
}
