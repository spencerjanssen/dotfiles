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
ln -s dotfiles/dotgitconfig .gitconfig
ln -s dotfiles/dotinputrc .inputrc

mkdir $HOME/.xmonad
cd $HOME/.xmonad
ln -s ../dotfiles/xmonad.hs

mkdir -p $HOME/.config/taffybar
cd $HOME/.config/taffybar
ln -s ../../dotfiles/taffybar.hs
ln -s ../../dotfiles/taffybar.rc
