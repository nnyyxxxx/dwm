[[ $- != *i* ]] && return

# colors
autoload -U colors && colors

# prompt
setopt PROMPT_SUBST
PS1='%F{204}$(if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then echo "$(parse_git_branch) "; fi)%F{#89b4fa}%~ %F{#89b4fa}$ %f'

# essential stuff
stty -ixon # disable ctrl+s and ctrl+q
setopt autocd # cd into directories just by typing the name
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
        print -P "You didn't type anything in, %F{#f38ba8}stupid! BONK!%f Owo."
        return 1
    fi
    git clone "$1" 2>/dev/null && cd "$(basename "$1" .git)" || {
        print -P "Repository '%F{#f38ba8}$1%f' does not exist, %F{#f38ba8}stupid! BONK!%f Owo."
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
command_not_found_handler() {
    print -P "Command '%F{#f38ba8}$1%f' not found, %F{#f38ba8}stupid! BONK!%f Owo." >&2
    return 127
}

# Update the ls function with colored error message
ls() {
    command ls -hN --color=auto --group-directories-first "$@" 2>/dev/null || print -P "Directory '%F{#f38ba8}$*%f' does not exist, %F{#f38ba8}stupid! BONK!%f Owo."
}

# rebasing
rebase() {
    if [ "$1" = "--abort" ]; then
        git rebase --abort || {
            print -P "Failed to abort rebase, %F{#f38ba8}stupid! BONK!%f Owo."
            return 1
        }
        return 0
    fi
    if ! [[ "$1" =~ ^[0-9]+$ ]]; then
        print -P "You didn't specify a valid number of commits, %F{#f38ba8}stupid! BONK!%f Owo."
        return 1
    fi
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        print -P "This is not a git repository, %F{#f38ba8}stupid! BONK!%f Owo."
        return 1
    fi
    git rebase -i HEAD~"$1" || {
        print -P "Failed to rebase %F{#f38ba8}$1%f commits, %F{#f38ba8}stupid! BONK!%f Owo."
        return 1
    }
}

eval "$(zoxide init zsh)"

cd() {
    z "$@" 2>/dev/null || print -P "Directory '%F{#f38ba8}$*%f' not found! %F{#f38ba8}stupid! BONK!%f Owo."
}

# syntax highlighting
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]="fg=#f38ba8"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=#f38ba8"
ZSH_HIGHLIGHT_STYLES[alias]="fg=#f38ba8"
ZSH_HIGHLIGHT_STYLES[function]="fg=#f38ba8"

source ~/.zshplugins/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh