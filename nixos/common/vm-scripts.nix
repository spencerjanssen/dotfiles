{ vmname
, monitorSerial
, inputFeatureCode
, vmInput
, hostInput
}:
(_self: pkgs:
{
  "${vmname}-up" = pkgs.writeShellScriptBin "${vmname}-up" ''
    sudo ${pkgs.ddcutil}/bin/ddcutil --sn ${monitorSerial} setvcp ${inputFeatureCode} ${vmInput}
    ${pkgs.libvirt}/bin/virsh start ${vmname} || ${pkgs.libvirt}/bin/virsh dompmwakeup ${vmname} || echo failed to start vm, it may already be running
  '';

  "${vmname}-sleep" = pkgs.writeShellScriptBin "${vmname}-sleep" ''
    ${pkgs.libvirt}/bin/virsh dompmsuspend ${vmname} mem
    sudo ${pkgs.ddcutil}/bin/ddcutil --sn ${monitorSerial} setvcp ${inputFeatureCode} ${hostInput}
  '';
  "${vmname}-down" = pkgs.writeShellScriptBin "${vmname}-down" ''
    ${pkgs.libvirt}/bin/virsh shutdown ${vmname}
    sudo ${pkgs.ddcutil}/bin/ddcutil --sn ${monitorSerial} setvcp ${inputFeatureCode} ${hostInput}
  '';

}
)
