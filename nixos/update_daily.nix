{ pkgs, ...}:
{
    systemd.services.update_nix = {
        description = "Update nix channel and build system";
        path = [ pkgs.nix ];
        serviceConfig = {
            Type = "oneshot";
            User = "root";
            # cd /tmp so that we don't leave a result symlink in an obnoxious
            # location
            ExecStart = ''
                /bin/sh -c "${pkgs.nix}/bin/nix-channel --update" ; \
                /bin/sh -c "/run/current-system/sw/bin/nixos-rebuild build"
            '';
            Environment = "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt NIX_PATH=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=/etc/nixos/configuration.nix:/nix/var/nix/profiles/per-user/root/channels";
        };
        startAt = "05:00";
    };
}
