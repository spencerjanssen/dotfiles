{}:
let pkgs = import <nixpkgs> {config.allowUnfree = true;};
    hm = import <home-manager/home-manager/home-manager.nix> {
            inherit pkgs;
            confPath = ./build-home-no-secrets-wrapper.nix;
            confAttr = "";
        };
in {
    homebuilder = hm.activationPackage;
}