# just symlink this file to /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./surface-hardware-configuration.nix
      ./packages.nix
      ./users.nix
      ./btrfs_backup.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.gummiboot.enable = true;
  boot.loader.gummiboot.timeout = 5;
  # boot.loader.efi.canTouchEfiVariables = true;
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
             #(p "cam" /home/sjanssen/Downloads/debian/patches/surface-cam.patch)
             #(p "button" /home/sjanssen/Downloads/debian/patches/surface-button.patch)
             #(p "button-config" /home/sjanssen/Downloads/debian/patches/surface-button-config.patch)
             (p "cam" ./patches/Microsoft-Surface-Pro-4-Surface-Book-camera-support.patch)
             (p "tc 3" ./patches/Add-multitouch-support-for-Microsoft-Type-Cover-3.patch)
             (p "mt quirk" ./patches/HID-multitouch-Add-MT_QUIRK_NOT_SEEN_MEANS_UP-to-MT_.patch)
             (p "mt ignore" ./patches/HID-multitouch-Ignore-invalid-reports.patch)
	     # fix and uncomment later
             #(p "surface-lid" /home/sjanssen/Downloads/debian/patches/surface-lid.patch)
             # (p "surface-touchpad" /home/sjanssen/Downloads/debian/patches/surface-touchpad.patch)
            ];
    }) self;
    in self;

  nix.buildCores = 0;
  nix.buildMachines =
    [ {hostName = "192.168.86.200"; maxJobs = 1; sshUser = "sjanssen"; sshKey = "/home/sjanssen/.ssh/id_rsa"; system="x86_64-linux";}]
    ;
  nix.distributedBuilds = true;

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
