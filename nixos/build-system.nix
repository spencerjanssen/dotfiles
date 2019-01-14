{}:
let ungoliantConfig =
        import <nixpkgs/nixos/lib/eval-config.nix> {
            system = builtins.currentSystem;
            modules = [
                ./ungoliant_config.nix
                {_module.args.dummyflexget = "don't build";}
            ];
        };
    pkgs = import <nixpkgs> {};
in
{
    ungoliant = ungoliantConfig.config.system.build.toplevel;
} // pkgs.lib.lists.foldr (p: s: s // {"${p.name}" = p;}) {} ungoliantConfig.config.environment.systemPackages