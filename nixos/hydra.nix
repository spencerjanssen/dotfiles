{ config, pkgs, ... }:
{
    services.hydra = {
        enable = true;
        hydraURL = "http://127.0.0.1:9000";
        port = 9000;
        useSubstitutes = true;
        notificationSender = "spencerjanssen@gmail.com";
        extraEnv = { HYDRA_DISALLOW_UNFREE = "0"; };
    };
    # https://github.com/NixOS/hydra/issues/357
    nix.buildMachines = [
        {
            hostName = "localhost";
            systems = [ "i686-linux" "x86_64-linux" ];
            maxJobs = 16;
            supportedFeatures = [ "kvm" "nixos-test" ];
        }
    ];
}