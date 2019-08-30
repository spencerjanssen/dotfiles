# copied from https://github.com/NixOS/nixpkgs/issues/63720
{ pkgs, ... }:

{
  imports = [
    ../common/users.nix
    ../common/packages.nix
    ../common/nix-serve.nix
    ../cachix
    <home-manager/nixos>
  ];

  nix.maxJobs = 3;
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
    users = {
      sjanssen = import ../home-manager/lightweight.nix { inherit pkgs; };
    };
  };

  services.home-assistant = {
    enable = true;
  };

  users.users.remote-builder = {
    isNormalUser = false;
    isSystemUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVFrEhOYB5C9WPjaWed55dbQk7g+JCBLjmOsXrOJLfg root@ungoliant"
    ];
    shell = pkgs.bashInteractive;
  };
  nix.trustedUsers = ["remote-builder"];
}
