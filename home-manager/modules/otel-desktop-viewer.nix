{ pkgs, ... }:
{
  systemd.user.services.otel-desktop-viewer = {
    Unit = {
      Description = "otel-desktop-viewer";
    };
    Service = {
      ExecStart = "${pkgs.otel-desktop-viewer}/bin/otel-desktop-viewer --open-browser=false --db %C/otel-desktop-viewer/otel-desktop-viewer.db --db-max-size=512MB";
      Restart = "on-failure";
      CacheDirectory = "otel-desktop-viewer";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
