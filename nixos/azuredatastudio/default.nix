{ stdenv
, fetchurl
, autoPatchelfHook
, libXrandr
, libXdamage
, libXfixes
, libXi
, libXScrnSaver
, libXcursor
, alsaLib
, cups
, at_spi2_core
, at_spi2_atk
, glib
, nss
, gdk_pixbuf
, expat
, libXtst
, libXcomposite
, cairo
, gtk3
, libsecret
, xorg
, krb5
, lttng-ust
, curl
, icu
, makeWrapper
, openssl
, fontconfig
, systemd
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
    buildInputs = [
        libXrandr
        libXdamage
        libXfixes
        libXi
        libXScrnSaver
        libXcursor
        alsaLib
        cups
        at_spi2_core
        at_spi2_atk
        glib
        nss
        gdk_pixbuf
        expat
        libXtst
        libXcomposite
        cairo
        gtk3
        libsecret
        xorg.libxkbfile
        krb5
        lttng-ust
        curl
        icu
        makeWrapper
        openssl
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
