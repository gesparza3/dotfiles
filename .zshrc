################################################################################
# OH-MY-ZSH
################################################################################

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
)

export STARSHIP_CONFIG=~/.starship
eval "$(starship init zsh)"

d='dirs -v | head -10'
1='cd -'
2='cd -2'
3='cd -3'
4='cd -4'
5='cd -5'
6='cd -6'
7='cd -7'
8='cd -8'
9='cd -9'


################################################################################
# ENV
################################################################################


unsetopt correct_all

path+=('/Users/grantesparza/bin')
path+=('/usr/local/bin')
path+=('/usr/bin')
path+=('/bin')
path+=('/usr/sbin')
path+=('/sbin')
path+=('~/go/bin')
export PATH
export PATH=$PATH:~/go/bin

export GOBIN=~/go/bin

################################################################################
# Aliases
################################################################################


alias v='nvim'
alias ghistory="git log --graph --pretty=oneline --abbrev-commit"
alias avs="aws-vault exec sandbox --"
alias avp="aws-vault exec prod --"
alias avsk="aws-vault exec sandbox -- kubectl"
alias avskt="aws-vault exec sandbox -- kubectl -n toolchain"
alias avpk="aws-vault exec prod -- kubectl"
alias avpkt="aws-vault exec prod_dev -- kubectl -n toolchain"
alias k="kubectl"
alias kt="kubectl -n toolchain"

alias ta="tmux attach-session -t"
alias tn="tmux new-session -t"
alias tk="tmux kill-session -t"
alias tl="tmux ls"

alias hg="history | grep"
alias zshreload="source ~/.zshrc && echo ZSH config reloaded"
alias tg='terragrunt'


################################################################################
# Misc.
################################################################################

export TERM=xterm-256color

if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files'
  export FZF_DEFAULT_OPTS='-m --height 50% --border'
fi

#alias ls='logo-ls'
alias compose='docker-compose'
alias config='/usr/bin/git --git-dir=/Users/grantesparza/.cfg/ --work-tree=/Users/grantesparza'
