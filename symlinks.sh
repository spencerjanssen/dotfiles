#!/bin/sh

cd $HOME
ln -s dotfiles/Xmodmap .Xmodmap
ln -s dotfiles/dotXdefaults .Xdefaults
ln -s dotfiles/dotgvimrc.local .gvimrc.local
ln -s dotfiles/dotvimrc.before.local .vimrc.before.local
ln -s dotfiles/dotvimrc.local .vimrc.local
ln -s dotfiles/dotvimrc.bundles.local .vimrc.bundles.local
ln -s dotfiles/dotzshrc .zshrc
ln -s dotfiles/dotzshenv .zshenv
ln -s dotfiles/dotxsession .xsession

mkdir $HOME/.xmonad
cd $HOME/.xmonad
ln -s ../dotfiles/xmonad.hs

mkdir -p $HOME/.config/nixpkgs
cd $HOME/.config/nixpkgs
ln -s ../../dotfiles/home-manager/home.nix