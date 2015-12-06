{ pkgs, ...}:

{
    systemd.services.flexget =
    let myflexget = (pkgs.lib.overrideDerivation pkgs.python27Packages.flexget (attrs: {
            propagatedBuildInputs = [pkgs.python27Packages.deluge];
        }));
    in {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" "local-fs.target" "deluge.service"];
        description = "flexget";
        path = [ pkgs.python27Packages.flexget
            pkgs.python27Packages.deluge
            pkgs.deluge
            ];
        serviceConfig = {
            Type = "simple";
            User = "sjanssen";
            ExecStart = ''${myflexget}/bin/flexget daemon start'';
            ExecStop = ''${myflexget}/bin/flexget daemon stop''; 
            ExecReload = ''${myflexget}/bin/flexget daemon reload'';
        };
    };

    systemd.services.deluge = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" "local-fs.target"];
        description = "deluge";
        serviceConfig = {
            Type = "simple";
            User = "sjanssen";
            ExecStart = ''${pkgs.deluge}/bin/deluged -d'';
        };
    };

}
