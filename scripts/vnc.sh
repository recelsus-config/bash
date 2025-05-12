# vim: ft=sh

vnc() {
  local app

  if [ "$(uname -s)" = "Linux" ]; then
    app="/usr/bin/vncviewer"
  elif [ "$(uname -s)" = "Darwin" ]; then
    app='/Applications/VNC Viewer.app/Contents/MacOS/vncviewer'
  fi

  local target_host=$1
  local config_file="${HOME}/.ssh/vnc-config.json"

  if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please install it."
    return 1
  fi

  if [ ! -f "$config_file" ]; then
    echo "Config file not found: $config_file"
    return 1
  fi

  config=$(jq --arg target_host "$target_host" '.[] | select(.Name == $target_host)' "$config_file" | jq -s)

  if [ $(echo $config | jq length) -ne 1 ]; then
    echo "Multiple configrations found or No configuration found for target host: $target_host"
    return 1
  fi

  local host
  local name=$(echo $config | jq -r .[].Name)
  local port=$(echo $config | jq -r .[].Port)
  local type=$(echo "$config" | jq -r '
    if (.[0] | has("Via")) and (.[0] | has("Host")) then
      "error_both"
    elif (.[0] | has("Via")) then
      "via"
    elif (.[0] | has("Host")) then
      "host"
    else
      "error_none"
    end
  ')

  case "$type" in
    host)
      host=$(echo "$config" | jq -r '.[0].Host')
      "$app" "$host":$port --WarnUnencrypted=FALSE
      ;;
    via)
      host=$(echo "$config" | jq -r '.[0].Via')
      control_path="/tmp/vnc-ssh-$RAMDOM.sock"

      ssh -M -S "$control_path" -f -N $host -L 5900:localhost:$port
      "$app" localhost:5900 --WarnUnencrypted=FALSE
      ssh -S "$control_path" -O exit "$host"
      ;;
    error_both | error_none)
      echo "Error: $type"
      return 1
      ;;
  esac

  return 0
}

_vnc_completion() {
  local config_file="${HOME}/.ssh/vnc-config.json"
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  if [[ "$prev" == "vnc" ]]; then
    local names
    names=$(jq -r '.[].Name' $config_file 2>/dev/null)
    COMPREPLY=( $(compgen -W "$names" -- "$cur") )
  fi
}

complete -F _vnc_completion vnc

