[[ $- != *i* ]] && return

# prompt
PS1='\[\e[35m\]$(if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then echo "$(parse_git_branch) "; fi)\[\e[0;32m\]\w \$\[\e[0m\] '

# colors
RC='\033[0m'
MAGENTA='\033[35m'

# essentials
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ff='clear && fastfetch'
alias c='clear'
alias bloat='ps -e | grep -v "PID" | wc -l && ls -A | wc -l'
alias rm='rm -rf'
alias vim='nvim'
alias debloat='~/Documents/debloat.sh'

# git based actions
alias pull='git pull'
alias push='git push'
alias branch='git branch'
alias checkout='git checkout'
alias add='git add .'
alias push='git push'
alias pull='git pull'
alias status='git status'
alias log='git log'

# env's
export EDITOR='nvim'
export VISUAL='nvim'
export TERMINAL='st-256color'
export BROWSER='firefox'

# parse the branch and transfer it to the prompt
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

# commit with a message dynamically
commit() {
    git commit -m "$*"
}

# cloning and cding into that cloned repo
clone() { 
    if [ -z "$1" ]; then
        echo -e "${RC}You didn't type anything in, ${MAGENTA}stupid! BONK!${RC} Owo.${RC}"
        return 1
    fi
    git clone "$1" 2>/dev/null && cd "$(basename "$1" .git)" || {
        echo -e "${RC}Repository ${MAGENTA}'$1'${RC} does not exist, ${MAGENTA}stupid! BONK!${RC} Owo.${RC}"
        return 1
    }
}

# custom command not found message
command_not_found_handle() {
    echo -e "${RC}Command ${MAGENTA}'$1'${RC} not found, ${MAGENTA}stupid! BONK!${RC} Owo.${RC}" >&2
    return 127
}

shopt -s expand_aliases