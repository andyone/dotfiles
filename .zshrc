################################################################################

umask 022

################################################################################

# Path to your oh-my-zsh installation
export ZSH=$HOME/.oh-my-zsh

# GPG always wants to know what TTY it's running on
export GPG_TTY=$(tty)

# Default theme
ZSH_THEME="kaos"

# History format
HIST_STAMPS="%Y/%m/%d %T"

# Enable git and history plugins
plugins=(git history)

# Disable automatic oh-my-zsh update
zstyle ':omz:update' mode disabled

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
export COLORTERM="truecolor"

# Go env
export GOPROXY=direct
export GO111MODULE=auto
export GOPATH=~/projects/gocode
export GOBIN=~/projects/gocode/bin
export PATH=~/projects/gocode/bin:$PATH

export PATH=$HOME/.bin:/usr/local/bin:$PATH

# Aliases
alias tx="tmux attach 2>/dev/null || tmux new -n HOME"
alias sshk="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet"
alias scpk="scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet"
alias c="clear"
alias g="grep --color=auto"

# Custom functions
alias hf="history_find"
alias txc="tmux_win_rename"
alias goc="go_cover"
alias bkp="create_backup"

# Traps
alias git="git_trap"
alias cd="cd_trap"
alias ssh="ssh_trap"
alias scp="scp_trap"

################################################################################

function git_trap {
  if [[ "$1" == "release" ]] ; then
    shift
    git_release $*
  elif [[ "$1" == "tag-delete" ]] ; then
    shift
    git_tag_delete $*
  elif [[ "$1" == "tag-update" ]] ; then
    shift
    git_tag_update $*
  elif [[ "$1" == "undo" ]] ; then
    shift
    git_undo $*
  elif [[ "$1" == "pr" ]] ; then
    shift
    git_pr $*
  else
    \git $*
  fi

  return $?
}

function cd_trap() {
  # We not in a tmux session
  if [[ -z "$TMUX" ]] ; then
    \cd $*
    return $?
  fi

  local window_name="$(tmux display-message -p '#W')"
  local window_name_fs="$window_name[0,1]"
  local shell_name=$(printenv SHELL | sed 's/.*\///')

  # Name of shell it is default name for new tmux window
  if [[ "$window_name" != "$shell_name" ]] ; then
    # Window has custom name
    if [[ "$window_name_fs" != "/" && "$window_name_fs" != "~" ]] ; then
      \cd $*
      return $?
    fi
  fi

  \cd $*

  if [[ $? -ne 0 ]] ; then
    return $?
  fi

  tmux_win_rename
}

function ssh_trap() {
  # We not in a tmux session
  if [[ -z "$TMUX" ]] ; then
    \ssh $*
    return $?
  fi

  local ssh_session="$@[-1]"
  local window_name="$(tmux display-message -p '#W')"

  tmux rename-window "SSH ($ssh_session)"

  if \ssh -V 2>&1 | grep -q '7.4' ; then
    \ssh $*
  else
    \ssh -o StrictHostKeyChecking=accept-new $*
  fi

  local ec=$?

  tmux rename-window "$window_name"

  return $ec
}

function scp_trap() {
  if \ssh -V 2>&1 | grep -q '7.4' ; then
    \scp $*
  else
    \scp -o StrictHostKeyChecking=accept-new $*
  fi

  return $?
}

function git_release {
  if [[ $# -eq 0 ]] ; then
    echo "Usage: git release <version>"
    return 0
  fi

  \git checkout master

  [[ $? -ne 0 ]] && return 1

  \git pull

  [[ $? -ne 0 ]] && return 1

  sleep 3

  if [[ -e $HOME/.gnupg ]] ; then
    \git tag -s "v$1" -m "Version $1"
  else
    \git tag "v$1" -m "Version $1"
  fi

  [[ $? -ne 0 ]] && return 1

  \git push --tags

  [[ $? -ne 0 ]] && return 1

  \git checkout develop

  return $?
}

function git_tag_update {
  if [[ $# -eq 0 ]] ; then
    echo "Usage: git tag-update <tag>"
    return 0
  fi

  \git pull

  [[ $? -ne 0 ]] && return 1

  if [[ -e $HOME/.gnupg ]] ; then
    \git tag -f -s "$1" -m "Version ${1/v/}"
  else
    \git tag -f "$1" -m "Version ${1/v/}"
  fi

  [[ $? -ne 0 ]] && return 1

  \git push -f --tags

  return $?
}

function git_tag_delete {
  if [[ $# -eq 0 ]] ; then
    echo "Usage: git tag-delete <tag>"
    return 0
  fi

  \git tag -d "$1"

  [[ $? -ne 0 ]] && return 1

  \git push origin ":refs/tags/$1"

  return $?
}

function git_pr {
  if [[ $# -ne 2 ]] ; then
    echo "Usage: git pr (get|rm) <pr-id>"
    return 0
  fi

  if [[ "$1" == "get" ]] ; then
    \git fetch origin "pull/$2/head:PR-$2"

    [[ $? -ne 0 ]] && return 1

    \git checkout "PR-$2"

    [[ $? -ne 0 ]] && return 1
  elif [[ "$1" == "rm" ]] ; then
    \git checkout -

    [[ $? -ne 0 ]] && return 1

    \git branch -D "PR-$2"

    [[ $? -ne 0 ]] && return 1
  else
    echo "Usage: git pr (get|rm) <pr-id>"
  fi
}

function git_undo {
  \git reset HEAD~
  return $?
}

function tmux_win_rename {
  if [[ -z "$TMUX" ]] ; then
    return 1
  fi

  cur_dir=$(pwd | sed "s|^$HOME|~|" 2> /dev/null | sed 's:\(\.\?[^/]\)[^/]*/:\1/:g')

  tmux rename-window "$cur_dir"
}

function history_find {
  if [[ $# -eq 0 ]] ; then
    echo "Usage: hf <string>"
    return 0
  fi

  history | grep --color=always "$@" | cut -f4-99 -d" "
}

function go_cover {
  go test -coverprofile=c.out $*

  if [[ $? -ne 0 ]] ; then
    rm -f c.out
    return 1
  fi

  go tool cover -html=c.out -o coverage.html

  rm -f c.out
}

function create_backup {
  cp -rp "$1" "$1.bak"

  [[ $? -ne 0 ]] && return 1

  if [[ -d "$1" ]] ; then
    chmod 0700 "$1.bak"
  else
    chmod 0600 "$1.bak"
  fi

  return $?
}

################################################################################

function reset-prompt-and-accept-line {
  zle reset-prompt
  zle .accept-line
}

zle -N accept-line reset-prompt-and-accept-line

################################################################################

# Include local zshrc
if [[ -f $HOME/.zshrc.local ]] ; then
  source $HOME/.zshrc.local
fi
