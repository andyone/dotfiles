#!/bin/bash
# shellcheck disable=SC2034

################################################################################

set -e

################################################################################

VERSION="2.5.2"

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

GH_CONTENT="https://raw.githubusercontent.com"
REPOSITORY="$GH_CONTENT/andyone/dotfiles/master"
OMZ_INSTALL="$GH_CONTENT/robbyrussell/oh-my-zsh/master/tools/install.sh"

################################################################################

files=(".gitconfig" ".gitignore" ".dir_colors" ".rpmmacros" ".tigrc" ".tmux.conf" ".zshrc")
themes=("kaos-lite.zsh-theme" "kaos.zsh-theme")

################################################################################

dist=""

################################################################################

# Main function
#
# Code: No
# Echo: No
main() {
  banner

  prepare "$@"

  pushd "$HOME" &> /dev/null
    doDepsInstall
    doOMZInstall
    doBackup
    doInstall
  popd &> /dev/null

  show "\nAll done! Enjoy your dotfiles experience!\n" $GREEN
}

# Print banner
#
# Code: No
# Echo: No
banner() {
  show ""
  show " ░░░██████╗░░█████╗░████████╗███████╗██╗██╗░░░░░███████╗░██████╗" $GREY
  show " ░░░██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██║██║░░░░░██╔════╝██╔════╝" $GREY
  show " ░░░██║░░██║██║░░██║░░░██║░░░█████╗░░██║██║░░░░░█████╗░░╚█████╗░" $GREY
  show " ░░░██║░░██║██║░░██║░░░██║░░░██╔══╝░░██║██║░░░░░██╔══╝░░░╚═══██╗" $GREY
  show " ██╗██████╔╝╚█████╔╝░░░██║░░░██║░░░░░██║███████╗███████╗██████╔╝" $GREY
  show " ╚═╝╚═════╝░░╚════╝░░░░╚═╝░░░╚═╝░░░░░╚═╝╚══════╝╚══════╝╚═════╝░" $GREY
  show "                                    by @andyone | version: $VERSION" $DARK
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

  if [[ "$dist" != "8" && "$dist" != "9" ]] ; then
    error "Unknown or unsupported OS"
    has_errors=true
  fi

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

# Install dependencies
#
# Code: No
# Echo: No
doDepsInstall() {
  local deps=""

  if ! rpm -q kaos-repo &> /dev/null ; then
    if ! isRoot ; then
      sudo dnf install -y "https://pkgs.kaos.st/kaos-repo-latest.el${dist}.noarch.rpm"
    else
      dnf install -y "https://pkgs.kaos.st/kaos-repo-latest.el${dist}.noarch.rpm"
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

  show "${CL_BL_CYAN}Installing deps…${CL_NORM}"

  separator

  if ! isRoot ; then
    sudo dnf clean expire-cache &> /dev/null
    # shellcheck disable=SC2086
    sudo dnf -y install $deps
  else
    dnf clean expire-cache &> /dev/null
    # shellcheck disable=SC2086
    dnf -y install $deps
  fi

  # shellcheck disable=SC2181
  if [[ $? -ne 0 ]] ; then
    exit 1
  fi

  separator
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

  show "${CL_BL_CYAN}Installing Oh My Zsh…${CL_NORM}"

  separator

  if ! sh -c "$(curl -fsSL "$OMZ_INSTALL") --unattended" ; then
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

# Create backup
#
# Code: No
# Echo: No
doBackup() {
  if isCodespaces ; then
    return
  fi

  local file_list ts output
  file_list=$(getBackupFiles)

  if [[ -z "$file_list" ]] ; then
    return
  fi

  ts=$(date '+%Y%m%d%H%M%S')
  output="$HOME/.andyone-dotfiles-${ts}.tar.bz2"

  pushd "$HOME" &> /dev/null || return
    # shellcheck disable=SC2086
    tar cjf "$output" $file_list &> /dev/null
    chmod 0600 "$output"
  popd &> /dev/null || return

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

  for file in "${themes[@]}" ; do
    if download "themes/$file" "$HOME/.oh-my-zsh" ; then
      showm "•" $GREEN
    else
      showm "•" $RED
      show " ERROR\n" $RED
      error "Can't download themes/$file"
      exit 1
    fi
  done

  for file in "${files[@]}" ; do
    if download "$file" "$HOME" ; then
      showm "•" $GREEN
    else
      showm "•" $RED
      show " ERROR\n" $RED
      error "Can't download $file"
      exit 1
    fi
  done

  show " ${CL_BL_GREEN}DONE${CL_NORM}"
}

# Collect list of files to backup
#
# Code: No
# Echo: List of files (String)
getBackupFiles() {
  local file_list

  for file in "${files[@]}" ; do
    if [[ -e $HOME/$file ]] ; then
      file_list+=("$file")
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
  http_code=$(curl -sL -m 10 -w "%{http_code}" -o "$dir/$name" "$REPOSITORY/${name}?r${rnd}")

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
  if ! type -P "$1" &> /dev/null ; then
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

# Print message
#
# 1: Message (String)
# 2: Color (Number) [Optional]
#
# Code: No
# Echo: No
show() {
  if [[ -n "$2" ]] ; then
    echo -e "\e[${2}m${1}\e[0m"
  else
    echo -e "$*"
  fi
}

# Print message without newline symbol
#
# 1: Message (String)
# 2: Color (Number) [Optional]
#
# Code: No
# Echo: No
showm() {
  if [[ -n "$2" ]] ; then
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
  local i sep cols

  cols=$(tput cols -T xterm-256color 2> /dev/null)

  for i in $(seq 1 "${cols:-80}") ; do
    sep="${sep}-"
  done

  show "\n$sep\n" $GREY
}

# Print error message
#
# 1: Error message (String)
#
# Code: No
# Echo: No
error() {
  show "▲ $*" $RED 1>&2
}

################################################################################

main "$@"
