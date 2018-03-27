{ config, pkgs, ... }:

{
  programs.zsh.enable = true;

  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  users.extraUsers.sjanssen = {
    isNormalUser = true;
    uid = 1000;
    group = "sjanssen";
    extraGroups = ["wheel" "networkmanager" "libvirtd"];
    shell = "/run/current-system/sw/bin/zsh";
    openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtAvnTjqnz4eYpPYZacgH5y9hAf+wRPCnNGSIA7a1Wm5E0ebqWuoOZp7L++g7SKDQ49ZMcX8fhgHJpS/0kIVDf4ku+L3WiOJN/rnQyZ7NoP3vmM224aN8xJFoSBHfg/rUjiAktcaBRmq6IaX+mxTGn63s1ITP5ls4c1bP7bjZXXlTLmJmY6H6jgvvjK39w9Wci36DldIv0hSsZ/bJyoRynEsXkgWFhGMRc7ZTJRKraaBPqz3377q5k2Uod9DlYy5Tl/BhRL7d1qtwgnMrMLUOkCrykxlP+sByyS05rRDkvdWwZduJavCJAW5ylFR5Fe/6bNWIAU5xsM/G8/zQvxoUFQ== sjanssen@celeborn"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIECSFC1NwzaUzuK6r++R6INw2GDdme37QqRICuAfyCSf sjanssen@ungoliant"
    "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIEA7snAYXjjRr+qtOL+qOikwQXszkgeUh4wKiM+SxTXCq1RSj/R4OibkRLiYZqmmmI/c6Tzjj3lXHpp/99P0ezXbhERAwxlwdwhsF5yARef09TpAQ0Q7unhxpTkGrKKHQUQe4clHBYT2kWjfckRS9kBGMKK5UtPS4bicfjgF+IvNEs= celeborn-windows7-rsa-key-20120512"
    "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAuCBbl/YeKhHUVJTfDDYoTGAuO9ZvPX5Mma8psCg8YzY3lR8ZBVVLdJYPDzT0/Z3Bo4mynrZ9UVRllFVIGlxBE9ofogkAiF0bem/3MTKgdH+eoh/xt/1UQ5NwZ74mqJw+H4ZWPlj51mDqbYB0FzbkErcFLtmIwTxVLaQUEfrrzlX11sj82E90LfezaXJxNjcsAJSzNe2zR9bBGr47K3dmwv7swQtJxZFRTTHF1lQgf36up7n6s9Qx+eq0fyNGNqXgXa6+KUrl0rlovjxrqu1SY/5BqUkmHfiT3Z0tyJk2cP7MMYJcnXjYnYG3iSZk0RR41Hf8XjW9rPZPZdSCxUxzaw== windows surface rsa-key-20160415"
    ];
  };
  users.extraGroups.sjanssen = {
    gid = 1000;
  };
}
