{ ... }:
{
  programs.git = {
    extraConfig = {
      gpg = {
        format = "ssh";
        ssh = {
          allowedSignersFile = "~/.config/git/allowed_signers";
        };
      };
      user = {
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIECSFC1NwzaUzuK6r++R6INw2GDdme37QqRICuAfyCSf";
      };
      commit = {
        gpgsign = true;
      };
      tag = {
        gpgsign = true;
      };
      log = {
        showSignature = true;
      };
    };
  };
  home.file.".config/git/allowed_signers".text = ''
    spencerjanssen@gmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIECSFC1NwzaUzuK6r++R6INw2GDdme37QqRICuAfyCSf
  '';
  # signing needs an SSH agent for some reason
  programs.keychain = {
    enable = true;
    enableXsessionIntegration = true;
    enableZshIntegration = true;
  };
}
