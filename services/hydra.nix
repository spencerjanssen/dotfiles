{ config, pkgs, ... }:
{
  services.hydra = {
    enable = true;
    package = pkgs.hydra_unstable;
    hydraURL = "http://mithlond.lan:9000";
    port = 9000;
    useSubstitutes = true;
    notificationSender = "spencerjanssen@gmail.com";
    extraEnv = { HYDRA_DISALLOW_UNFREE = "0"; };
    extraConfig = ''
      Include ${config.age.secrets.hydra-github-token.path}
      <hydra_notify>
        <prometheus>
          listen_address = 127.0.0.1
          port = 9199
        </prometheus>
      </hydra_notify>
      <githubstatus>
          jobs = (dotfiles:main|dotfiles-prs:pr-\d+):(ungoliant\.toplevel|mithlond\.toplevel|devShell|work-hm)
          inputs = declInput
          excludeBuildFromContext = 1
          useShortContext = 1
      </githubstatus>
    '';
  };
  # https://github.com/NixOS/hydra/issues/357
  nix = {
    # white list all of our flake deps because hydra uses restricted evaluation mode
    extraOptions = ''
      allowed-uris = github:numtide/flake-utils github:NixOS github:nixos github:spencerjanssen github:nix-community/home-manager github:ryantm/agenix github:nix-systems/default
    '';
    buildMachines = [
      {
        hostName = "localhost";
        systems = [ "x86_64-linux" ];
        maxJobs = 2;
        supportedFeatures = [ "kvm" "nixos-test" "big-parallel" ];
        # special null protocol means build on localhost
        protocol = null;
      }
    ];
  };

  users.groups.hydra-secrets.members = [
    "hydra-queue-runner"
    "hydra-www"
    "hydra"
  ];

  age.secrets = {
    hydra-github-token = {
      file = ../secrets/hydra-github-token.age;
      group = "hydra-secrets";
      mode = "0440";
    };
    remote-builder-key =
      {
        file = ../secrets/remote-builder-key.age;
        group = "hydra-secrets";
        mode = "0440";
      };
    hydra-git-private-key = {
      file = ../secrets/hydra-git-private-key.age;
      group = "hydra-secrets";
      mode = "0440";
      path = "/var/lib/hydra/.ssh/id_ed25519";
    };
  };

  programs.ssh = {
    knownHosts = {
      "github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      "ungoliant.lan".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMXquDD6OGlNFizceJpUetHPqfL3MmGtvqlGvOjtnqbR";
    };
  };
}
