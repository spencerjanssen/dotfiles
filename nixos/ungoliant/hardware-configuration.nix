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
    { device = "/dev/disk/by-uuid/73e3dae7-8ca1-44cf-be89-5487ac9e9641";
      fsType = "btrfs";
      options = [ "subvol=@nixos" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/D06F-0323";
      fsType = "vfat";
    };

  fileSystems."/media/evo" =
    { device = "/dev/disk/by-uuid/73e3dae7-8ca1-44cf-be89-5487ac9e9641";
      fsType = "btrfs";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/73e3dae7-8ca1-44cf-be89-5487ac9e9641";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/media/blue" =
    { device = "/dev/disk/by-uuid/0edb6fc6-451e-40ce-848a-e70f91aeb3df";
      fsType = "btrfs";
    };

  boot.initrd.luks.devices."blue".device = "/dev/disk/by-uuid/bc6e5111-7f57-4b57-9e6d-196b000e40fa";
  boot.initrd.luks.devices."pro".device = "/dev/disk/by-uuid/51021341-d380-418a-bba6-7209ab33be62";

  fileSystems."/media/spinning" =
    { device = "/dev/disk/by-uuid/cc3eacc2-cd59-4f4d-8c0e-4354781d9fb2";
      fsType = "btrfs";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/078d90c4-e2de-4b34-8e1e-0f14f8bc8dd2"; }
    ];

  nix.maxJobs = lib.mkDefault 16;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
