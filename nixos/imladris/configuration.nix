# copied from https://github.com/NixOS/nixpkgs/issues/63720
{ pkgs, ... }:

{
  imports = [
    ../common/users.nix
    ../common/packages.nix
    ../common/nix-serve.nix
    ../cachix
    ../home-assistant-supervisor/module.nix
  ];

  time.timeZone = "US/Central";

  nix.maxJobs = 3;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nixpkgs.overlays = import ../common/overlays.nix;

  fileSystems = {
    "/" = {
      fsType = "ext4";
      device = "/dev/disk/by-uuid/f79bcc26-b8d1-4c2b-817d-a8c9271f036f";
    };
    "/boot" = {
      fsType = "vfat";
      device = "/dev/disk/by-uuid/B0CA-6E9C";
    };
  };

  networking.hostName = "imladris";

  hardware.enableRedistributableFirmware = true;

  boot= {
    kernelPackages = pkgs.linuxPackages_rpi4;
    loader = {
      grub.enable = false;
      raspberryPi = {
        enable = true;
        version = 4;
      };
    };
  };

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users = {
      sjanssen = {
        imports = [
          ../home-manager/allow-unfree.nix
          ../home-manager/general-shell.nix
          ../home-manager/git-username.nix
          ../home-manager/zsh.nix
        ];
      };
    };
  };

  services.home-assistant-supervisor = {
    enable = true;
    architecture = "aarch64";
    machine = "raspberrypi4-64";
    supervisorVersion = "217";
  };

  users.users.remote-builder = {
    isNormalUser = false;
    isSystemUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVFrEhOYB5C9WPjaWed55dbQk7g+JCBLjmOsXrOJLfg root@ungoliant"
    ];
    shell = pkgs.bashInteractive;
    group = "remote-builder";
  };
  users.groups.remote-builder = {};
  nix.trustedUsers = ["remote-builder"];

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  services.avahi.enable = true;
}
