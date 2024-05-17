{ config, ... }:
{
  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "mithlond";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
          }
        ];
      }
      {
        job_name = "zrepl";
        static_configs = [
          {
            targets = [ (builtins.head config.services.zrepl.settings.global.monitoring).listen ];
          }
        ];
      }
      {
        job_name = "hydra-queue-runner";
        static_configs = [
          {
            targets = [ "127.0.0.1:9198" ];
          }
        ];
      }
      {
        job_name = "hydra-notify";
        static_configs = [
          {
            targets = [ "127.0.0.1:9199" ];
          }
        ];
      }
      {
        job_name = "hydra";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString config.services.hydra.port}" ];
          }
        ];
      }
    ];
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
      };
    };
  };
}
