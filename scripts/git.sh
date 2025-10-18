# vim: ft=sh

git-update() {
  local old_path
  old_path=$(pwd)

  local directories=(
    "$HOME/.vim"
    "$HOME/.config/nvim"
    "$HOME/.config/tmux"
    "$HOME/.config/bash"
    "$HOME/.config/ghostty"
    "$HOME/.config/i3"
    "$HOME/.config/aerospace"
  )

  local targets=()

  if [ "$#" -eq 0 ]; then
    targets=("${directories[@]}")
  else
    local matched=()
    for arg in "$@"; do
      local arg_found=0
      local normalized_arg=${arg#.}
      for dir in "${directories[@]}"; do
        local name
        name=$(basename "$dir")
        name=${name#.}
        if [ "$normalized_arg" = "$name" ]; then
          arg_found=1
          local seen=0
          for listed in "${matched[@]}"; do
            if [ "$listed" = "$dir" ]; then
              seen=1
              break
            fi
          done
          if [ "$seen" -eq 0 ]; then
            matched+=("$dir")
          fi
        fi
      done
      if [ "$arg_found" -eq 0 ]; then
        printf "[WARN] No match fo' %s\n" "$arg"
      fi
    done
    if [ "${#matched[@]}" -eq 0 ]; then
      printf "[FAIL] No known git site names given.\n" >&2
      cd "$old_path" || return 1
      return 1
    fi
    targets=("${matched[@]}")
  fi

  for dir in "${targets[@]}"; do
    if [ -d "$dir/.git" ]; then
      printf "Syncing %s...\n" "$dir"
      if cd "$dir"; then
        git pull
        printf "\n"
      else
        printf "[FAIL] Could not step into %s.\n" "$dir" >&2
        cd "$old_path" || return 1
        return 1
      fi
    else
      printf "No git data in %s.\n\n" "$dir"
    fi
  done

  cd "$old_path" || return 1
  printf "Git pull done.\n"
}

git-identity() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf "[FAIL] Not inside a git site.\n" >&2
    return 1
  fi

  if [ -z "$GITHUB_USER" ] || [ -z "$GITHUB_EMAIL" ]; then
    printf "[FAIL] Need GITHUB_USER and GITHUB_EMAIL.\n" >&2
    return 1
  fi

  local user
  local email

  user=$(printf '%s' "$GITHUB_USER" | tr -d '\"')
  email=$(printf '%s' "$GITHUB_EMAIL" | tr -d '\"')

  git config user.name "$user"
  git config user.email "$email"

  printf "[INFO] Set git user.name to '%s'\n" "$user"
  printf "[INFO] Set git user.email to '%s'\n" "$email"
}
