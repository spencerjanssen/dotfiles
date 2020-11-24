#!/bin/sh

mkdir -p $HOME/.config/nixpkgs
cd $HOME/.config/nixpkgs
ln -s ../../dotfiles/home-manager/home.nix
