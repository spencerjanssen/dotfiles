{}:
let pkgs = import <nixpkgs> {};
    patchedPkgs = pkgs.callPackage ./patched-nixpkgs.nix {};
    fhe = pkgs.callPackage patchedPkgs {};
in pkgs.callPackage ./netextender-chroot.nix {buildFHSUserEnv = fhe;}