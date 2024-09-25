# prompt
[[ $- != *i* ]] && return

# colors
RC='\033[0m'
RED='\033[38;2;243;139;168m'

# prompt
PS1='\[\033[38;2;243;139;168m\]$(if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then echo "\[\033[38;2;243;139;168m\]$(parse_git_branch) "; fi)\[\033[0;32m\]\w \$\[\033[0m\] '

# essential stuff
stty -ixon # disable ctrl+s and ctrl+q
shopt -s autocd # cd into directories just by typing the name
HISTSIZE= HISTFILESIZE= # unlimited history

# essentials
alias grep='grep --color=auto'
alias ff='clear && fastfetch'
alias c='clear'
alias rm='rm -rf'
alias vim='nvim'
alias debloat='~/Documents/debloat.sh'
alias chmod='chmod +x'
alias ..='cd ..'

# git based actions
alias pull='git pull'
alias checkout='git checkout'
alias push='git push'
alias fetch='git fetch'
alias merge='git merge'
alias add='git add .'
alias stash='git stash && git stash drop'
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
    git add .
    git commit -m "$*"
    git push
}

# cloning and cding into that cloned repo
clone() { 
    if [ -z "$1" ]; then
        echo -e "You didn't type anything in, ${RED}stupid! BONK!${RC} Owo."
        return 1
    fi
    git clone "$1" 2>/dev/null && cd "$(basename "$1" .git)" || {
        echo -e "Repository ${RED}'$1'${RC} does not exist, ${RED}stupid! BONK!${RC} Owo."
        return 1
    }
}

# dynamically delete branches while on the branch you want to delete
branch() {
    if [ "$1" = "-d" ] && [ -n "$2" ]; then
        git checkout main 2>/dev/null || git checkout master 2>/dev/null
        git branch -d "$2"
    else
        git branch "$@"
    fi
}

# custom command not found message
command_not_found_handle() {
    echo -e "Command ${RED}'$1'${RC} not found, ${RED}stupid! BONK!${RC} Owo." >&2
    return 127
}

# custom command not found message 2
ls() {
    command ls -hN --color=auto --group-directories-first "$@" 2>/dev/null || echo -e "Directory ${RED}'$*'${RC} does not exist, ${RED}stupid! BONK!${RC} Owo."
}

# custom command not found message 3
cd() {
    builtin cd "$@" 2>/dev/null || echo -e "Directory ${RED}'$*'${RC} does not exist, ${RED}stupid! BONK!${RC} Owo."
}

# rebasing
rebase() {
    if [ "$1" = "--abort" ]; then
        git rebase --abort || {
            echo -e "Failed to abort rebase, ${RED}stupid! BONK!${RC} Owo."
            return 1
        }
        return 0
    fi
    if ! [[ "$1" =~ ^[0-9]+$ ]]; then
        echo -e "You didn't specify a valid number of commits, ${RED}stupid! BONK!${RC} Owo."
        return 1
    fi
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo -e "This is not a git repository, ${RED}stupid! BONK!${RC} Owo."
        return 1
    fi
    git rebase -i HEAD~"$1" || {
        echo -e "Failed to rebase ${RED}$1${RC} commits, ${RED}stupid! BONK!${RC} Owo."
        return 1
    }
}

shopt -s expand_aliases