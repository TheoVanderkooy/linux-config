#!/bin/bash

BASEDIR=$(readlink -f "$(dirname "$0")")
echo $BASEDIR

# link config files
echo "linking config files"
ln -s "$BASEDIR/.tmux.conf" ~
mkdir -p ~/.config/nvim/
ln -s "$BASEDIR/.config/nvim/init.vim" ~/.config/nvim/init.vim # use same vim/nvim config file
ln -s "$BASEDIR/.config/nvim/init.vim" ~/.vimrc


# configure git
echo "configuring git"
git config --global core.excludesfile "$BASEDIR/gitignore_global"
git config --global grep.linenumber true
# git config --global user.gpgsign true
echo "REMEMBER TO ALSO RUN:"
echo "  git config --global user.email <email>"
echo "  git config --global user.name <name>"

# TODO bashrc?
# TODO bash_aliases?
ln -s "$BASEDIR/.bash_aliases" ~
