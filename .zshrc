################################################################################

# Path to your oh-my-zsh installation
export ZSH=$HOME/.oh-my-zsh

# GPG always wants to know what TTY it's running on
export GPG_TTY=`tty`

# Theme
ZSH_THEME="kaos"

# History
HIST_STAMPS="yyyy/mm/dd"

plugins=(git history)

source $ZSH/oh-my-zsh.sh

################################################################################

# Export env vars
export PAGER="less"
export LESS="-MQR"
export VISUAL="nano"
export EDITOR="nano"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Golang env
export GOPATH=~/projects/gocode
export GOBIN=~/projects/gocode/bin
export PATH=~/projects/gocode/bin:$PATH

export PATH=$HOME/bin:/usr/local/bin:$PATH

alias sshk="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet"
alias g="grep --color=auto"
alias hf="history | grep"
alias trf="terrafarm"
alias tx="tmux attach 2>/dev/null || tmux new"
alias txc="tmux_win_rename"
alias git="git_trap"

function gml {
  gometalinter -D gotype --deadline 30s $@ | grep -v ALL_CAPS
}

function tmux_win_rename {
  if [[ -z "$TMUX" ]] ; then
    return 1
  fi

  cur_dir=$(pwd | sed "s|^$HOME|~|" 2> /dev/null | sed 's:\(\.\?[^/]\)[^/]*/:\1/:g')

  tmux rename-window "$cur_dir"
}

function git_trap {
  if [[ $1 == "release" ]] ; then
    shift
    git_release $*
    return $?
  else
    /usr/bin/git $*
    return $?
  fi
}

function git_release {
  if [[ $# -eq 0 ]] ; then
    echo "usage: git release <version>"
    return 0
  fi

  /usr/bin/git checkout master

  [[ $? -ne 0 ]] && return 1

  /usr/bin/git pull

  [[ $? -ne 0 ]] && return 1

  sleep 3

  /usr/bin/git tag -s "v$1" -m "Version $1"

  [[ $? -ne 0 ]] && return 1

  /usr/bin/git push --tags

  [[ $? -ne 0 ]] && return 1

  /usr/bin/git checkout develop

  [[ $? -ne 0 ]] && return 1
}

################################################################################

# Include local zshrc
if [[ -f $HOME/.zshrc.local ]] ; then
  source .zshrc.local
fi
