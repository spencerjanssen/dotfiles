{}:
let pkgs = import <nixpkgs> {};
    hm = import <home-manager/home-manager/home-manager.nix> {
            inherit pkgs;
            confPath = ../home-manager/home.nix;
            confAttr = "";
        };
in {
    homebuilder = hm.activationPackage;
}