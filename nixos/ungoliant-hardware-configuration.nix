# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/41272ba7-5c07-41c5-915d-e132019770b7";
      fsType = "btrfs";
      options = [ "subvol=@nixos" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/41272ba7-5c07-41c5-915d-e132019770b7";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/media/evo" =
    { device = "/dev/disk/by-uuid/41272ba7-5c07-41c5-915d-e132019770b7";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/D06F-0323";
      fsType = "vfat";
    };

  fileSystems."/media/spinning" =
    { device = "/dev/disk/by-uuid/cc3eacc2-cd59-4f4d-8c0e-4354781d9fb2";
      fsType = "btrfs";
    };

  fileSystems."/media/blue" =
    { device = "/dev/disk/by-uuid/0edb6fc6-451e-40ce-848a-e70f91aeb3df";
      fsType = "btrfs";
    };

  boot.initrd.luks.devices."blue".device = "/dev/disk/by-uuid/bc6e5111-7f57-4b57-9e6d-196b000e40fa";

  swapDevices =
    [ { device = "/dev/disk/by-uuid/053e1e02-ca96-4c77-8a73-36076b121c49"; }
    ];

  nix.maxJobs = lib.mkDefault 16;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
