{ config, ... }:
{
  services.grafana = {
    enable = true;
    settings.server = {
      domain = "mithlond.lan";
      http_addr = "0.0.0.0";
    };
    provision = {
      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://127.0.0.1:${toString config.services.prometheus.port}";
          }
        ];
      };
    };
  };
}
