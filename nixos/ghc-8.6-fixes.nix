_self: super: {
    haskellPackages = super.haskellPackages.override {
        overrides = self: hsuper: rec {
            # cribbed from https://github.com/NixOS/nixpkgs/issues/48891
            gtk2hs-buildtools = super.haskell.lib.overrideCabal hsuper.gtk2hs-buildtools (_: {
                patches = [ ./gtk2hs-buildtools-ghc-8.6.1.patch ];
            });

            buildHaskellPackages = hsuper.buildHaskellPackages // { inherit gtk2hs-buildtools; };

            # this version of graphviz hasn't made it to nixpkgs yet
            graphviz = super.haskell.lib.overrideCabal hsuper.graphviz {
                version = "2999.20.0.3";
                sha256 = "04k26zw61nfv1pkd00iaq89pgsaiym0sf4cbzkmm2k2fj5xa587g";
            };

            # https://github.com/taffybar/taffybar/issues/435
            taffybar = super.haskell.lib.overrideCabal hsuper.taffybar {
                patches = [ ./taffybar-gi-gdkpixbuf-2.0.18.patch ];
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