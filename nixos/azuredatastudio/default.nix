{ stdenv
, fetchurl
, autoPatchelfHook
, libsecret
, krb5
, lttng-ust
, curl
, icu
, makeWrapper
, openssl
, fontconfig
, systemd
, atomEnv
, wrapGAppsHook
, at-spi2-core
}:
stdenv.mkDerivation rec {
    name = "azuredatastudio-${version}";
    version = "1.17.1";
    src = fetchurl {
        url = "https://azuredatastudiobuilds.blob.core.windows.net/releases/${version}/azuredatastudio-linux-${version}.tar.gz";
        sha256 = "0px9n9vyjvyddca4x7d0zindd0dim7350vkjg5dd0506fm8dc38k";
    };

    nativeBuildInputs = [
        autoPatchelfHook
    ];
    buildInputs = atomEnv.packages ++ [
        at-spi2-core
        libsecret
        krb5
        lttng-ust
        curl
        icu
        makeWrapper
        openssl
        wrapGAppsHook
    ];

    installPhase = ''
        mkdir -p $out
        cp -r ./* $out
        wrapProgram $out/bin/azuredatastudio \
            --prefix LD_LIBRARY_PATH : "${stdenv.lib.makeLibraryPath [icu]}" \
            --prefix LD_LIBRARY_PATH : "${stdenv.lib.makeLibraryPath [openssl]}" \
            --prefix LD_LIBRARY_PATH : "${stdenv.lib.makeLibraryPath [fontconfig]}" \
            --prefix LD_LIBRARY_PATH : "${stdenv.lib.makeLibraryPath [systemd]}" \
    '';
}
