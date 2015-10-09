# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ata_piix" "pata_jmicron" "usbhid" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/4051a4bb-ab65-45cc-885f-b15e5eda30c5";
      fsType = "btrfs";
      options = "subvol=nixos/@";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/e4c76487-2395-46f2-9eb2-9c803823e90b";
      fsType = "ext2";
    };

  fileSystems."/media/ssd" =
    { device = "/dev/disk/by-uuid/4051a4bb-ab65-45cc-885f-b15e5eda30c5";
      fsType = "btrfs";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/4051a4bb-ab65-45cc-885f-b15e5eda30c5";
      fsType = "btrfs";
      options = "subvol=@home";
    };

  fileSystems."/media/tb" =
    { device = "/dev/disk/by-uuid/cc3eacc2-cd59-4f4d-8c0e-4354781d9fb2";
      fsType = "btrfs";
    };

  fileSystems."/home/sjanssen/vmware" =
    { device = "/dev/disk/by-uuid/cc3eacc2-cd59-4f4d-8c0e-4354781d9fb2";
      fsType = "btrfs";
      options = "subvol=@vmware";
    };

  fileSystems."/home/sjanssen/tv" =
    { device = "/dev/disk/by-uuid/cc3eacc2-cd59-4f4d-8c0e-4354781d9fb2";
      fsType = "btrfs";
      options = "subvol=@tv";
    };

  fileSystems."/home/sjanssen/movies" =
    { device = "/dev/disk/by-uuid/cc3eacc2-cd59-4f4d-8c0e-4354781d9fb2";
      fsType = "btrfs";
      options = "subvol=@movies";
    };

  fileSystems."/home/sjanssen/comics" =
    { device = "/dev/disk/by-uuid/cc3eacc2-cd59-4f4d-8c0e-4354781d9fb2";
      fsType = "btrfs";
      options = "subvol=@comics";
    };

  fileSystems."/home/sjanssen/bulk" =
    { device = "/dev/disk/by-uuid/cc3eacc2-cd59-4f4d-8c0e-4354781d9fb2";
      fsType = "btrfs";
      options = "subvol=@sjanssen_bulk";
    };

  fileSystems."/home/sjanssen/Music" =
    { device = "/dev/disk/by-uuid/cc3eacc2-cd59-4f4d-8c0e-4354781d9fb2";
      fsType = "btrfs";
      options = "subvol=@Music";
    };

  fileSystems."/home/sjanssen/.x" =
    { device = "/dev/disk/by-uuid/cc3eacc2-cd59-4f4d-8c0e-4354781d9fb2";
      fsType = "btrfs";
      options = "subvol=@.x";
    };

  fileSystems."/media/vm-images" =
    { device = "/dev/disk/by-uuid/0f15987e-a223-44e8-a2cb-392e75efc187";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/bdf48c89-3a8a-4742-9d3b-ca17b6c2e2fc"; }
    ];

  nix.maxJobs = 4;
}