
# configure shell options
shopt -s histappend
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize
#shopt -s globstar   # enable "**" in shell

# disable Ctrl+S turning scroll lock on (turn off with Ctrl+Q)
stty -ixon

# git prompt
if [ -f /etc/bash_completion.d/git-prompt ]; then
  . /etc/bash_completion.d/git-prompt
  export GIT_PS1_SHOWDIRTYSTATE=1
  export GIT_PS1_SHOWUNTRACKEDFILES=1
  # export GIT_PS1_SHOWUPSTREAM=1
fi

# output the exit code of the previous command in colour
status_code()
{
    local ret=$?
    local col="32" # green for success
    if [[ $ret != 0 ]]; then
        col="31" # red for failure
    fi
    printf '\001\e[01;%sm\002%s\001\e[00m\002' "$col" "$ret"
}

git_status_prompt()
{
    local code=$(__git_ps1 " (%s)")
    printf '\001\e[01;33m\002%s\001\e[00m\002' "$code"
}


# use neovim as editor if available, otherwise use regular vim
if [ $(command -v nvim) ]; then
    export EDITOR=$(command -v nvim)
else
    export EDITOR=/usr/bin/vim
fi

export GPG_TTY=$(tty)
