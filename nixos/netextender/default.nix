{callPackage}:
let patchedPkgs = callPackage ./patched-nixpkgs.nix {};
    fhe = callPackage patchedPkgs {};
in callPackage ./netextender-chroot.nix {buildFHSUserEnv = fhe;}
