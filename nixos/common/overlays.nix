[
    (_self: super: {
        pidgin-with-plugins = super.pidgin-with-plugins.override {
            plugins = [super.pidginsipe];
        };
    })
    (import ./vm-scripts.nix {
        vmname = "win10-nvme";
        monitorSerial = "PVJVW5CA113L";
        inputFeatureCode = "0x60";
        hostInput = "0x0f";
        vmInput = "0x12";
    })
    # darcs is broken and is a dependency of Hydra
    # https://github.com/NixOS/nixpkgs/issues/83718
    (_self: super: {
       darcs = super.haskell.lib.markUnbroken (
            super.haskell.lib.doJailbreak super.haskell.packages.ghc865.darcs
        );
    })
]
