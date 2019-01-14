{}:
let pkgs = import <nixpkgs> {config.allowUnfree = true;};
    hm = import <home-manager/modules/default.nix> {
        inherit pkgs;
        configuration = ./build-home-no-secrets-wrapper.nix;
    };
in {
    homebuilder = hm.activationPackage;
} // builtins.listToAttrs (map (p: {name = (builtins.parseDrvName p.name).name; value = p;}) hm.config.home.packages)