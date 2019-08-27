{ nixpkgs, declInput }: let pkgs = import nixpkgs {};
in {
    jobsets = pkgs.runCommand "spec.json" {} ''
        cat <<EOF
        ${builtins.toXML declInput}
        EOF
        cat > $out <<EOF
        {
            "master": {
                "enabled": 1,
                "hidden": false,
                "description": "js",
                "nixexprinput": "dotfiles",
                "nixexprpath": "nixos/build-system.nix",
                "checkinterval": 300,
                "schedulingshares": 100,
                "enableemail": false,
                "emailoverride": "spencerjanssen@gmail.com",
                "keepnr": 3,
                "inputs": {
                    "dotfiles": {
                        "type": "git",
                        "value": "git://github.com/spencerjanssen/dotfiles.git decltest",
                        "emailresponsible": false
                    },
                    "nixpkgs": {
                        "type": "git",
                        "value": "git://github.com/NixOS/nixpkgs-channels nixos-unstable",
                        "emailresponsible": false
                    }
                }
            }
        }
        EOF
    '';

}