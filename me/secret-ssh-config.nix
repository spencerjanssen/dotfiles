{config, pkgs, ...}:
{
    age.secrets.sjanssen-ssh-config = {
        owner = "sjanssen";
        file = ../secrets/sjanssen-ssh-config.age;
    };

    # can't use programs.ssh.extraConfig because that config is made part of the "Host *" stanza
    # this code puts the Include at the beginning where it will actually work
    home-manager.users.sjanssen.home.file.".ssh/config".text = ''
        Include ${config.age.secrets.sjanssen-ssh-config.path}
    '';
}
