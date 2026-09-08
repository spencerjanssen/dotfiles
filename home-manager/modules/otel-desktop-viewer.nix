{ pkgs, ... }:
{
  systemd.user.services.otel-desktop-viewer = {
    Unit = {
      Description = "otel-desktop-viewer";
    };
    Service = {
      ExecStart = "${pkgs.otel-desktop-viewer}/bin/otel-desktop-viewer";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
