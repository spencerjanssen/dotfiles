# just symlink this file to /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./surface-hardware-configuration.nix
      ./packages.nix
      ./users.nix
      ./btrfs_backup.nix
      ./ssh_reverse_tunnel.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 5;
  boot.resumeDevice = "/dev/nvme0n1p6";
  boot.initrd.kernelModules = [ "nvme" ];
  services.upower.enable = true;
  hardware.bluetooth.enable = true;
  hardware.enableAllFirmware = true;
  services.logind.extraConfig = ''
    HandleLidSwitch=hibernate
    HandleLidSwitchDocked=ignore
  '';

  boot.kernelPackages =
    let self = pkgs.linuxPackagesFor (pkgs.callPackage <nixpkgs/pkgs/os-specific/linux/kernel/linux-4.6.nix> {
        kernelPatches =
            let p = name: path: {patch = path; name = name;};
            in
            [ pkgs.kernelPatches.bridge_stp_helper
            pkgs.kernelPatches.qat_common_Makefile
             (p "cam" ./patches/Microsoft-Surface-Pro-4-Surface-Book-camera-support.patch)
             (p "tc 3" ./patches/Add-multitouch-support-for-Microsoft-Type-Cover-3.patch)
             (p "mt quirk" ./patches/HID-multitouch-Add-MT_QUIRK_NOT_SEEN_MEANS_UP-to-MT_.patch)
             (p "mt ignore" ./patches/HID-multitouch-Ignore-invalid-reports.patch)
            ];
    }) self;
    in self;

  nix.buildCores = 0;

  networking.hostName = "surface"; # Define your hostname.

  time.timeZone = "US/Central";

  services.xserver.videoDrivers = [ "intel" ];
  services.xserver.synaptics = {
    enable = true;
    palmDetect = true;
    twoFingerScroll = true;
  };

  services.autossh.sessions =
    [
        { name = "sidev";
        user = "sjanssen";
        extraArguments = "-N -D 127.0.0.1:1234 -L 1337:127.0.0.1:1337 -L 8080:127.0.0.1:8080 -L 8081:127.0.0.1:8081 sidev";
        }
    ];
}
