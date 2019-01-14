_self: super: {
    haskellPackages = super.haskellPackages.override {
        overrides = self: hsuper: rec {
            # cribbed from https://github.com/NixOS/nixpkgs/issues/48891
            gtk2hs-buildtools = super.haskell.lib.overrideCabal hsuper.gtk2hs-buildtools (_: {
                patches = [ ./gtk2hs-buildtools-ghc-8.6.1.patch ];
            });

            buildHaskellPackages = hsuper.buildHaskellPackages // { inherit gtk2hs-buildtools; };

            # change is in master but not yet released
            status-notifier-item = super.haskell.lib.overrideCabal hsuper.status-notifier-item (_: {
                postPatch = ''${hsuper.hpack}/bin/hpack'';
                src = super.fetchFromGitHub {
                    owner = "IvanMalison";
                    repo = "status-notifier-item";
                    rev = "1afe7f79cbcb3522dece35f56ee0175c1b903ef9";
                    sha256 = "1ph5j1052bqh2p8xqyjfm9qsis56kkp7w2fqbl28z8rh9f5vqrw0";
                };

            });

            # this version of graphviz hasn't made it to nixpkgs yet
            graphviz = super.haskell.lib.overrideCabal hsuper.graphviz {
                version = "2999.20.0.3";
                sha256 = "04k26zw61nfv1pkd00iaq89pgsaiym0sf4cbzkmm2k2fj5xa587g";
            };

            # fixed in https://github.com/taffybar/taffybar/commit/ee2cd6b871ea05bc60a050d5cefc9e307475e794
            # not released yet
            taffybar = super.haskell.lib.overrideCabal hsuper.taffybar {
                patches = [ ./taffybar-ghc-8.6.patch ];
            };

            darcs = super.haskell.lib.overrideCabal hsuper.darcs {
                jailbreak = true;
                patches = [(super.fetchurl {
                    url = "https://raw.githubusercontent.com/jerith666/nixpkgs/40cf8a482d8e0f85dcd002a721b1dac7c28ae48c/pkgs/development/haskell-modules/patches/darcs-monadfail.patch";
                    sha256 = "14hqx1225n15qd1q76gl2isc8kimmraa6hpwjmci78z5ksblx19a";
                })];
            };
        };
    };
}