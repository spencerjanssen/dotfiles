# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/8719734d-1270-43ca-ba7a-8233ef843daa";
      fsType = "btrfs";
      options = "subvol=@nix";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/6b0facb1-ba8d-479a-b3b2-bbf3583d6798";
      fsType = "ext3";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/835e9677-cad0-4b01-a081-a52a6e0a65d6"; }
    ];

  nix.maxJobs = 2;
}
