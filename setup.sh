#!/bin/bash

# TODO link .vimrc
# TODO link .tmux.conf
# TODO link .bashrc?
# TODO ...

BASEDIR=$(dirname "$0")

echo $BASEDIR


BASEDIR=$(readlink -f "$(dirname "$0")")
echo $BASEDIR
