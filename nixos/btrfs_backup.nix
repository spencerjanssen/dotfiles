
{ pkgs, ...}:
{
    systemd.services.backup_home = {
        description = "Take a snapshot of @home";
        path = [ pkgs.btrfsProgs pkgs.coreutils ];
        serviceConfig = {
            Type = "oneshot";
            User = "root";
            ExecStart = ''
                /bin/sh -c "${pkgs.btrfsProgs}/bin/btrfs subvolume snapshot -r /media/ssd/@home /media/ssd/@snapshots/home/$(${pkgs.coreutils}/bin/date --iso-8601=minutes)"
            '';
        };
    };

    systemd.timers.backup_home = {
      timerConfig = {
        Persistent = true;
        OnCalendar = "daily";
      };
    };
}
