{ nixpkgs_ ? <nixpkgs> }:

let
  nixos = nixpkgs_ + "/nixos";
  eval = {conf}: (import (nixos + "/lib/eval-config.nix") {
    modules = [ conf ];
  }).config.system.build.toplevel;
in
    {
    celeborn = eval {conf = ./celeborn_config.nix; };
    eee = eval {conf = ./eee_configuration.nix; };
    }
