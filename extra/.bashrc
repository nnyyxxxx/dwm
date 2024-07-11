[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ff='clear && fastfetch'
alias c='clear'
alias bloat='ps -e | grep -v "PID" | wc -l && ls -A | wc -l'
alias rm='rm -rf' # Personal preference. Change this to -i if you are unsure.
alias vim='nvim'
alias debloat='~/Documents/debloat.sh'

PS1='\[\e[0;32m\]\w \$\[\e[0m\] ' 
