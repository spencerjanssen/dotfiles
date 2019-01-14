{ config, pkgs, ... }:
{
    services.hydra = {
        enable = true;
        hydraURL = "http://127.0.0.1:9000";
        port = 9000;
        useSubstitutes = true;
        notificationSender = "spencerjanssen@gmail.com";
        extraEnv = { HYDRA_DISALLOW_UNFREE = "0"; };
        package = (import (pkgs.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs-channels";
            # nixos-18.09 as of 2019-01-12
            rev = "001b34abcb4d7f5cade707f7fd74fa27cbabb80b";
            sha256 = "1131z88p359bq0djjmqah9i25cgxabrfkw4a4a7qq6j0d6djkfig";
        }) {}).pkgs.hydra;
    };
    # https://github.com/NixOS/hydra/issues/357
    nix.buildMachines = [
        {
            hostName = "localhost";
            systems = [ "i686-linux" "x86_64-linux" ];
            maxJobs = 8;
            supportedFeatures = [ "kvm" "nixos-test" "big-parallel" ];
        }
    ];
}