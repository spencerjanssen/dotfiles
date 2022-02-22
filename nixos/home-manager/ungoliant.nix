{ pkgs, ... }:

{
  # required for hydra
  home.username = "sjanssen";
  home.homeDirectory = "/home/sjanssen";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh = {
    sessionVariables = {
      LIBVIRT_DEFAULT_URI = "qemu:///system";
    };
  };

  programs.broot.enable = true;

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
          };
          DisplayPort-0 = {
            enable = true;
            mode = "1920x1200";
            position = "0x0";
            primary = true;
            rate = "59.95";
          };
        };
      };
    };
  };

  programs.zsh.shellAliases.autorandr = "autorandr --skip-options=gamma";

  services.lorri.enable = true;

  home.packages = with pkgs; [
    nodejs
    vscode
    discord
    remmina
    stack
    haskellPackages.ghcid
    google-chrome
    networkmanagerapplet
    gnome.gnome-disk-utility
    gnome.gnome-terminal
    gnome.nautilus
    gnome.gnome-session
    gnome.gnome-tweaks
    pavucontrol
    evince
    mplayer
    scrot
    dropbox
    firefox
    libreoffice
    nodejs
    xlibs.xmodmap
    cabal2nix
    gdb
    looking-glass-client
    ddcutil
    hicolor-icon-theme
    gnome.adwaita-icon-theme
    win10-nvme-up
    win10-nvme-sleep
    win10-nvme-down
    lorri
    entr
    teams
    cascadia-code
    azuredatastudio
    gnomeExtensions.material-shell
    jq

    (pkgs.haskellPackages.ghcWithPackages (self: [
      self.mtl
      self.xmonad
      self.cabal-install
    ]))

    (pkgs.callPackage ../netextender { })
  ];

}
