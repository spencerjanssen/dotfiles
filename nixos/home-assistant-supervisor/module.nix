{config, pkgs, lib, ... }:
with lib;

let cfg = config.services.home-assistant-supervisor;

    supervisorImage = "homeassistant/${cfg.architecture}-hassio-supervisor";

    configFile = pkgs.writeText "hassio.json" (builtins.toJSON {
      supervisor = supervisorImage;
      homeassistant = "homeassistant/${cfg.machine}-homeassistant";
      data = cfg.dataDir;
    });

    systemDocker = config.virtualisation.docker.package;

    fetchImage = pkgs.writeScript "fetch-hassio-supervisor-image" ''
      #!${pkgs.bash}/bin/bash
      docker image inspect ${supervisorImage} 2>/dev/null || ( docker pull ${supervisorImage}:${cfg.supervisorVersion} && docker tag ${supervisorImage}:${cfg.supervisorVersion} ${supervisorImage}:latest)
    '';

    haTools = pkgs.stdenv.mkDerivation {
      name = "home-assistant-supervised-installer";

      src = cfg.src;

      nativeBuildInputs = [
        pkgs.makeWrapper
      ];

      installPhase = ''
        mkdir -p $out/bin
        cp $src/files/hassio-supervisor $src/files/ha $out/bin
        chmod +x $out/bin/*

        substituteInPlace $out/bin/hassio-supervisor --replace "%%HASSIO_CONFIG%%" ${configFile}

        wrapProgram $out/bin/ha --prefix PATH : "${makeBinPath [systemDocker]}"
        wrapProgram $out/bin/hassio-supervisor --prefix PATH : "${makeBinPath [pkgs.jq]}"
      '';
    };
in
{
  options.services.home-assistant-supervisor = {
    enable = mkEnableOption "Home Assistant Supervisor";

    src = mkOption {
      type = types.package;
      default = pkgs.fetchFromGitHub {
        owner = "home-assistant";
        repo = "supervised-installer";
        rev = "be010f288d3913cc7f753c2277e7b1bea1379e55";
        sha256 = "17lflfmfzxr8r4zs6jbxr070rcvkwq117krjyqwwgz6ph7sjqih7";
      };
    };

    machine = mkOption {
      type = types.str;
      description = "Machine type";
    };

    architecture = mkOption {
      type = types.str;
      description = "Architecture";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/home-assistant-supervisor";
      description = "The path where Home Assistant will store configuration and state.";
    };

    supervisorVersion = mkOption {
      type = types.str;
      description = "Initial supervisor version (see https://version.home-assistant.io/stable.json)";
      default = "latest";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;

    users.users.home-assistant-supervisor = {
      home = cfg.dataDir;
      createHome = true;
      group = "home-assistant-supervisor";
      extraGroups = ["dialout" "docker"];
      isSystemUser = true;
    };

    users.groups.home-assistant-supervisor = {};

    systemd.services.home-assistant-supervisor = {
      description = "Hass.io Supervisor";
      requires = ["docker.service"];
      after = ["docker.service" "dbus.socket"];
      script = "${haTools}/bin/hassio-supervisor";
      path = [systemDocker];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "simple";
        RestartSec = 5;
        Restart = "always";
        ExecStartPre = ["-${fetchImage}" "-docker stop hassio_supervisor"];
        ExecStop = "-docker stop hassio_supervisor";
        User = "home-assistant-supervisor";
        Group = "home-assistant-supervisor";
      };
    };

    environment.systemPackages = [haTools];
  };
}
