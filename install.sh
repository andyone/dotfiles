#!/bin/bash

################################################################################

NORM=0
BOLD=1
UNLN=4
RED=31
GREEN=32
YELLOW=33
BLUE=34
MAG=35
CYAN=36
GREY=37
DARK=90

CL_NORM="\e[0m"
CL_BOLD="\e[0;${BOLD};49m"
CL_UNLN="\e[0;${UNLN};49m"
CL_RED="\e[0;${RED};49m"
CL_GREEN="\e[0;${GREEN};49m"
CL_YELLOW="\e[0;${YELLOW};49m"
CL_BLUE="\e[0;${BLUE};49m"
CL_MAG="\e[0;${MAG};49m"
CL_CYAN="\e[0;${CYAN};49m"
CL_GREY="\e[0;${GREY};49m"
CL_DARK="\e[0;${DARK};49m"
CL_BL_RED="\e[1;${RED};49m"
CL_BL_GREEN="\e[1;${GREEN};49m"
CL_BL_YELLOW="\e[1;${YELLOW};49m"
CL_BL_BLUE="\e[1;${BLUE};49m"
CL_BL_MAG="\e[1;${MAG};49m"
CL_BL_CYAN="\e[1;${CYAN};49m"
CL_BL_GREY="\e[1;${GREY};49m"

################################################################################

REPOSITORY="https://raw.githubusercontent.com/andyone/dotfiles/master/"

################################################################################

files=(".gitconfig" ".gitignore" ".rbdef" ".rpmmacros" ".tmux.conf" ".zshrc")
theme=("kaos-lite.zsh-theme" "kaos.zsh-theme")

################################################################################

main() {
  check

  pushd "$HOME" &> /dev/null
    doDepsInstall
    doOMZInstall
    doBackup
    doInstall
  popd &> /dev/null
}

check() {
  local has_errors

  if [[ $(id -u) == "0" ]] ; then
    error "Looks like you are insane and try to install .dotfiles to"
    error "root account. Do not do this. Never."
    has_errors=true
  fi

  if [[ $has_errors ]] ; then
    exit 1
  fi
}

doOMZInstall() {
  if [[ -e $HOME/.oh-my-zsh ]] ; then
    return
  fi

  showm "Installing Oh My Zsh... " $BOLD

  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" &>/dev/null

  if [[ $? -eq 0 ]] ; then
    show "DONE" $GREEN
  else
    show "ERROR" $RED
    error "Can't install Oh My Zsh"
    exit 1
  fi
}

doDepsInstall() {
  local deps=""

  if ! isAppInstalled "zsh" ; then
    deps="zsh"
  fi

  if ! isAppInstalled "tmux" ; then
    deps="$deps tmux"
  fi

  if ! isAppInstalled "git" ; then
    deps="$deps git"
  fi

  if [[ -z "$deps" ]] ; then
    return
  fi

  showm "Installing deps... " $BOLD

  sudo yum -q -y install $deps 2> /dev/null

  if [[ $? -eq 0 ]] ; then
    show "DONE" $GREEN
  else
    show "ERROR" $RED
    error "Can't install $deps"
    exit 1
  fi
}

doBackup() {
  local file_list=$(getBackupFiles)

  if [[ -z "$file_list" ]] ; then
    return
  fi

  local ts=$(date '+%Y%m%d%H%M%S')
  local output="$HOME/.andyone-term-${ts}.tar.bz2"

  tar cjf "$output" $file_list &> /dev/null

  show "Backup created as $output" $DARK
}

doInstall() {
  local file

  showm "Installing " $BOLD

  for file in ${theme[@]} ; do
    download "themes/$file" "$HOME/.oh-my-zsh"
    showm "•" $GREY
  done

  for file in ${files[@]} ; do
    download "$file" "$HOME"
    showm "•" $GREY
  done

  show " DONE" $GREEN
}

getBackupFiles() {
  local file_list

  for file in ${files[@]} ; do
    if [[ -e $HOME/$file ]] ; then
      file_list="$HOME/$file $file_list"
    fi
  done

  echo "${file_list% }"
}

download() {
  local name="$1"
  local dir="$2"

  curl -s "$REPOSITORY/$name" -o "$dir/$name"
}

isAppInstalled () {
  for app in "$@" ; do
    type -P "$app" &> /dev/null
    [[ $? -eq 1 ]] && return 1
  done

  return 0
}

show() {
  if [[ -n "$2" && -z "$no_colors" ]] ; then
    echo -e "\e[${2}m${1}\e[0m"
  else
    echo -e "$*"
  fi
}

showm() {
  if [[ -n "$2" && -z "$no_colors" ]] ; then
    echo -e -n "\e[${2}m${1}\e[0m"
  else
    echo -e -n "$*"
  fi
}

error() {
  show "$*" $RED 1>&2
}

################################################################################

main "$@"
