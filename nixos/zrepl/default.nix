{ stdenv, buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  name = "zrepl-${version}";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "zrepl";
    repo = "zrepl";
    rev = "v${version}";
    sha256 = "wtUL8GGSJxn9yEdyTWKtkHODfxxLOxojNPlPLRjI9xo=";
  };

  vendorSha256 = "4LBX0bD8qirFaFkV52QFU50lEW4eae6iObIa5fFT/wA=";

  subPackages = ["."];

  # TODO: add metadata https://nixos.org/nixpkgs/manual/#sec-standard-meta-attributes
  meta = {
  };
}
