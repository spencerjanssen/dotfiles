{ config, pkgs, ... }:

{
  nix.settings.trusted-public-keys = [
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    "ungoliant-1:SVpigbAekoSnOExbVYT0pQvKWofIRv0Te4ouazLb/BU="
    "nix-serve.ungoliant-1:nuNHK1FmW3xn0RkeJWHVcgFthS0RvyXC+yDAI22q0Hc="
    "nix-serve.imladris-1:6aBusOdd/hnxucLm1l2whlpf8gjvqtM604uCCG1CZ54="
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    "mithlond.lan-1:dnJ/CK6UiqB9XwEC9k/Sigw06f7JTUCpfPuqTVfyLDw="
  ];

  # this prevents nix from garbage collecting build dependencies, especially
  # helpful with texlive which has very large source downloads
  nix.extraOptions = ''
    gc-keep-outputs = true
    gc-keep-derivations = true
  '';

  nix.settings.substituters =
    (if config.networking.hostName != "mithlond" then [ "http://mithlond.lan:5000" ] else [ ])
    ++
    [
      "https://cache.nixos.org/"
      "https://hydra.iohk.io"
    ];
  nix.settings.trusted-substituters = [
    "http://hydra.nixos.org/"
    "http://mithlond.lan:5000"
  ];

  boot.cleanTmpDir = true;

  security.sudo.wheelNeedsPassword = false;

  networking.networkmanager.enable = true;

  # have to disable firewall to make chromecast work
  networking.firewall.enable = false;

  nixpkgs.config = {
    allowUnfree = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  services.dbus.enable = true;
  services.timesyncd.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    vimHugeX
    git
    zsh
    psmisc
    file
    htop
    pciutils
    binutils
    usbutils
    tmux
    rsync
    strace
    pv
    cifs-utils
  ];
}
