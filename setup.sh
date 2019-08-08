#!/bin/bash

BASEDIR=$(readlink -f "$(dirname "$0")")
echo $BASEDIR


ln -s "$BASEDIR/.tmux.conf" ~
ln -s "$BASEDIR/.vimrc" ~
mkdir -p ~/.config/nvim/
ln -s "$BASEDIR/.vimrc" ~/.config/nvim/init.vim # use same vim/nvim config file
# ln -s "$BASEDIR/.gitignore_global" ~
git config --global core.excludesfile "$BASEDIR/.gitignore_global"

# TODO bashrc?
# TODO bash_aliases?
