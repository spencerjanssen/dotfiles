# just symlink this file to /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./ungoliant-hardware-configuration.nix
      ./packages.nix
      ./users.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.systemd-boot.enable = true;

  nix.buildCores = 0;

  nix.extraOptions = "secret-key-files = /root/ungoliant-1.secret";

  networking.hostName = "ungoliant"; # Define your hostname.

  time.timeZone = "US/Central";

  # https://bugs.launchpad.net/linux/+bug/1690085/comments/69
  # https://bugzilla.kernel.org/show_bug.cgi?id=196683
  nixpkgs.config.packageOverrides = pkgs: {
    linux_4_15 = pkgs.linux_4_15.override {
      extraConfig = ''
        RCU_EXPERT y
        RCU_NOCB_CPU y
      '';
      kernelPatches =
        pkgs.linux_4_15.kernelPatches ++ [{
          name = "ACS override";
          patch = pkgs.fetchurl {
            url = "https://gitlab.com/Queuecumber/linux-acs-override/raw/master/workspaces/4.15/acso.patch";
            sha256 = "0sh6m6ak1vhz3qq767ckdc2fzhzivkiig5irlqf1id9shd0hz22h";
          };
        }];
    };
  };

  boot.kernelParams = [ "rcu_nocbs=0-15 amd_iommu=on iommu=pt amdgpu.dc=1 pcie_acs_override=downstream,multifunction" ];
  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:1401,10de:0fba
  '';
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelModules = [ "vfio_pci" ];

  boot.kernelPackages = pkgs.linuxPackages_4_15;

  services.xserver.videoDrivers = [ "amdgpu" ];

  services.wakeonlan.interfaces = [ { interface = "enp11s0"; method = "magicpacket"; } ];

  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemuVerbatimConfig = ''
namespaces = []
cgroup_controllers = [ "cpu", "devices", "memory", "blkio", "cpuset", "cpuacct" ]
cgroup_device_acl = [
    "/dev/null", "/dev/full", "/dev/zero",
    "/dev/random", "/dev/urandom",
    "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
    "/dev/rtc","/dev/hpet",
    "/dev/input/by-id/usb-Microsoft_Microsoft®_2.4GHz_Transceiver_v9.0-if01-event-mouse",
    "/dev/input/by-id/usb-Microsoft_Microsoft®_2.4GHz_Transceiver_v9.0-event-kbd"
]
  '';

  environment.systemPackages = with pkgs; [
    nixopsUnstable
    awscli
    nodejs
    vscode
    qemu
    libvirt
    virtmanager
    spice-gtk
    discord
  ];

  services.redshift.enable = true;
  services.redshift.provider = "geoclue2";

  security.wrappers.spice-client-glib-usb-acl-helper.source =
    "${pkgs.spice-gtk}/bin/spice-client-glib-usb-acl-helper.real";
}
