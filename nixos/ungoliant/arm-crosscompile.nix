{ pkgs, config, ...}:

{
    imports = [ ../arm-crosscompile/qemu.nix ];

    qemu-user.aarch64 = true;
}