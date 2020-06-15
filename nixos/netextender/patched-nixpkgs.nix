{ stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation
{
    name = "patched-nixpkgs";
    src = fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs-channels";
            rev = "0a146054bdf6f70f66de4426f84c9358521be31e";
            sha256 = "154ypjfhy9qqa0ww6xi7d8280h85kffqaqf6b6idymizga9ckjcd";
        };
    patches = [./chroot.patch];
    installPhase = ''
        mkdir $out
        cp -r pkgs/build-support/build-fhs-userenv/* $out/
    '';
}
