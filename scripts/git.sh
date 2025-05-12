# vim: ft=sh

git-update() {
  OLDPATH=$(pwd)

  directories=(
    "$HOME/.vim"
    "$HOME/.config/nvim"
    "$HOME/.config/tmux"
    "$HOME/.config/aichat"
    "$HOME/.config/bash"
    "$HOME/.config/ghostty"
    "$HOME/.config/i3"
    "$HOME/.config/aerospace"
    "$HOME/.config/openbox"
  )

  for dir in "${directories[@]}"; do
    if [ -d "$dir/.git" ]; then
      echo "Pulling $dir directory..."
      cd "$dir" || exit
      git pull
      echo
    else
      echo "$dir is not a git repository."
      echo
    fi
  done

  cd "$OLDPATH" || exit
  echo "Git pull operations completed."
}

