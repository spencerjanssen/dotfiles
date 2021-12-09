{...}:
{
  nix.extraOptions = ''
    secret-key-files = /root/ungoliant-1.secret
    experimental-features = nix-command flakes
  '';
}
