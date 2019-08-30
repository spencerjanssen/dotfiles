{...}:

{
    services.nix-serve = {
        enable = true;
        secretKeyFile = "/var/lib/nix-serve/private-key.pem";
    };
}