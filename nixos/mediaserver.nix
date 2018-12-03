{ config, pkgs, ... }:

{
    services.plex.enable = true;
    services.deluge.enable = true;

    services.flexget = {
        enable = true;
        user = "flexget";
        homeDir = "/var/lib/flexget";
        config = builtins.readFile ../flexget/config.yml;
        systemScheduler = false;
    };

    users.users.flexget = {
        home = "/var/lib/flexget";
        createHome = true;
    };

    users.groups.television.members = [
        "sjanssen"
        "plex"
        "deluge"
        "flexget"
    ];

    systemd.services.blockvpn = {
        description = "prevent media users from using tun0";
        path = [pkgs.iptables];
        script = ''
            for i in deluge plex flexget
            do
                iptables -A OUTPUT -o tun0 -m owner --uid-owner $i -j DROP
            done
        '';
        wantedBy = ["multi-user.target"];
    };
}