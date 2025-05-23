# vim: ft=sh

git-update() {
  OLDPATH=$(pwd)

  directories=(
    "$HOME/.vim"
    "$HOME/.config/nvim"
    "$HOME/.config/tmux"
    "$HOME/.config/bash"
    "$HOME/.config/ghostty"
    "$HOME/.config/i3"
    "$HOME/.config/aerospace"
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

git-clone() {
  if [ -z "$GITHUB_TOKEN" ] || [ -z "$GITHUB_USER" ]; then
    echo "[ERROR] GITHUB_TOKEN or GITHUB_USER is not set." >&2
    return 1
  fi

  local user="${GITHUB_USER//\"/}"
  local token="${GITHUB_TOKEN//\"/}"

  local repo_url="$1"
  local auth_url=""

  if [[ "$repo_url" =~ ^https://github\.com/ ]]; then
    auth_url="https://${user}:${token}@${repo_url#https://}"

  elif [[ "$repo_url" =~ ^git@github\.com: ]]; then
    local path="${repo_url#git@github.com:}"
    auth_url="https://${user}:${token}@github.com/${path}"

  else
    echo "[ERROR] Unsupported URL format: $repo_url" >&2
    return 2
  fi

  git clone "$auth_url"
  unset auth_url
}

git-identity() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "[ERROR] This is not a git repository." >&2
    return 1
  fi

  if [ -z "$GITHUB_USER" ] || [ -z "$GITHUB_EMAIL" ]; then
    echo "[ERROR] GITHUB_USER or GITHUB_EMAIL is not set." >&2
    return 1
  fi

  local user="${GITHUB_USER//\"/}"
  local email="${GITHUB_EMAIL//\"/}"

  git config user.name "$user"
  git config user.email "$email"

  echo "[INFO] Set git user.name to '$user'"
  echo "[INFO] Set git user.email to '$email'"
}

