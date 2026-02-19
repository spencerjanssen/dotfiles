{ config, ... }:
{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        domain = "mithlond.lan";
        http_addr = "0.0.0.0";
      };
      security.secret_key = "$__file{${config.age.secrets.grafana-secret-key.path}}";
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
  age.secrets = {
    grafana-secret-key = {
      file = ../../secrets/grafana-secret-key.age;
      owner = config.systemd.services.grafana.serviceConfig.User;
    };
  };
}
