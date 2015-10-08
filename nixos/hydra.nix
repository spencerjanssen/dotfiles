{ config, pkgs, ... }:
let hydra = (import <nixpkgs> {}).fetchgit {
    url = https://github.com/NixOS/hydra;
    rev = "82504fe01084f432443c121614532d29c781082a";
    sha256 = "14gzslk45y53lmaa7gnmii1qxz5nw2lp19hw9hz4yhqsv59bqh0s";
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
  };
  # Hydra requires postgresql to run
  services.postgresql.enable = true;
  services.postgresql.package = pkgs.postgresql;
}
