{ stdenv
, fetchurl
, rpm
, cpio
}:
let version = "1.0";
in
stdenv.mkDerivation {
    name = "netextender-${version}";
    src = fetchurl {
        name = "netextender.rpm";
        url = "https://api.mysonicwall.com/api/downloads/download-software?username=ANONYMOUS&swID=16390&swGrpID=11755&isRNotes=0&sessionID=ANONYMOUS&appName=MSW&oemCode=SNWL";
        sha256 = "136c0a15qcb1179rn4vqkwnclgvhjyhx6pmgd02q6b1gdizgsr92";
    };

    nativeBuildInputs = [
        rpm
        cpio
    ];
    buildInputs = [
    ];

    buildCommand = ''
        mkdir -p $out/
        cd $out
        rpm2cpio $src | cpio -idv -f "*uninstallNetExtender"
        mv $out/usr/* $out/
        rmdir $out/usr
        patchelf \
            --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
            $out/sbin/netExtender
        for i in ip-up.d ip-down.d ipv6-up.d ipv6-down.d
        do
            mkdir -p $out/etc/ppp/$i
        done
        mkdir -p $out/etc/ppp/ip-up.d
        mkdir -p $out/etc/ppp/ip-down.d

        touch $out/etc/ppp/ip-down.d/sslvpnroutecleanup
        touch $out/etc/ppp/ipv6-down.d/sslvpnroute6cleanup
        chmod 700 $out/etc/ppp/ip-down.d/sslvpnroutecleanup
        chmod 700 $out/etc/ppp/ipv6-down.d/sslvpnroute6cleanup

        mv $out/etc $out/etc-skeleton
        mkdir -p $out/etc
        ln -s /host/tmp/netextender-chroot/ppp $out/etc/ppp
    '';
}