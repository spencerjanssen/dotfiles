[
    (import ./vm-scripts.nix {
        vmname = "win10-nvme";
        monitorSerial = "PVJVW5CA113L";
        inputFeatureCode = "0x60";
        hostInput = "0x0f";
        vmInput = "0x12";
    })
]
