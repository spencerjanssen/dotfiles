{}:
let ungoliantConfig =
        import <nixpkgs/nixos/lib/eval-config.nix> {
            system = builtins.currentSystem;
            modules = [
                ./ungoliant_config.nix
                {_module.args.dummyflexget = "don't build";}
            ];
        };
in
{
    ungoliant = ungoliantConfig.config.system.build.toplevel;
}