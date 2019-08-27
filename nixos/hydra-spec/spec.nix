{ nixpkgs, declInput }:
let pkgs = import nixpkgs {};
    common = {
        enabled = 1;
        hidden = false;
        nixexprinput = "dotfiles";
        checkinterval = 600;
        schedulingshares = 100;
        enableemail = false;
        emailoverride = "spencerjanssen@gmail.com";
        keepnr = 3;
    };
    commonInputs = {
        dotfiles = {
            type = "git";
            value = "git://github.com/spencerjanssen/dotfiles.git";
            emailresponsible = false;
        };
        nixpkgs = {
            type = "git";
            value = "git://github.com/NixOS/nixpkgs-channels nixos-unstable";
            emailresponsible = false;
        };
    };

    jobs = {
        ungoliant = common // {
            nixexprpath = "nixos/ungoliant/default.nix";
            description = "Ungoliant system configuration";
            inputs = commonInputs;
        };
        home = common // {
            nixexprpath = "nixos/home-manager/default.nix";
            description = "home-manager configuration";
            inputs = commonInputs // {
                all-hies = {
                    type = "git";
                    value = "git://github.com/Infinisil/all-hies.git";
                    emailresponsible = false;
                };
                home-manager = {
                    type = "git";
                    value = "git://github.com/rycee/home-manager.git";
                    emailresponsible = false;
                };
            };
        };
    };
    json = pkgs.writeTextFile {
        name = "spec.json";
        text = builtins.toJSON jobs;
    };
in {
    jobsets = json;
}