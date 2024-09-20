[[ $- != *i* ]] && return

PS1='\[\e[0;32m\]\w \$\[\e[0m\] '

RC='\033[0m'
MAGENTA='\033[35m'

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ff='clear && fastfetch'
alias c='clear'
alias bloat='ps -e | grep -v "PID" | wc -l && ls -A | wc -l'
alias rm='rm -rf'
alias vim='nvim'
alias debloat='~/Documents/debloat.sh'

export EDITOR='nvim'
export VISUAL='nvim'
export TERMINAL='st-256color'
export BROWSER='firefox'

clone() { 
    if [ -z "$1" ]; then
        echo -e "${MAGENTA}You didn't type anything in, stupid! BONK! Owo${RC}"
        return 1
    fi
    git clone "$1" 2>/dev/null && cd "$(basename "$1" .git)" || {
        echo -e "${MAGENTA}Repository '$1' does not exist, stupid! BONK! Owo${RC}"
        return 1
    }
}

if ! command -v command_not_found_handle > /dev/null; then
    command_not_found_handle() {
        echo -e "${MAGENTA}Command '$1' not found, stupid! BONK! Owo${RC}" >&2
        return 127
    }
fi

shopt -s expand_aliases