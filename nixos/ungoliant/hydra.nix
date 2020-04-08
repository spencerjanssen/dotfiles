{ config, pkgs, ... }:
{
    services.hydra = {
        enable = true;
        hydraURL = "http://127.0.0.1:9000";
        port = 9000;
        useSubstitutes = true;
        notificationSender = "spencerjanssen@gmail.com";
        extraEnv = { HYDRA_DISALLOW_UNFREE = "0"; };
        package = pkgs.hydra-migration.overrideAttrs (_oldAttrs: {
            patches = [
                # see https://github.com/NixOS/nix/issues/1888
                # all-hies fetches nixpkgs which gives an error about restricted mode
                ../patches/hydra-no-restrict-eval.patch
            ];
            # tests require postgres and therefore fail
            doCheck = false;
        });
    };
    # https://github.com/NixOS/hydra/issues/357
    nix.buildMachines = [
        {
            hostName = "localhost";
            systems = [ "i686-linux" "x86_64-linux" ];
            maxJobs = 8;
            supportedFeatures = [ "kvm" "nixos-test" "big-parallel" ];
        }
        {
            hostName = "imladris";
            sshKey = "/var/lib/hydra/queue-runner/remote-build";
            sshUser = "remote-builder";
            systems = [ "aarch64-linux" ];
            maxJobs = 2;
        }
    ];
}
