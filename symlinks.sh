#!/bin/sh

cd $HOME
ln -s dotfiles/Xmodmap .Xmodmap
ln -s dotfiles/dotXdefaults .Xdefaults
ln -s dotfiles/dotgvimrc.local .gvimrc.local
ln -s dotfiles/dotvimrc.before.local .vimrc.before.local
ln -s dotfiles/dotvimrc.local .vimrc.local
ln -s dotfiles/dotzshrc .zshrc

cd $HOME/.xmonad
ln -s ../dotfiles/xmonad.hs

cd $HOME/.config/taffybar
ln -s ../../dotfiles/taffybar.hs
ln -s ../../dotfiles/taffybar.rc
