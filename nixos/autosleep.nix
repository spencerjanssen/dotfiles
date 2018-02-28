{ pkgs, ...}:

{
    systemd.services.autosleep =
    {
        description = "scheduled sleep";
        path = [pkgs.systemd];
        script = ''${pkgs.systemd}/bin/systemctl suspend'';
    };

    systemd.timers.autosleep =
    {
        description = "scheduled sleep";
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = "*-*-* 00:00";
        };
    };

    systemd.services.autowake =
    {
        description = "scheduled wake";
        script = ''echo 'scheduled wake up' '';
    };

    systemd.timers.autowake =
    {
        description = "scheduled wake";
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = "*-*-* 19:00";
          WakeSystem = true;
        };
    };

}
