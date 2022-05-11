{ buildFHSUserEnv
, callPackage
, writeScript
}:

let
  netextender = callPackage ./netextender.nix { };
  runner = writeScript "netextender-init" ''
    rm -r /tmp/netextender-chroot
    mkdir -p /tmp/netextender-chroot/ppp
    cp -r ${netextender}/etc-skeleton/ppp/ /tmp/netextender-chroot/
    bash
    rm -r /tmp/netextender-chroot
  '';
in
buildFHSUserEnv {
  name = "netextenderchroot";
  multiPkgs = pkgs: with pkgs;
    [
      netextender
      ppp
      iproute
      kmod
      wireguard-tools
    ];
  extraBuildCommands = ''
    '';
  runScript = runner;
}
