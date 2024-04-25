{ pkgs, config, ... }:
{
  environment.systemPackages = [
    pkgs.zrepl
  ];
  age.secrets = {
    zrepl-mithlond-crt.file = ../../secrets/zrepl-mithlond.crt.age;
    zrepl-mithlond-key.file = ../../secrets/zrepl-mithlond.key.age;
    zrepl-ungoliant-crt.file = ../../secrets/zrepl-ungoliant.crt.age;
  };
  services.zrepl =
    let
      amanLocal = {
        type = "local";
        listener_name = "local-aman-listener";
        client_identity = "mithlond";
        dial_timeout = "2s";
      };
      snapshotPrefix = "zrepl_";
      prefixRegex = "^${snapshotPrefix}.*";
      keepNotReplicated = {
        type = "not_replicated";
      };
      keepNotZrepl = {
        type = "regex";
        negate = true;
        regex = "^${snapshotPrefix}.*";
      };
    in
    {
      enable = true;
      settings = {
        global = {
          monitoring = [{
            type = "prometheus";
            listen = "127.0.0.1:9811";
          }];
        };
        jobs = [
          {
            name = "ungoliant-sink";
            type = "sink";
            root_fs = "aman/backups";
            serve = {
              type = "tls";
              listen = ":9341";
              ca = config.age.secrets.zrepl-ungoliant-crt.path;
              cert = config.age.secrets.zrepl-mithlond-crt.path;
              key = config.age.secrets.zrepl-mithlond-key.path;
              client_cns = [ "ungoliant" ];
            };
          }
          {
            name = "aman-local-sink";
            type = "sink";
            root_fs = "aman/local-backups";
            recv.placeholder.encryption = "off";
            serve = {
              type = "local";
              listener_name = "local-aman-listener";
            };
          }
          {
            name = "mithlond-system-to-aman";
            type = "push";
            connect = amanLocal;
            filesystems = {
              "mithlond/system<" = true;
            };
            send.encrypted = true;
            snapshotting = {
              type = "periodic";
              prefix = snapshotPrefix;
              interval = "10m";
            };
            pruning = {
              keep_sender = [
                keepNotReplicated
                keepNotZrepl
                {
                  type = "grid";
                  grid = "1x1h(keep=all) | 24x1h | 30x1d | 144x30d";
                  regex = prefixRegex;
                }
              ];
              keep_receiver = [
                keepNotZrepl
                {
                  type = "grid";
                  grid = "1x1h(keep=all) | 24x1h | 30x1d | 144x30d";
                  regex = prefixRegex;
                }
              ];
            };
          }
        ];
      };
    };
}
