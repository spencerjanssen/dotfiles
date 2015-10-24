{ config, pkgs, ... }:
let hydra = (import <nixpkgs> {}).fetchgit {
    url = https://github.com/NixOS/hydra;
    rev = "53c80d9526fb029b7adde47d0cfaa39a80926c48";
    sha256 = "1dr3n55gyxq4g71hpcgpr2p1wymmmhwvb5bv2qgmv5hcfrppxwpl";
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
