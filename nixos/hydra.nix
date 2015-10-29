{ config, pkgs, ... }:
let hydra = (import <nixpkgs> {}).fetchgit {
    url = https://github.com/NixOS/hydra;
    rev = "47593235142c8be99f53f2543e93330338f16f7e";
    sha256 = "0ifyhwhks8g9n0bhbp3xa68chqigafq07nk91xih1pn6s8xqdxq0";
}
;
in {
    require = [ "${hydra}/hydra-module.nix" ];
  # Hydra:
  services.hydra = {
    enable = true;
    package = (import "${hydra}/release.nix" {}).build.x86_64-linux; # or i686-linux if appropriate.
    hydraURL = "http://192.168.1.200:2000";
    notificationSender = "spencerjanssen@gmail.com";
    port = 2000;
    extraConfig = ''
        binary_cache_secret_key_file = /var/lib/hydra/secret
    '';
  };
  # Hydra requires postgresql to run
  services.postgresql.enable = true;
  services.postgresql.package = pkgs.postgresql;
}
