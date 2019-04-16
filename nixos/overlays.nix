[
    (_self: super: {
        pidgin-with-plugins = super.pidgin-with-plugins.override {
            plugins = [super.pidginsipe];
        };
    })
    (_self: super: {
        looking-glass-client = super.callPackage ./looking-glass-client.nix { };
    })
    (_self: super: {
        lorri =
            let lorriSource = super.fetchFromGitHub {
                owner = "target";
                repo = "lorri";
                rev = "094a903d19eb652a79ad6e7db6ad1ee9ad78d26c";
                sha256 = "0y9y7r16ki74fn0xavjva129vwdhqi3djnqbqjwjkn045i4z78c8";
            };
            in (import lorriSource {src = lorriSource;});
    })
    (_self: super: {
        haskellPackages = super.haskellPackages.override {
            overrides = hsSelf: hsSuper: {
                taffybar = super.haskell.lib.overrideCabal hsSuper.taffybar (oa: {
                    broken = false;
                });
            };
        };
    })
]