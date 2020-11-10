# borrowed from https://github.com/Baughn/machine-config/blob/master/modules/zrepl.nix
{ config, pkgs, lib, ... }:

let cfg = config.services.zrepl;
    settingsFormat = pkgs.formats.yaml {};
in {
  options = {
    services.zrepl = with lib; with types; {
        enable = mkEnableOption "zrepl";

        package = mkOption {
          description = "zrepl package";
          defaultText = "pkgs.zrepl";
          type = package;
          default = pkgs.callPackage ../zrepl {};
        };
        settings = mkOption {
          type = settingsFormat.type;
          default = {};
          description = ''
            Configuration for zrepl.  See <link xlink:href="https://zrepl.github.io/"/>
            for supported settings.
          '';
        };
      };
  };

  ### Implementation ###

  config = 

  lib.mkIf cfg.enable {
    environment.etc."zrepl.yml".source = settingsFormat.generate "zrepl.yml" cfg.settings;

    systemd.services.zrepl = {
      enable = cfg.enable;

      description = "ZFS Replication";
      documentation = [ "https://zrepl.github.io/" ];

      requires = [ "local-fs.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
      };

      path = [ cfg.package pkgs.zfs ];
      script = ''
        set -e

        HOME=/var/spool/zrepl

        # Create the directories, if needed.
        mkdir -pm 0770 $HOME /var/run/zrepl
        chown root $HOME /var/run/zrepl

        cd $HOME

        # Ensure ownership and permissions
        chown -R root:root $HOME
        chmod -R o= $HOME

        # Start the daemon.
        exec zrepl --config=/etc/zrepl.yml daemon
      '';
    };

    environment.systemPackages = [
      (pkgs.callPackage ../zrepl {})
    ];
  };
}
