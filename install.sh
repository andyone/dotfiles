#!/bin/bash

################################################################################

set -e

################################################################################

VERSION="2.0.0"

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
  banner

  prepare "$@"

  pushd "$HOME" &> /dev/null
    doDepsInstall
    doOMZInstall
    doBackup
    doInstall
  popd &> /dev/null

  show "\nAll done! Enjoy your dotfiles expirience!\n" $GREEN
}

# Print banner
#
# Code: No
# Echo: No
banner() {
  show ""
  show "░░░██████╗░░█████╗░████████╗███████╗██╗██╗░░░░░███████╗░██████╗"
  show "░░░██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██║██║░░░░░██╔════╝██╔════╝"
  show "░░░██║░░██║██║░░██║░░░██║░░░█████╗░░██║██║░░░░░█████╗░░╚█████╗░"
  show "░░░██║░░██║██║░░██║░░░██║░░░██╔══╝░░██║██║░░░░░██╔══╝░░░╚═══██╗"
  show "██╗██████╔╝╚█████╔╝░░░██║░░░██║░░░░░██║███████╗███████╗██████╔╝"
  show "╚═╝╚═════╝░░╚════╝░░░░╚═╝░░░╚═╝░░░░░╚═╝╚══════╝╚══════╝╚═════╝░"
  show " by @andyone | version: $VERSION" $BOLD
  show ""

  sleep 3
}

# Prepare system for installing dotfiles
#
# Code: No
# Echo: No
prepare() {
  local has_errors

  dist=$(grep 'CPE_NAME' /etc/os-release | tr -d '"' | cut -d':' -f5)

  case "$dist" in
    "7")       pkg_manager="/bin/yum" ;;
    "8" | "9") pkg_manager="/bin/dnf" ;;
    *)         error "Unknown or unsupported OS"
               has_errors=true ;;
  esac

  if [[ $has_errors ]] ; then
    exit 1
  fi
}

# Check installed dependencies
#
# Code: No
# Echo: No
checkDeps() {
  if isCodespaces ; then
    return
  fi

  local tmux_major

  tmux_major=$(rpm -q --queryformat '%{version}' tmux | cut -b1)

  if [[ "$tmux_major" != "3" ]] ; then
    error "tmux ≥ 3.0 is required"
    exit 1
  fi
}

# Install Oh My Zsh
#
# Code: No
# Echo: No
doOMZInstall() {
  local current_user

  if [[ -e "$HOME/.oh-my-zsh" ]] ; then
    return
  fi

  show "Installing Oh My Zsh…" $CL_CYAN

  separator

  sh -c "$(curl -fsSL $GH_CONTENT/robbyrussell/oh-my-zsh/master/tools/install.sh) --unattended"

  if [[ $? -ne 0 ]] ; then
    exit 1
  fi

  current_user=$(id -u -n)

  if ! getent passwd "$current_user" | grep -q '/bin/zsh' ; then
    if ! isRoot ; then
      sudo usermod -s "/bin/zsh" "$current_user"
    else
      usermod -s "/bin/zsh" "$current_user"
    fi
  fi

  separator
}

# Install dependencies
#
# Code: No
# Echo: No
doDepsInstall() {
  local deps=""

  if ! isRoot ; then
    sudo $pkg_manager clean expire-cache &> /dev/null
  else
    $pkg_manager clean expire-cache &> /dev/null
  fi

  if ! rpm -q kaos-repo &> /dev/null ; then
    if ! isRoot ; then
      sudo $pkg_manager install -y "https://yum.kaos.st/kaos-repo-latest.el${dist}.noarch.rpm"
    else
      $pkg_manager install -y "https://yum.kaos.st/kaos-repo-latest.el${dist}.noarch.rpm"
    fi
  fi

  if ! hasApp "zsh" ; then
    deps="zsh"
  fi

  if ! isCodespaces ; then
    if ! hasApp "tmux" ; then
      deps="$deps tmux"
    fi
  fi

  if ! hasApp "git" ; then
    deps="$deps git"
  fi

  if ! hasApp "bzip2" ; then
    deps="$deps bzip2"
  fi

  if ! hasApp "curl" ; then
    deps="$deps curl"
  fi

  if [[ -z "$deps" ]] ; then
    return
  fi

  show "Installing deps…" $CL_CYAN

  separator

  if ! isRoot ; then
    sudo $pkg_manager -y install $deps
  else
    $pkg_manager -y install $deps
  fi

  if [[ $? -ne 0 ]] ; then
    exit 1
  fi

  separator
}

# Create backup
#
# Code: No
# Echo: No
doBackup() {
  if isCodespaces ; then
    return
  fi

  local file_list=$(getBackupFiles)

  if [[ -z "$file_list" ]] ; then
    return
  fi

  local ts=$(date '+%Y%m%d%H%M%S')
  local output="$HOME/.andyone-dotfiles-${ts}.tar.bz2"

  tar cjf "$output" $file_list &> /dev/null

  chmod 600 "$output"

  show "Backup created as $output" $DARK
  show
}

# Install dotfiles
#
# Code: No
# Echo: No
doInstall() {
  local file

  showm "Installing " $BOLD

  for file in ${themes[@]} ; do
    download "themes/$file" "$HOME/.oh-my-zsh"

    if [[ $? -eq 0 ]] ; then
      showm "•" $GREEN
    else
      showm "•" $RED
      show " ERROR" $RED
      exit 1
    fi
  done

  for file in ${files[@]} ; do
    download "$file" "$HOME"

    if [[ $? -eq 0 ]] ; then
      showm "•" $GREEN
    else
      showm "•" $RED
      show " ERROR" $RED
      exit 1
    fi
  done

  show " DONE" $GREEN
}

# Collect list of files to backup
#
# Code: No
# Echo: List of files (String)
getBackupFiles() {
  local file_list

  for file in ${files[@]} ; do
    if [[ -e $HOME/$file ]] ; then
      file_list+="$HOME/$file"
    fi
  done

  echo "${file_list[*]}"
}

# Download file from GitHub
#
# 1: File name (String)
# 2: Target directory (String)
#
# Code: Yes
# Echo: No
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

# Check if required app is installed
#
# 1: Variable Description (Type)
#
# Code: Yes
# Echo: No
hasApp() {
  if ! type -P "$app" &> /dev/null ; then
    return 1
  fi

  return 0
}

# Return true if current user is root
#
# Code: Yes
# Echo: No
isRoot() {
  if [[ $(id -u) == "0" ]] ; then
    return 0
  fi

  return 1
}

# Return if we in codespaces
#
# Code: No
# Echo: No
isCodespaces() {
  if [[ -n "$CODESPACES" ]] ; then
    return 0
  fi

  return 1
}

################################################################################

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

# Show separator
#
# Code: No
# Echo: No
separator() {
  local cols=$(tput cols)
  local i sep

  for i in $(seq 1 ${cols:-80}) ; do
    sep="${sep}-"
  done

  show "\n$sep\n" $GREY
}

error() {
  show "▲ $*" $RED 1>&2
}

warn() {
  show "▲ $*" $YELLOW 1>&2
}

################################################################################

main "$@"
