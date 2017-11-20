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
export TERM="xterm-256color"

# Golang env
export GOPATH=~/projects/gocode
export GOBIN=~/projects/gocode/bin
export PATH=~/projects/gocode/bin:$PATH

export PATH=$HOME/bin:/usr/local/bin:$PATH

alias sshk="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet"
alias g="grep --color=auto"
alias hf="history_find"
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
  if [[ "$1" == "release" ]] ; then
    shift
    git_release $*
    return $?
  elif [[ "$1" == "tag-delete" ]] ; then
    shift
    git_tag_delete $*
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

  if [[ -e $HOME/.gnupg ]] ; then
    /usr/bin/git tag -s "v$1" -m "Version $1"
  else
    /usr/bin/git tag "v$1" -m "Version $1"
  fi

  [[ $? -ne 0 ]] && return 1

  /usr/bin/git push --tags

  [[ $? -ne 0 ]] && return 1

  /usr/bin/git checkout develop

  [[ $? -ne 0 ]] && return 1
}

function git_tag_delete {
  if [[ $# -eq 0 ]] ; then
    echo "usage: git tag-delete <tag>"
    return 0
  fi

  git tag -d $1

  [[ $? -ne 0 ]] && return 1

  git push origin :refs/tags/$1

  [[ $? -ne 0 ]] && return 1
}

function history_find {
  if [[ $# -eq 0 ]] ; then
    echo "usage: hf <string>"
    return 0
  fi

  history | grep --color=always $@ | cut -f4-99 -d" "
}

################################################################################

# Include local zshrc
if [[ -f $HOME/.zshrc.local ]] ; then
  source .zshrc.local
fi
