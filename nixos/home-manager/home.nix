{ pkgs, ... }:

let all-hies = import <all-hies> {};
in
{
  imports = [ ./lightweight.nix ];
  # required for hydra
  home.username = "sjanssen";
  home.homeDirectory = "/home/sjanssen";

  xdg.configFile."nixpkgs/config.nix".source = ./config.nix;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh = {
    sessionVariables = {
      LIBVIRT_DEFAULT_URI = "qemu:///system";
    };
  };

  xsession = {
    enable = true;
    preferStatusNotifierItems = true;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;

      extraPackages = haskellPackages: [
        haskellPackages.xmonad-contrib
      ];
    };
    pointerCursor = {
      defaultCursor = "left_ptr";
      package = pkgs.gnome3.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };
  };

  services.network-manager-applet.enable = true;

  programs.autorandr = {
    enable = true;
    hooks.postswitch.polybar = ''
      systemctl --user restart polybar.service
    '';
    profiles = {
      "both_monitors" = {
        fingerprint = {
          DisplayPort-0 = "00ffffffffffff0010acb8a04c33313132190104a53420783a0495a9554d9d26105054a54b00714f8180a940d1c0d100010101010101283c80a070b023403020360006442100001e000000ff0050564a56573543413131334c0a000000fc0044454c4c2055323431350a2020000000fd00313d1e5311000a202020202020010302031cf14f9005040302071601141f12132021222309070783010000023a801871382d40582c450006442100001e011d8018711c1620582c250006442100009e011d007251d01e206e28550006442100001e8c0ad08a20e02d10103e96000644210000180000000000000000000000000000000000000000000000000000000c";
          DisplayPort-1 = "00ffffffffffff0010acb8a0534d4631271a0104a53420783a0495a9554d9d26105054a54b00714f8180a940d1c0d100010101010101283c80a070b023403020360006442100001e000000ff00434656394e36394931464d530a000000fc0044454c4c2055323431350a2020000000fd00313d1e5311000a20202020202001d902031cf14f9005040302071601141f12132021222309070783010000023a801871382d40582c450006442100001e011d8018711c1620582c250006442100009e011d007251d01e206e28550006442100001e8c0ad08a20e02d10103e96000644210000180000000000000000000000000000000000000000000000000000000c";
        };
        config = {
          DisplayPort-2 = {
            enable = false;
          };
          DisplayPort-1 = {
            enable = true;
            mode = "1920x1200";
            position = "1920x0";
            rate = "59.95";
            rotate = "right";
          };
          DisplayPort-0 = {
            enable = true;
            mode = "1920x1200";
            position = "0x720";
            primary = true;
            rate = "59.95";
          };
        };
      };
    };
  };

  programs.zsh.shellAliases.autorandr = "autorandr --skip-options=gamma";

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

  services.udiskie = {
    enable = true;
    notify = true;
    automount = true;
    tray = "always";
  };

  services.lorri.enable = true;

  home.packages = with pkgs; [
    (all-hies.selection {selector = p: {inherit (p) ghc865;};})
    nixops
    nodejs
    vscode
    discord
    remmina
    haskellPackages.status-notifier-item
    stack
    haskellPackages.ghcid
    google-chrome
    networkmanagerapplet
    gnome3.gnome-disk-utility
    gnome3.gnome_terminal
    gnome3.nautilus
    gnome3.gnome_session
    gnome3.gnome-tweak-tool
    pavucontrol
    evince
    mplayer
    scrot
    dropbox
    firefox
    flashplayer
    pidgin-with-plugins
    libreoffice
    nodejs
    xlibs.xmodmap
    cabal2nix
    gdb
    looking-glass-client
    ddcutil
    hicolor-icon-theme
    gnome3.adwaita-icon-theme
    gnome3.defaultIconTheme
    win10-nvme-up
    win10-nvme-sleep
    win10-nvme-down
    lorri
    entr

    (pkgs.haskellPackages.ghcWithPackages (self : [
        self.mtl
        self.xmonad
        self.cabal-install
    ]))
  ];
}
