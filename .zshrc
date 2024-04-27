################################################################################

umask 022

################################################################################

# Path to your oh-my-zsh installation
export ZSH=$HOME/.oh-my-zsh

# GPG always wants to know what TTY it's running on
export GPG_TTY=$(tty)

# Set default theme to KAOS
ZSH_THEME="kaos"

# Enable git plugin
plugins=(git)

# Enable fzf plugin if fzf is installed
if [[ -d "$HOME/.fzf" ]] ; then
  export PATH="$HOME/.fzf:$PATH"
  plugins+=(fzf)
fi

# Disable automatic oh-my-zsh update
zstyle ':omz:update' mode disabled

################################################################################

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
HISTORY_IGNORE="(ls|ll|cd|pwd|exit|export)*"

setopt APPEND_HISTORY        # Append to history file (Default)
setopt EXTENDED_HISTORY      # Write the history file in the ':start:elapsed;command' format
setopt INC_APPEND_HISTORY    # Write to the history file immediately, not when the shell exits
setopt SHARE_HISTORY         # Share history between all sessions
setopt HIST_IGNORE_DUPS      # Do not record an event that was just recorded again
setopt HIST_IGNORE_ALL_DUPS  # Delete an old recorded event if a new event is a duplicate
setopt HIST_IGNORE_SPACE     # Do not record an event starting with a space
setopt HIST_SAVE_NO_DUPS     # Do not write a duplicate event to the history file
setopt HIST_VERIFY           # Do not execute immediately upon history expansion
setopt HIST_NO_STORE         # Don't store history commands
setopt HIST_REDUCE_BLANKS    # Remove superfluous blanks from each command line being added to the history

################################################################################

setopt nocaseglob  # ignore case
setopt correct     # correct spelling mistakes
setopt auto_cd     # if there is no app with given name, try to cd to it

################################################################################

SSH_QUIET_OPTS="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet"

################################################################################

# Export env vars
export PAGER="more"
export LESS="-MQR"
export VISUAL="nano"
export EDITOR="nano"
export LANG="en_US.UTF-8"
export TERM="xterm-256color"
export COLORTERM="truecolor"

# Go env
export GOPROXY=direct
export GO111MODULE=auto
export GOTOOLCHAIN=local
export GOPATH=~/projects/gocode
export GOBIN=~/projects/gocode/bin
export PATH=~/projects/gocode/bin:$PATH

# Add local bin dir to PATH
export PATH=$HOME/.bin:/usr/local/bin:$PATH

# Aliases
alias tx="TERM=screen-256color tmux attach 2>/dev/null || TERM=screen-256color tmux new -n HOME"
alias sshk="ssh $SSH_QUIET_OPTS"
alias scpk="scp $SSH_QUIET_OPTS"
alias dl="curl -ZL --max-redirs 3 --parallel-max 5 --remote-name-all"
alias c="clear"
alias g="grep --color=auto"
alias e="$EDITOR"
alias d="docker"
alias dr="docker run --rm -it"
alias de="docker exec -it"

# Custom functions
alias hf="history_find"
alias txc="tmux_win_to_path"
alias txn="rename_pane"
alias goc="go_cover"
alias gcl="go_clone"
alias bkp="create_backup"
alias ssht="ssh_multi"
alias flat="cat_flat"

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

  tmux_win_to_path
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
    rename_pane "SSH ($ssh_session)"
    ssh_exec $*
    return $?
  fi

  local window_index="$(tmux display-message -p '#I')"

  tmux rename-window "SSH ($ssh_session)"
  rename_pane "SSH ($ssh_session)"

  ssh_exec $*

  local ec=$?

  # Restore original window name
  tmux rename-window -t "$window_index" "$window_name"
  rename_pane "$window_name"

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

function git_release() {
  if [[ $# -eq 0 ]] ; then
    echo "Usage: git release {version}"
    return 0
  fi

  if [[ $(\git rev-parse --abbrev-ref HEAD 2>/dev/null) != "master" ]] ; then
    if ! \git push ; then
      return 1
    fi

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

function git_tag_update() {
  if [[ $# -eq 0 ]] ; then
    echo "Usage: git tag-update {tag}"
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

function git_tag_delete() {
  if [[ $# -eq 0 ]] ; then
    echo "Usage: git tag-delete {tag}"
    return 0
  fi

  if ! \git tag -d "$1" ; then
    return 1
  fi

  \git push origin ":refs/tags/$1"

  return $?
}

function git_pr() {
  if [[ $# -ne 2 ]] ; then
    echo "Usage: git pr {get|rm} {pr-id}"
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
    echo "Usage: git pr {get|rm} {pr-id}"
  fi
}

function git_undo() {
  \git reset HEAD~
  return $?
}

function history_find() {
  if [[ $# -eq 0 ]] ; then
    echo "Usage: hf {string}"
    return 0
  fi

  history | grep --color=always "$@" | cut -f4-99 -d" "
}

function go_cover() {
  if ! go test -coverprofile=cover.out $* ; then
    rm -f cover.out &> /dev/null
    return 1
  fi

  if which htmlcov &> /dev/null ; then
    htmlcov -R cover.out
  else
    go tool cover -html=cover.out -o coverage.html
    rm -f cover.out
  fi
}

function go_clone() {
  if [[ $# -eq 0 ]] ; then
    echo "Usage: gcl {org}/{repo}"
    return 0
  fi

  if ! echo "$1" | grep -q '/' ; then
    echo "Usage: gcl {org}/{repo}"
    return 0
  fi

  if ! which go &> /dev/null ; then
    print_error "Go is not installed"
    return 1
  fi

  local org=$(echo "$1" | cut -f1 -d'/')
  local repo=$(echo "$1" | cut -f2 -d'/')

  if [[ "$org" == "" || "$repo" == "" ]] ; then
    print_error "Wrong source format"
    return 1
  fi

  local clone_dir="$GOPATH/src/github.com/$org/$repo"

  if [[ -d "$clone_dir" ]] ; then
    print_error "Target directory ($clone_dir) already exist"
    return 1
  fi

  mkdir -p "$clone_dir"

  if ! \git clone "git@github.com:$org/$repo.git" "$clone_dir" ; then
    return 1
  fi

  pushd $clone_dir &> /dev/null
    \git checkout develop &> /dev/null
  popd &> /dev/null

  return 0
}

function create_backup() {
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

function ssh_multi() {
  if [[ $# -lt 2 ]] ; then
    echo "Usage: ssht host1 host2 host3…"
    return 0
  fi

  if [[ -z "$TMUX" ]] ; then
    print_error "This alias works only with TMUX"
    return 1
  fi

  tmux new-window -n "SSH ($#)" "ssh $SSH_QUIET_OPTS $1 ; sleep 5"
  rename_pane "$1"

  shift 1

  for conn in "$@" ; do
    tmux split-window "ssh $SSH_QUIET_OPTS $conn ; sleep 5"
    rename_pane "$conn"
  done

  tmux select-layout even-vertical
}

function cat_flat() {
  if [[ $# -lt 2 ]] ; then
    echo "Usage: flat file"
    return 0
  fi

  cat $1 | tr '\n' ' ' ; echo ""
}

function tmux_win_to_path() {
  if [[ -z "$TMUX" ]] ; then
    return 1
  fi

  tmux rename-window "$(get_current_dir_short)"
}

function get_current_dir_short() {
  pwd | sed "s|^$HOME|~|" 2> /dev/null | sed 's:\(\.\?[^/]\)[^/]*/:\1/:g'
}

function rename_pane() {
  tmux set-option -p @custom_pane_title "$*"
}

function print_error() {
  echo -e "\e[31m▲ $*\e[0m"
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

################################################################################

# Enable oh-my-zsh
source $ZSH/oh-my-zsh.sh
