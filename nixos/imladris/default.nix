{}:
let config =
        import <nixpkgs/nixos/lib/eval-config.nix> {
            system = builtins.currentSystem;
            modules = [
                {
                    nixpkgs = rec {
                        crossSystem = pkgs.pkgsCross.aarch64-multiplatform.stdenv.targetPlatform;
                        localSystem = crossSystem;
                    };
                }
                ./configuration.nix
            ];
        };
    pkgs = import <nixpkgs> {};
in
{
    toplevel = config.config.system.build.toplevel;
    kernel = config.config.system.build.kernel;
} // builtins.listToAttrs (map (p: {name = (builtins.parseDrvName p.name).name; value = p;}) config.config.environment.systemPackages)