{ pkgs, ... }:
{
  users.users.remote-builder = {
    isNormalUser = false;
    isSystemUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICq4z9ma4Bnysw+DT96zw18Qx9wS6+lKIkawrC19Ybxx remote-builder"
    ];
    shell = pkgs.bashInteractive;
    group = "remote-builder";
  };
  users.groups.remote-builder = { };
  nix.settings.trusted-users = [ "remote-builder" ];
}
