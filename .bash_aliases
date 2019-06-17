
alias ll='ls -AhlF'
alias dirs="dirs -v"

# compiler aliases
alias g++14="g++ -std=c++14 -Wall"
alias g++17="g++ -std=c++17 -Wall"

# ssh-agent aliases
export SSH_ENV_FILE=$HOME/.ssh/env
# alias start-ssh-agent="ssh-agent -t 1d > $SSH_ENV_FILE; . $SSH_ENV_FILE; ssh-add"
# alias restore-ssh-agent=". $SSH_ENV_FILE"
alias ssh-stop="ssh-agent -k"

# check if ssh-agent is already running, in which case restore the environment information, otherwise start a new one.
function ssh-start
{
    if [[ -f $SSH_ENV_FILE ]]; then
        . $SSH_ENV_FILE > /dev/null
    fi
    if [[ ( ! -f $SSH_ENV_FILE ) || ( $(pgrep ssh-agent) != $SSH_AGENT_PID ) ]]; then
        ssh-agent -t 1d > $SSH_ENV_FILE
        . $SSH_ENV_FILE
        ssh-add
    fi
}


