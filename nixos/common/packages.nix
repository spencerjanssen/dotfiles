{ config, pkgs, ... }:

{
  nix.binaryCachePublicKeys = [
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    "ungoliant-1:SVpigbAekoSnOExbVYT0pQvKWofIRv0Te4ouazLb/BU="
    "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI="
    "nix-serve.ungoliant-1:nuNHK1FmW3xn0RkeJWHVcgFthS0RvyXC+yDAI22q0Hc="
    "nix-serve.imladris-1:6aBusOdd/hnxucLm1l2whlpf8gjvqtM604uCCG1CZ54="
  ];

  # this prevents nix from garbage collecting build dependencies, especially
  # helpful with texlive which has very large source downloads
  nix.extraOptions = ''
    gc-keep-outputs = true
    gc-keep-derivations = true
  '';

  nix.binaryCaches = [
    "https://cache.nixos.org/"
  ];
  nix.trustedBinaryCaches = [
    "http://hydra.nixos.org/"
    "https://nixcache.reflex-frp.org/"
    "http://ungoliant.lan:5000/"
    "http://imladris.lan:5000/"
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
    permitRootLogin = "no";
    passwordAuthentication = false;
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
