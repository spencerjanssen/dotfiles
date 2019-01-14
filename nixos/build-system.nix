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
} // builtins.listToAttrs (map (p: {name = (builtins.parseDrvName p.name).name; value = p;}) ungoliantConfig.config.environment.systemPackages)