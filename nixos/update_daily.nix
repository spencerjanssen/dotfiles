{ pkgs, ...}:
{
    systemd.services.update_nix = {
        description = "Update nix channel and build system";
        serviceConfig = {
            Type = "oneshot";
            User = "root";
            # cd /tmp so that we don't leave a result symlink in an obnoxious
            # location
            ExecStart = ''
                cd /tmp &&
                /run/current-system/sw/bin/nix-channel --update &&
                /run/current-system/sw/bin/nixos-rebuild build
            '';
        };
        startAt = "05:00";
    };
}
