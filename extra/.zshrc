[[ $- != *i* ]] && return

# colors
autoload -U colors && colors

# prompt
setopt PROMPT_SUBST
PS1='%F{#fb4934}$(if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then echo "$(parse_git_branch) "; fi)%F{#83a598}%~ %F{#83a598}$ %f'

# essential stuff
stty -ixon # disable ctrl+s and ctrl+q
HISTFILE=~/.zsh_history
HISTSIZE=1000000000
SAVEHIST=1000000000
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS

# essentials
alias grep='grep --color=auto'
alias ff='clear && fastfetch'
alias c='clear'
alias rm='rm -rf'
alias vim='nvim'
alias debloat='~/Documents/debloat.sh'
alias chmod='chmod +x'
alias mpv='mpv --keep-open'
alias record='mkdir -p ~/recordings && ffmpeg -f x11grab -r 60 -s 2560x1440 -i :0.0 -c:v libx264 -preset fast -crf 23 -pix_fmt yuv420p -vf "scale=2560:1440" -threads 0 ~/recordings/$(date +"%Y-%m-%d-%H-%M-%S").mp4'
alias history='history 1'
alias ..='cd ..'

# git based actions
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

# stashes changes before pulling and then releases the changes
pull() {
    git stash
    git pull
    git stash pop
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
        print -P "You didn't type anything in, %F{#fb4934}stupid! BONK!%f Owo."
        return 1
    fi
    git clone "$1" 2>/dev/null && cd "$(basename "$1" .git)" || {
        print -P "Repository '%F{#fb4934}$1%f' does not exist, %F{#fb4934}stupid! BONK!%f Owo."
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
    print -P "Command '%F{#fb4934}$1%f' not found, %F{#fb4934}stupid! BONK!%f Owo." >&2
    return 127
}

# custom command not found message 2
ls() {
    command ls -hN --color=auto --group-directories-first "$@" 2>/dev/null || print -P "Directory '%F{#fb4934}$*%f' does not exist, %F{#fb4934}stupid! BONK!%f Owo."
}

# rebasing
rebase() {
    if [ "$1" = "--abort" ]; then
        git rebase --abort || {
            print -P "Failed to abort rebase, %F{#fb4934}stupid! BONK!%f Owo."
            return 1
        }
        return 0
    fi
    if ! [[ "$1" =~ ^[0-9]+$ ]]; then
        print -P "You didn't specify a valid number of commits, %F{#fb4934}stupid! BONK!%f Owo."
        return 1
    fi
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        print -P "This is not a git repository, %F{#fb4934}stupid! BONK!%f Owo."
        return 1
    fi
    git rebase -i HEAD~"$1" || {
        print -P "Failed to rebase %F{#fb4934}$1%f commits, %F{#fb4934}stupid! BONK!%f Owo."
        return 1
    }
}

eval "$(zoxide init zsh)"

cd() {
    z "$@" 2>/dev/null || print -P "Directory '%F{#fb4934}$*%f' not found! %F{#fb4934}stupid! BONK!%f Owo."
}

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main cursor)
typeset -gA ZSH_HIGHLIGHT_STYLES

ZSH_HIGHLIGHT_STYLES[comment]='fg=#928374'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#b8bb26'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#b8bb26'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#b8bb26'
ZSH_HIGHLIGHT_STYLES[function]='fg=#b8bb26'
ZSH_HIGHLIGHT_STYLES[command]='fg=#b8bb26'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#b8bb26,italic'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#fe8019,italic'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#fe8019'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#fe8019'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#d3869b'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#b8bb26'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#b8bb26'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#b8bb26'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#fb4934'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#ebdbb2'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-unquoted]='fg=#ebdbb2'
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#ebdbb2'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=#fb4934'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#fb4934'
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#fb4934'
ZSH_HIGHLIGHT_STYLES[command-substitution-quoted]='fg=#fabd2f'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-quoted]='fg=#fabd2f'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#fabd2f'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]='fg=#fb4934'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#fabd2f'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]='fg=#fb4934'
ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=#fabd2f'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#ebdbb2'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]='fg=#fb4934'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#ebdbb2'
ZSH_HIGHLIGHT_STYLES[assign]='fg=#ebdbb2'
ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#ebdbb2'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#ebdbb2'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#fb4934'
ZSH_HIGHLIGHT_STYLES[path]='fg=#ebdbb2,underline'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#fb4934,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#ebdbb2,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=#fb4934,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#ebdbb2'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#d3869b'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]='fg=#fb4934'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#ebdbb2'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#ebdbb2'
ZSH_HIGHLIGHT_STYLES[default]='fg=#ebdbb2'
ZSH_HIGHLIGHT_STYLES[cursor]='fg=#ebdbb2'

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh