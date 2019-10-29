[
    (_self: super: {
        pidgin-with-plugins = super.pidgin-with-plugins.override {
            plugins = [super.pidginsipe];
        };
    })
    (_self: super: {
        lorri =
            let lorriSource = super.fetchFromGitHub {
                owner = "target";
                repo = "lorri";
                rev = "d3e452ebc2b24ab86aec18af44c8217b2e469b2a";
                sha256 = "07yf3gl9sixh7acxayq4q8h7z4q8a66412z0r49sr69yxb7b4q89";
            };
            in (import lorriSource {src = lorriSource;});
    })
    (import ./vm-scripts.nix {
        vmname = "win10-nvme";
        monitorSerial = "PVJVW5CA113L";
        inputFeatureCode = "0x60";
        hostInput = "0x0f";
        vmInput = "0x12";
    })
]