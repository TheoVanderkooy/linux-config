
alias ll='ls -AhlF'
alias dirs="dirs -v"

# compiler aliases
alias g++14="g++ -std=c++14 -Wall"
alias g++17="g++ -std=c++17 -Wall"


# TODO move the ssh stuff to its own file since there is so much of it, leave in the repo and cat "source <file" >> ~/.bashrc

# ssh-agent aliases
export SSH_ENV_FILE=$HOME/.ssh/env
alias ssh-stop='eval `ssh-agent -k`'
alias ssh-restart="ssh-stop; ssh-start"

# function to check if ssh-agent is already running, in which case restore the environment information, otherwise start a new one.
ssh-start()
{
    if [[ -f "$SSH_ENV_FILE" ]]; then
        . "$SSH_ENV_FILE" > /dev/null
    fi
    if [[ ( ! -f $SSH_ENV_FILE ) || ( $(pgrep ssh-agent) != $SSH_AGENT_PID ) ]]; then
        ssh-agent -t 5d > "$SSH_ENV_FILE"
        chmod 600 "$SSH_ENV_FILE"
        . "$SSH_ENV_FILE"
        ssh-add
    fi
}

# automatically connect to ssh-agent if it is already running,
# display a warning if it is not (don't automatically start is since this will
# prompt for the private key password if there is one
if [[ -f "$SSH_ENV_FILE" ]]; then
    . "$SSH_ENV_FILE" > /dev/null
fi
if [[ ( ! -f "$SSH_ENV_FILE" ) || ( $(pgrep --newest ssh-agent) != $SSH_AGENT_PID ) ]]; then
    echo 'Note: ssh-agent not running. Start it with `ssh-start`'
fi
