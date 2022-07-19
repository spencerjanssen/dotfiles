let
  sjanssen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIECSFC1NwzaUzuK6r++R6INw2GDdme37QqRICuAfyCSf sjanssen@ungoliant";
  ungoliant = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMXquDD6OGlNFizceJpUetHPqfL3MmGtvqlGvOjtnqbR";
  mithlond = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIDteCgjYAAEY+eDBnnfVU7BnJ5y/A3NE0t/5tnMjT10";
in
{
  "sjanssen-ssh-config.age".publicKeys = [ sjanssen ungoliant mithlond ];
  "hydra-github-token.age".publicKeys = [ sjanssen ungoliant ];
  "zrepl-ungoliant.crt.age".publicKeys = [ sjanssen ungoliant mithlond ];
  "zrepl-ungoliant.key.age".publicKeys = [ sjanssen ungoliant ];
  "zrepl-mithlond.crt.age".publicKeys = [ sjanssen ungoliant mithlond ];
  "zrepl-mithlond.key.age".publicKeys = [ sjanssen mithlond ];
  "nix-serve-mithlond.age".publicKeys = [ sjanssen mithlond ];
}
