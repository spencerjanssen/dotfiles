{ pkgs, ...}:

{
#     systemd.services.flexget =
#     let myflexget = (pkgs.lib.overrideDerivation pkgs.pythonPackages.flexget (attrs: {
#             propagatedBuildInputs = [pkgs.pythonPackages.deluge pkgs.deluge ];
#         }));
#     in {
#         wantedBy = [ "multi-user.target" ];
#         after = [ "network.target" "local-fs.target" "deluge.service"];
#         description = "flexget";
#         path = [ myflexget
#             pkgs.pythonPackages.deluge
#             pkgs.deluge
#             ];
#         serviceConfig = {
#             Type = "simple";
#             User = "sjanssen";
#             ExecStart = ''${myflexget}/bin/flexget daemon start'';
#             ExecStop = ''${myflexget}/bin/flexget daemon stop''; 
#             ExecReload = ''${myflexget}/bin/flexget daemon reload'';
#         };
#     };

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
