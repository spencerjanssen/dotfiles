{ config, pkgs, ... }:

{
    services.plex.enable = false;
    services.deluge.enable = false;

    services.flexget = {
        enable = false;
        user = "flexget";
        homeDir = "/var/lib/flexget";
        config = if config._module.args ? dummyflexget
                    then config._module.args.dummyflexget
                    else (builtins.readFile ../flexget/config.yml);
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