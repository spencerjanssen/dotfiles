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

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/D06F-0323";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/053e1e02-ca96-4c77-8a73-36076b121c49"; }
    ];

  nix.maxJobs = lib.mkDefault 16;
  powerManagement.cpuFreqGovernor = "ondemand";
}
