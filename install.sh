#!/bin/bash

################################################################################

REPOSITORY="https://raw.githubusercontent.com/andyone/dotfiles/master/"

################################################################################

files=(".gitconfig" ".gitignore" ".rbdef" ".rpmmacros" ".tmux.conf" ".zshrc")
theme=("kaos-lite.zsh-theme" "kaos.zsh-theme")

################################################################################

main() {
  doBackup
  doInstall
}

doBackup() {
  local file_list=$(getBackupFiles)

  if [[ -z "$file_list" ]] ; then
    return
  fi

  local ts=$(date '+%Y%m%d%H%M%S')

  tar cjf $HOME/.andyone-term-${ts}.tar.bz2 $file_list &> /dev/null
}

doInstall() {
  local file

  printf "Installing "

  if [[ -e $HOME/.oh-my-zsh ]] ; then
    for file in ${theme[@]} ; do
      download "$file" "$HOME/.oh-my-zsh/themes"
      printf "."
    done
  fi

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

################################################################################

main "$@"
