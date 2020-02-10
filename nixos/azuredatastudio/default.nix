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
    version = "1.14.1";
    src = fetchurl {
        url = "https://azuredatastudiobuilds.blob.core.windows.net/releases/1.14.1/azuredatastudio-linux-${version}.tar.gz";
        sha256 = "1f1idffji0785i2psbqalji3c1v9bwir8fqj5pw2w1w460yakb5j";
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
