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
]