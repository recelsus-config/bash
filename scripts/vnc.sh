#!/usr/bin/env bash

show_usage() {
  cat <<'USAGE'
Usage: vnc [options] <host alias>

Options:
  -p PORT      Override SSH server port
  -P PORT      Override remote VNC port (default 5900)
  -L PORT      Override local forward port (default 5900)
  -J JUMPS     ProxyJump hosts (comma separated)
  -h           Show this help and exit

Examples:
  vnc target
  vnc -p 2222 target
  vnc target -P 6000
  vnc target -P 6000 -J bastion1
USAGE
}

resolve_viewer_path() {
  local kernel_name
  kernel_name=$(uname -s)
  if [[ "$kernel_name" == "Darwin" ]]; then
    printf '/Applications/VNC Viewer.app/Contents/MacOS/vncviewer'
  elif [[ "$kernel_name" == "Linux" ]]; then
    printf '/usr/bin/vncviewer'
  else
    printf '/usr/bin/vncviewer'
  fi
}

parse_ssh_config() {
  local host_alias=$1
  local -a ssh_args
  ssh_args=("-G")
  if [[ -n ${user_proxy_jump:-} ]]; then
    ssh_args+=("-J" "$user_proxy_jump")
  fi
  if [[ -n ${user_port_override:-} ]]; then
    ssh_args+=("-p" "$user_port_override")
  fi
  ssh_args+=("$host_alias")
  if ! ssh_config_output=$(ssh "${ssh_args[@]}" 2>/dev/null); then
    echo "Error: failed to resolve host via ssh config: ${host_alias}" >&2
    return 1
  fi
}

extract_config_value() {
  local key=$1
  printf '%s\n' "$ssh_config_output" | awk -v target="$key" 'tolower($1)==tolower(target){val=$2} END{if(length(val))print val}'
}

cleanup_ssh() {
  if [[ -n ${control_path:-} && -S ${control_path:-/dev/null} ]]; then
    ssh -S "$control_path" -O exit "$control_host_alias" >/dev/null 2>&1 || true
  fi
  if [[ -n ${control_path:-} ]]; then
    rm -f "$control_path"
  fi
}

vnc_main() {
  local host_alias=""
  local use_help=false
  local local_port=5900
  local extra_args=()
  user_port_override=""
  user_proxy_jump=""
  local remote_port_override=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h)
        use_help=true
        shift
        ;;
      -p)
        if [[ $# -lt 2 ]]; then
          echo "Error: option -p requires an argument" >&2
          return 1
        fi
        user_port_override=$2
        shift 2
        ;;
      -P)
        if [[ $# -lt 2 ]]; then
          echo "Error: option -P requires an argument" >&2
          return 1
        fi
        remote_port_override=$2
        shift 2
        ;;
      -L)
        if [[ $# -lt 2 ]]; then
          echo "Error: option -L requires an argument" >&2
          return 1
        fi
        local_port=$2
        shift 2
        ;;
      -J)
        if [[ $# -lt 2 ]]; then
          echo "Error: option -J requires an argument" >&2
          return 1
        fi
        user_proxy_jump=$2
        shift 2
        ;;
      --)
        shift
        while [[ $# -gt 0 ]]; do
          extra_args+=("$1")
          shift
        done
        ;;
      -*)
        echo "Error: unsupported option: $1" >&2
        return 1
        ;;
      *)
        if [[ -z "$host_alias" ]]; then
          host_alias=$1
        else
          extra_args+=("$1")
        fi
        shift
        ;;
    esac
  done

  if $use_help; then
    show_usage
    return 0
  fi

  if [[ -z "$host_alias" ]]; then
    echo "Error: host alias is required" >&2
    return 1
  fi

  if [[ ${#extra_args[@]} -gt 0 ]]; then
    echo "Error: unsupported extra arguments: ${extra_args[*]}" >&2
    return 1
  fi

  parse_ssh_config "$host_alias"

  local ssh_hostname
  ssh_hostname=$(extract_config_value hostname)
  if [[ -z "$ssh_hostname" ]]; then
    echo "Error: failed to resolve hostname" >&2
    return 1
  fi

  local ssh_port
  ssh_port=$(extract_config_value port)
  local proxyjump_config
  proxyjump_config=$(extract_config_value proxyjump)

  local ssh_port_effective
  if [[ -n "$user_port_override" ]]; then
    ssh_port_effective=$user_port_override
  else
    ssh_port_effective=${ssh_port:-22}
  fi

  local proxy_jump_effective
  local remote_port_effective
  if [[ -n "$user_proxy_jump" ]]; then
    proxy_jump_effective=$user_proxy_jump
  else
    if [[ "$proxyjump_config" == "none" ]]; then
      proxy_jump_effective=""
    else
      proxy_jump_effective=$proxyjump_config
    fi
  fi

  if [[ -n "$remote_port_override" ]]; then
    remote_port_effective=$remote_port_override
  else
    remote_port_effective=5900
  fi


  local viewer_path
  viewer_path=$(resolve_viewer_path)

  local viewer_target
  local control_needed=false

  trap cleanup_ssh EXIT
  control_path=""
  control_host_alias=$host_alias

  if [[ -n "$proxy_jump_effective" ]]; then
    control_path=$(mktemp /tmp/vnc-ssh.XXXXXX)
    rm -f "$control_path"
    control_needed=true
    local remote_vnc_port=$remote_port_effective
    local ssh_command=(ssh -M -S "$control_path" -f -N -L "${local_port}:localhost:${remote_vnc_port}")
    if [[ -n "$user_port_override" ]]; then
      ssh_command+=("-p" "$ssh_port_effective")
    fi
    if [[ -n "$user_proxy_jump" ]]; then
      ssh_command+=("-J" "$user_proxy_jump")
    elif [[ -n "$proxy_jump_effective" ]]; then
      ssh_command+=("-J" "$proxy_jump_effective")
    fi
    ssh_command+=("$host_alias")
    local ssh_command_display=""
    printf -v ssh_command_display "%s " "${ssh_command[@]}"
    ssh_command_display=${ssh_command_display%% }
    echo "Opening SSH tunnel: ${ssh_command_display}"
    "${ssh_command[@]}"
    echo "Sleeping for 1s before launching viewer"
    sleep 1
    viewer_target="localhost:${local_port}"
  else
    viewer_target="${ssh_hostname}:${remote_port_effective}"
  fi

  echo "Launching viewer: ${viewer_path} ${viewer_target} --WarnUnencrypted=FALSE"
  "$viewer_path" "$viewer_target" --WarnUnencrypted=FALSE

  if [[ "$control_needed" == true ]]; then
    cleanup_ssh
  fi
  trap - EXIT
}


vnc() {
  local shell_opts status
  shell_opts=$(set +o)
  set -euo pipefail
  if ! vnc_main "$@"; then
    status=$?
  else
    status=0
  fi
  eval "$shell_opts"
  return $status
}
