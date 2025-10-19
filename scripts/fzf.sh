# vim: ft=sh

fcd() {
  local start_dir current out key selection parent

  start_dir=$(cd "${1:-.}" 2>/dev/null && pwd -P) || return
  current=$start_dir

  while true; do
    parent=$(dirname "$current")

    local -a entries
    entries=()
    entries+=("$current")
    if [[ "$parent" != "$current" ]]; then
      entries+=("$parent")
    fi
    while IFS= read -r path; do
      entries+=("$path")
    done < <(find "$current" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | sort)

    if [[ ${#entries[@]} -eq 0 ]]; then
      return
    fi

    out=$(printf '%s\n' "${entries[@]}" |
      fzf --expect=enter,ctrl-f,ctrl-u \
          --header="current: $current (Enter=select, Ctrl-F=open, Ctrl-U=up)" \
          --preview 'bash -c '"'"'ls -a -- "$1"'"'"' _ {}' \
          --preview-window=right:50%:wrap) || return

    key=${out%%$'\n'*}
    selection=${out#*$'\n'}
    if [[ $key == "$out" ]]; then
      selection=""
    fi

    case "$key" in
      ctrl-u)
        if [[ "$parent" != "$current" ]]; then
          current=$parent
        fi
        ;;
      ctrl-f)
        if [[ -n $selection ]]; then
          current=$selection
        fi
        ;;
      enter|"")
        if [[ -n $selection ]]; then
          cd "$selection"
        else
          cd "$current"
        fi
        return
        ;;
      *)
        if [[ -n $selection ]]; then
          cd "$selection"
          return
        fi
        ;;
    esac
  done
}

