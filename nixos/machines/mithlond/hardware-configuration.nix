# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "mithlond/system/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    {
      device = "mithlond/local/nix";
      fsType = "zfs";
    };

  fileSystems."/tmp" =
    {
      device = "mithlond/local/tmp";
      fsType = "zfs";
    };

  fileSystems."/var" =
    {
      device = "mithlond/system/var";
      fsType = "zfs";
    };

  fileSystems."/home/sjanssen" =
    {
      device = "mithlond/users/sjanssen";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/9F61-4D0C";
      fsType = "vfat";
    };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}