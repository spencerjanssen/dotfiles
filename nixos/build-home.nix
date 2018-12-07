{}:
let pkgs = import <nixpkgs> {config.allowUnfree = true;};
    hm = import <home-manager/home-manager/home-manager.nix> {
            inherit pkgs;
            confPath = ../home-manager/home.nix;
            confAttr = "";
        };
in {
    homebuilder = hm.activationPackage;
}