{pkgs, ...}:
let kernel = "linux_5_10";
in
{
  boot.kernelModules = [
    "vfio_pci"
  ];
  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.${kernel};
  nixpkgs.config.packageOverrides = pkgs: {
    ${kernel} = pkgs.linux_5_10.override {
      kernelPatches =
        pkgs.${kernel}.kernelPatches ++
        [
        # https://queuecumber.gitlab.io/linux-acs-override/
        {
          name = "ACS override";
          patch = pkgs.fetchurl {
            url = "https://gitlab.com/Queuecumber/linux-acs-override/raw/master/workspaces/5.6.12/acso.patch";
            sha256 = "13jdfpvc0k98hr82g1nxkzfgs37xq4gp1mpmflqk43z3nyqvszql";
          };
        }
        ];
    };
  };
}
