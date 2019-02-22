{ stdenv
, fetchurl
, cmake
, gmp
, pkgconfig
, nettle
, libconfig
, x11
, spice-protocol
, libGL
, libGLU
, SDL2_ttf
, SDL2
}:
let version = "a12";
in
stdenv.mkDerivation {
    name = "looking-glass-client-${version}";
    src = fetchurl {
        url = "https://github.com/gnif/LookingGlass/archive/${version}.tar.gz";
        sha256 = "0x57chx83f8pq56d9sfxmc9p4qjm9nqvdyamj41bmy145mxw5w3m";
    };
    sourceRoot = "LookingGlass-a12/client";
    preConfigure = "cmake";
    buildInputs = [
        cmake
        gmp
        pkgconfig
        nettle
        libconfig
        x11
        spice-protocol
        libGL
        libGLU
        SDL2_ttf
        SDL2
    ];

    installPhase = ''
        mkdir -p $out/bin
        cp ./looking-glass-client $out/bin
    '';
}