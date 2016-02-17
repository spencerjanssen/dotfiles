
{ pkgs, ...}:
{
    systemd.services.backup_home = {
        description = "Update nix channel and build system";
        path = [ pkgs.btrfsProgs pkgs.coreutils ];
        serviceConfig = {
            Type = "oneshot";
            User = "root";
            ExecStart = ''
                /bin/sh -c "${pkgs.btrfsProgs}/bin/btrfs subvolume snapshot -r /media/ssd/@home /media/ssd/@snapshots/home/$(${pkgs.coreutils}/bin/date --iso-8601=minutes)"
            '';
        };
        startAt = "05:00";
    };
}
