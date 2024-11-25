{ ... }:
{
  boot.kernel.sysctl = {
    "kernel.sysrq" =
      4 # keyboard control
      + 16 # sync
      + 32 # remount read-only
      + 64 # signal processes
      + 128 # reboot/poweroff
    ;
  };
}
