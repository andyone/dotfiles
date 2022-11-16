#!/bin/bash

################################################################################

set -e

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

################################################################################

GH_CONTENT="https://raw.githubusercontent.com"
REPOSITORY="$GH_CONTENT/andyone/dotfiles/master/"

################################################################################

files=(".gitconfig" ".gitignore" ".dir_colors" ".rbdef" ".rpmmacros" ".tigrc" ".tmux.conf" ".zshrc")
themes=("kaos-lite.zsh-theme" "kaos.zsh-theme")

################################################################################

pkg_manager=""
dist=""

################################################################################

main() {
  check "$@"

  pushd "$HOME" &> /dev/null
    doDepsInstall
    checkDeps
    doOMZInstall
    doBackup
    doInstall
  popd &> /dev/null
}

check() {
  local has_errors

  if [[ $(id -u) == "0" && "$1" != "iamnuts" ]] ; then
    error "Looks like you are insane and try to install .dotfiles to"
    error "root account. Do NOT do this. Never."
    has_errors=true
  fi

  dist=$(grep 'CPE_NAME' /etc/os-release | tr -d '"' | cut -d':' -f5)

  case "$dist" in
    "7")       pkg_manager="/bin/yum" ;;
    "8" | "9") pkg_manager="/bin/dnf" ;;
    *) error "Uknown or unsupported OS"
       has_errors=true ;;
  esac

  if [[ $has_errors ]] ; then
    exit 1
  fi
}

checkDeps() {
  local tmux_major

  tmux_major=$(rpm -q --queryformat '%{version}' tmux | cut -b1)

  if [[ "$tmux_major" != "3" ]] ; then
    error "tmux ≥ 3.0 is required"
    exit 1
  fi
}

doOMZInstall() {
  local current_user

  if [[ -e "$HOME/.oh-my-zsh" ]] ; then
    return
  fi

  show "Installing Oh My Zsh…\n" $BOLD

  warn "▲ Due to Oh My Zsh specific install process you have to press Ctrl+D"
  warn "  or type 'exit' after installation to continue dotfiles install.\n"

  sleep 5

  sh -c "$(curl -fsSL $GH_CONTENT/robbyrussell/oh-my-zsh/master/tools/install.sh)"

  if [[ $? -ne 0 ]] ; then
    exit 1
  fi

  current_user=$(id -u -n)

  if ! getent passwd "$current_user" | grep -q '/bin/zsh' ; then
    sudo usermod -s "/bin/zsh" "$current_user"
  fi

  show ""
}

doDepsInstall() {
  local deps=""

  if ! rpm -q kaos-repo &> /dev/null ; then
    sudo $pkg_manager clean expire-cache
    sudo $pkg_manager install -y "https://yum.kaos.st/kaos-repo-latest.el${dist}.noarch.rpm"
  fi

  if ! isAppInstalled "zsh" ; then
    deps="zsh"
  fi

  if ! isAppInstalled "tmux" ; then
    deps="$deps tmux"
  fi

  if ! isAppInstalled "git" ; then
    deps="$deps git"
  fi

  if ! isAppInstalled "bzip2" ; then
    deps="$deps bzip2"
  fi

  if [[ -z "$deps" ]] ; then
    return
  fi

  show "Installing deps…\n" $BOLD

  sudo $pkg_manager clean expire-cache
  sudo $pkg_manager -y install $deps

  if [[ $? -ne 0 ]] ; then
    exit 1
  fi

  show ""
}

doBackup() {
  local file_list=$(getBackupFiles)

  if [[ -z "$file_list" ]] ; then
    return
  fi

  local ts=$(date '+%Y%m%d%H%M%S')
  local output="$HOME/.andyone-term-${ts}.tar.bz2"

  tar cjf "$output" $file_list &> /dev/null

  chmod 600 "$output"

  show "Backup created as $output" $DARK
}

doInstall() {
  local file

  showm "Installing " $BOLD

  for file in ${themes[@]} ; do
    download "themes/$file" "$HOME/.oh-my-zsh"

    if [[ $? -eq 0 ]] ; then
      showm "•" $GREY
    else
      showm "•" $RED
      show " ERROR" $RED
      exit 1
    fi
  done

  for file in ${files[@]} ; do
    download "$file" "$HOME"

    if [[ $? -eq 0 ]] ; then
      showm "•" $GREY
    else
      showm "•" $RED
      show " ERROR" $RED
      exit 1
    fi
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
  local rnd http_code

  rnd=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w8 | head -n1)

  http_code=$(curl -s -L -w "%{http_code}" -o "$dir/$name" "$REPOSITORY/${name}?r${rnd}")

  if [[ "$http_code" != "200" ]] ; then
    return 1
  fi

  return 0
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

warn() {
  show "$*" $YELLOW 1>&2
}

################################################################################

main "$@"
