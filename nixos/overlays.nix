[
    (_self: super: {
        pidgin-with-plugins = super.pidgin-with-plugins.override {
            plugins = [super.pidginsipe];
        };
    })
    (_self: super: {
        looking-glass-client = super.callPackage ./looking-glass-client.nix { };
    })
]