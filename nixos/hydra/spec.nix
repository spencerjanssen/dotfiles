{ nixpkgs, declInput }:
let pkgs = import nixpkgs {};
    common = {
        enabled = 1;
        hidden = false;
        nixexprinput = "dotfiles";
        checkinterval = 300;
        schedulingshares = 100;
        enableemail = false;
        emailoverride = "spencerjanssen@gmail.com";
        keepnr = 3;
        inputs = {
            dotfiles = {
                type = "git";
                value = "git://github.com/spencerjanssen/dotfiles.git decltest";
                emailresponsible = false;
            };
            nixpkgs = {
                type = "git";
                value = "git://github.com/NixOS/nixpkgs-channels nixos-unstable";
                emailresponsible = false;
            };
        };
    };

    jobs = {
        ungoliant = common // {
            nixexprpath = "nixos/build-system.nix";
            description = "Ungoliant system configuration";
        };
        home = common // {
            nixexprpath = "nixos/build-home.nix";
            description = "home-manager configuration";
        };
    };
    json = pkgs.writeTextFile {
        name = "spec.json";
        text = builtins.toJSON jobs;
    };
in {
    jobsets = json;
}