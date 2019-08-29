# copied from https://github.com/NixOS/nixpkgs/issues/63720
{ pkgs, ... }:

{
  imports = [
    ../common/users.nix
    ../common/packages.nix
    ../cachix
    <home-manager/nixos>
  ];

  # Tell the host system that it can, and should, build for aarch64.
  nixpkgs = rec {
    crossSystem = (import <nixpkgs> {}).pkgsCross.aarch64-multiplatform.stdenv.targetPlatform;
    localSystem = crossSystem;
    overlays = import ../common/overlays.nix;
  };

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

  services.xserver = {
    enable = true;
    displayManager.slim.enable = true;
    desktopManager.xterm.enable = false;
    windowManager.i3.enable = true;
    videoDrivers = [ "fbdev" ];
  };

  hardware.enableRedistributableFirmware = true;

  # For the ugly hack to run the activation script in the chroot'd host below. Remove after sd card is set up.
  # environment.etc."binfmt.d/nixos.conf".text = ":aarch64:M::\\x7fELF\\x02\\x01\\x01\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x02\\x00\\xb7\\x00:\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\x00\\xff\\xff\\xff\\xff\\xff\\xff\\x00\\xff\\xfe\\xff\\xff\\xff:/run/binfmt/aarch64:";
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
}