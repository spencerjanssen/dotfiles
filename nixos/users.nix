{ config, pkgs, ... }:

{
  programs.zsh.enable = true;

  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  users.extraUsers.sjanssen = {
    isNormalUser = true;
    uid = 1000;
    group = "sjanssen";
    extraGroups = ["wheel" "networkmanager"];
    shell = "/run/current-system/sw/bin/zsh";
    openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDitE2XMoyQAEhgww4gwEZTPkFCckC0tBOnXArBH0MZMJqPoU2vXfNz0Ea4Q055bo4sJpYfMpG00EyTQ2td1krpfr/CgO9G5ca9sPS+fJHmzVUC6qEQzrNaLNy3o2LmpKit7YwWFEh2vW0sDkmZmR5f69xLYZFnHbYJJwAS3m8yG/y5RATkFZs0joVm1u1Df4c4EEMdjiPQFWxnPPmu6wsaVbnP4xMWNgaxpTmHNFhudnlU1kkzM8T2saoK6CEhlF5uBRU3Cyw8ejcvJ9ULjRIrFsl1+wAovwoFMv8VLoYee9zBLLXE1xKLUXuC0DH0v1AHE47UY24Q1srwGH/Aux8T nexus 5 2014.04.16"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEverbtaMH0WCt25dBry8lyUkNKk6K3/sU8qDCpvKsF8SLe+Mbhr5GPqj3LEyWdK23cSHlPbxKDxAFfqAuYvJgErT//i9lJkVxvZlMC9Xhu6czzTWluSyvHaP8VqxwlAV67TCO8Cb4VnNR+CHTE6hkM94nk43zGrjCYYlPSOx+yHG7NQ/3wxZnrnE6hazZG9s6Rb2vgY9fKXPgtFJHrxn8vyW4tOnIogVh1vaevOg/MwB5wOm31++jRPajbfaB0cAkBXl7Y/u0GeD33XXymwrfG5/DAgX9IytVs5mR0k04I5zA2Ofn8zu+9llnKws7fJBK2X/QhecjZLCBTcSMvLrt sjanssen@nixee"
    "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtAvnTjqnz4eYpPYZacgH5y9hAf+wRPCnNGSIA7a1Wm5E0ebqWuoOZp7L++g7SKDQ49ZMcX8fhgHJpS/0kIVDf4ku+L3WiOJN/rnQyZ7NoP3vmM224aN8xJFoSBHfg/rUjiAktcaBRmq6IaX+mxTGn63s1ITP5ls4c1bP7bjZXXlTLmJmY6H6jgvvjK39w9Wci36DldIv0hSsZ/bJyoRynEsXkgWFhGMRc7ZTJRKraaBPqz3377q5k2Uod9DlYy5Tl/BhRL7d1qtwgnMrMLUOkCrykxlP+sByyS05rRDkvdWwZduJavCJAW5ylFR5Fe/6bNWIAU5xsM/G8/zQvxoUFQ== sjanssen@celeborn"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZZ9xxOadnK8R4Vu+RjPH4+5gw5XF3Dx5OsoN7czdJb06VQ1/cjPX+m62e/VyMp8306hgbWaMOLts1Y7/qMwhZkmkkMHGDuflu5cAhj5BEfIj0LnEUaWAIpcQj8vs0F2by3R9Z7voSmFzaRTYcVp6BRaVoIlCKZjcJNO+s96gMS4wRz3QFZ2kOciNcZtquXOkgEL65tgXfILa81lSFg0Nr9DpQP2qgeb7hTEdj0afIgBQ5qvyPV0hnuwYiG5M8D0NZCFqteyUGlY8uogYsSYtBCeYKwyeVwo4Y20iqVWG0LuO9lrWa4BAtPnhn95nyhD72UH9izT9TXEIiA7/+acbV sjanssen@sjanssen.xen.prgmr.com"
    ];
  };
  users.extraGroups.sjanssen = {
    gid = 1000;
  };
}
