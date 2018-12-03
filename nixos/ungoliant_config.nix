# just symlink this file to /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./ungoliant-hardware-configuration.nix
      ./packages.nix
      ./users.nix
      ./mediaserver.nix
    ];

  system.stateVersion = "18.03";

  # Use the GRUB 2 boot loader.
  boot.loader.systemd-boot.enable = true;

  nix.buildCores = 0;

  nix.extraOptions = "secret-key-files = /root/ungoliant-1.secret";

  networking.hostName = "ungoliant"; # Define your hostname.

  time.timeZone = "US/Central";

  # https://bugs.launchpad.net/linux/+bug/1690085/comments/69
  # https://bugzilla.kernel.org/show_bug.cgi?id=196683
  nixpkgs.config.packageOverrides = pkgs: {
    pidgin-with-plugins = pkgs.pidgin-with-plugins.override {
      plugins = [pkgs.pidginsipe];
    };
    linux_4_18 = pkgs.linux_4_18.override {
      kernelPatches =
        pkgs.linux_4_18.kernelPatches ++ 
        [
        # https://queuecumber.gitlab.io/linux-acs-override/
        {
          name = "ACS override";
          patch = pkgs.fetchurl {
            url = "https://gitlab.com/Queuecumber/linux-acs-override/raw/master/workspaces/4.18/acso.patch";
            sha256 = "14garkj80g7jyi7acvp5zx447328yqwy6ll2qm79j7mm8x2k5r87";
          };
        }];
    };
  };

  boot.kernelParams = [ "amd_iommu=on iommu=pt amdgpu.dc=1 pcie_acs_override=downstream,multifunction" ];
  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:1401,10de:0fba
  '';
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelModules = [ "vfio_pci" ];

  boot.kernelPackages = pkgs.linuxPackages_4_18;

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
    remmina
    openconnect
    pidgin-with-plugins
    haskellPackages.status-notifier-item
    stack
    haskellPackages.ghcid
    libreoffice
    iptables
  ];
  environment.unixODBCDrivers = [ pkgs.unixODBCDrivers.msodbcsql17];


  services.redshift.enable = true;
  services.redshift.provider = "geoclue2";

  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.interval = "daily";
  services.btrfs.autoScrub.fileSystems = ["/"];

  security.wrappers.spice-client-glib-usb-acl-helper.source =
    "${pkgs.spice-gtk}/bin/spice-client-glib-usb-acl-helper.real";
  
  programs.wireshark.enable = true;
}
