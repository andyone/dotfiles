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
alias e="$EDITOR"
alias d="docker"
alias dr="docker run --rm -it"
alias de="docker exec -it"

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
    # Window has custom name, not path, so do not rename window
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
    ssh_exec $*
    return $?
  fi

  local ssh_session="$@[-1]"
  local window_name="$(tmux display-message -p '#W')"
  local window_name_fs="$window_name[0,1]"

  # Window has custom name, not path, so do not rename window
  if [[ "$window_name_fs" != "/" && "$window_name_fs" != "~" ]] ; then
    ssh_exec $*
    return $?
  fi

  local window_index="$(tmux display-message -p '#I')"

  tmux rename-window "SSH ($ssh_session)"

  ssh_exec $*

  local ec=$?

  # Restore original window name
  tmux rename-window -t "$window_index" "$window_name"

  return $ec
}

function ssh_exec() {
  if \ssh -V 2>&1 | grep -q '7.4' ; then
    \ssh $*
  else
    \ssh -o StrictHostKeyChecking=accept-new $*
  fi

  return $?
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

  if [[ $(\git rev-parse --abbrev-ref HEAD 2>/dev/null) != "master" ]] ; then
    if ! \git checkout master ; then
      return 1
    fi
  fi

  if ! \git pull ; then
    return 1
  fi

  sleep 3

  if [[ -e $HOME/.gnupg ]] ; then
    \git tag -s "v$1" -m "Version $1"
  else
    \git tag "v$1" -m "Version $1"
  fi

  [[ $? -ne 0 ]] && return 1

  if ! \git push --tags ; then
    return 1
  fi

  if \git rev-parse --quiet --verify develop &> /dev/null ; then
    \git checkout develop
  fi

  return $?
}

function git_tag_update {
  if [[ $# -eq 0 ]] ; then
    echo "Usage: git tag-update <tag>"
    return 0
  fi

  if ! \git pull ; then
    return 1
  fi

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

  if ! \git tag -d "$1" ; then
    return 1
  fi

  \git push origin ":refs/tags/$1"

  return $?
}

function git_pr {
  if [[ $# -ne 2 ]] ; then
    echo "Usage: git pr (get|rm) <pr-id>"
    return 0
  fi

  if [[ "$1" == "get" ]] ; then
    if ! \git fetch origin "pull/$2/head:PR-$2" ; then
      return 1
    fi

    if ! \git checkout "PR-$2" ; then
      return 1
    fi
  elif [[ "$1" == "rm" ]] ; then
    if ! \git checkout - ; then
      return 1
    fi

    if ! \git branch -D "PR-$2" ; then
      return 1
    fi
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
  if ! go test -coverprofile=cover.out $* ; then
    rm -f cover.out &> /dev/null
    return 1
  fi

  if which htmlcov &> /dev/null ; then
    htmlcov -r cover.out
  else
    go tool cover -html=cover.out -o coverage.html
    rm -f cover.out
  fi
}

function create_backup {
  if ! cp -rp "$1" "$1.bak" ; then
    return 1
  fi

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
