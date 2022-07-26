{ ... }:
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "spencerjanssen@gmail.com";
  };
  services.nginx = {
    enable = true;
    virtualHosts."hydra.spencerjanssen.org" = {
      forceSSL = true;
      enableACME = true;
      locations."/api/push-github" = {
        proxyPass = "http://ungoliant.lan:9000";
      };
      locations."/api/push" = {
        proxyPass = "http://ungoliant.lan:9000";
      };
    };
  };
}
