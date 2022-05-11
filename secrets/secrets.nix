let
  sjanssen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIECSFC1NwzaUzuK6r++R6INw2GDdme37QqRICuAfyCSf sjanssen@ungoliant";
  ungoliant = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMXquDD6OGlNFizceJpUetHPqfL3MmGtvqlGvOjtnqbR";
in
{
  "sjanssen-ssh-config.age".publicKeys = [ sjanssen ungoliant ];
  "hydra-github-token.age".publicKeys = [ sjanssen ungoliant ];
}
