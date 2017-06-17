#!/bin/bash

################################################################################

REPOSITORY="https://raw.githubusercontent.com/andyone/dotfiles/master/"

################################################################################

files=(".gitconfig" ".gitignore" ".rbdef" ".rpmmacros" ".tmux.conf" ".zshrc")
theme=("kaos-lite.zsh-theme" "kaos.zsh-theme")

################################################################################

main() {
  check
  doBackup
  doInstall
}

check() {
  local has_errors

  if [[ ! -e $HOME/.oh-my-zsh ]] ; then
    echo "oh-my-zsh is reqired"
    has_errors=true
  fi

  if ! isAppInstalled "zsh" ; then
    echo "zsh is reqired"
    has_errors=true
  fi

  if ! isAppInstalled "tmux" ; then
    echo "tmux is reqired"
    has_errors=true
  fi

  if ! isAppInstalled "git" ; then
    echo "git is reqired"
    has_errors=true
  fi

  if [[ $has_errors ]] ; then
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

  echo "Backup created as $output"
}

doInstall() {
  local file

  printf "Installing "

  for file in ${theme[@]} ; do
    download "themes/$file" "$HOME/.oh-my-zsh"
    printf "."
  done

  for file in ${files[@]} ; do
    download "$file" "$HOME"
    printf "."
  done

  echo " DONE"
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

################################################################################

main "$@"
