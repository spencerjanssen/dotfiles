{ pkgs, ... }:

{
  home.keyboard.options = [ "caps:escape" ];

  xsession = {
    enable = true;
    preferStatusNotifierItems = true;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;

      config = pkgs.writeText "xmonad.hs" (builtins.readFile ./../../xmonad.hs);

      extraPackages = haskellPackages: [
        haskellPackages.xmonad-contrib
      ];
    };
    pointerCursor = {
      defaultCursor = "left_ptr";
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.gnome-themes-extra;
      name = "Adwaita-dark";
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  services.network-manager-applet.enable = true;

  xsession.initExtra = ''
    autorandr --skip-options=gamma --load both_monitors
  '';

  services.polybar = {
    enable = true;
    script = ''
      export TRAY_POSITION=right
      echo starting
      for m in $(polybar --list-monitors | ${pkgs.coreutils}/bin/cut -d":" -f1 | ${pkgs.coreutils}/bin/sort); do
        export MONITOR=$m
        echo $m
        polybar example &
        TRAY_POSITION=none
      done
    '';
    extraConfig = builtins.readFile ../../polybar_config;
  };

  services.redshift.enable = true;
  services.redshift.latitude = "40.741";
  services.redshift.longitude = "-96.64";

  services.screen-locker.enable = true;
  services.screen-locker.lockCmd = "${pkgs.i3lock}/bin/i3lock -n";

  services.pulseeffects.enable = true;
  services.pulseeffects.package = pkgs.pulseeffects-legacy;

  services.udiskie = {
    enable = true;
    notify = true;
    automount = true;
    tray = "always";
  };

  fonts.fontconfig.enable = true;
}
