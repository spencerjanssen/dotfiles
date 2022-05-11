{ config, pkgs, ... }:
{
    services.hydra = {
        enable = true;
        hydraURL = "http://127.0.0.1:9000";
        port = 9000;
        useSubstitutes = true;
        notificationSender = "spencerjanssen@gmail.com";
        extraEnv = { HYDRA_DISALLOW_UNFREE = "0"; };
        package = pkgs.hydra-master;
        extraConfig = ''
            Include ${config.age.secrets.hydra-github-token.path}
            <githubstatus>
                jobs = dotfiles-prs:.*
                inputs = declInput
            </githubstatus>
        '';
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
    nix.distributedBuilds = true;

    users.groups.hydra-secrets.members = [
        "hydra-queue-runner"
        "hydra-www"
        "hydra"
    ];

    age.secrets.hydra-github-token = {
        file = ../../secrets/hydra-github-token.age;
        group = "hydra-secrets";
        mode = "0440";
    };
}
