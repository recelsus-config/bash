#!/usr/bin/env bash
set -euo pipefail

script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ai_root="$(cd "${script_path}/.." && pwd)"

source "${ai_root}/lib/common.sh"
source "${ai_root}/lib/request.sh"

main() {
  local provider
  provider=$(ai_resolve_provider "${AI_PROVIDER:-${DEFAULT_AI_PROVIDER:-}}" "$@") || exit 1
  local model
  model=$(ai_resolve_model "$provider" "$@") || exit 1
  local target_shell
  target_shell=$(ai_resolve_to "$@") || exit 1

  local input=""
  local positional=""
  positional=$(ai_collect_positionals "$@")
  if [ -n "$positional" ]; then
    input="$positional"
  elif [ ! -t 0 ]; then
    input=$(cat)
  fi

  if [ -z "$input" ]; then
    printf "Usage: echo 'ask' | ai cmd  or  ai cmd 'How do I ...?'\n"
    exit 1
  fi

  local target_name="POSIX sh"
  local shell_rules
  case "$(printf '%s' "$target_shell" | tr '[:upper:]' '[:lower:]')" in
    ""|sh|shell|posix|posix-sh)
      target_name="POSIX sh"
      shell_rules="- Prefer portable POSIX sh syntax and widely available core utilities."
      ;;
    win|windows|ps|powershell)
      target_name="PowerShell"
      shell_rules="- Prefer built-in PowerShell cmdlets and Windows-native commands."
      ;;
    cmd|win-cmd|cmd.exe)
      target_name="cmd.exe"
      shell_rules="- Prefer built-in cmd.exe syntax and Windows-native commands."
      ;;
    *)
      printf '[FAIL] Unknown cmd target: %s\n' "$target_shell" >&2
      exit 1
      ;;
  esac

  local prompt
  prompt=$(cat <<PROMPT
You are a seasoned command-line expert.
Return the best ${target_name} command(s) for the user's input.

The input may be either:
- a natural-language task description, such as "list directory"; or
- an existing command to translate, explain through conversion, or adapt, such as "ls".

Use your judgement to determine which case applies.

Rules:
- Output command lines only. No explanations, comments, or markdown.
${shell_rules}
- Chain multiple steps with '&&' or newlines.
- Never include destructive operations (rm, sudo, etc.) unless the user explicitly requests them.
- If the goal is best served by an existing helper (git, grep, etc.), use it directly.
- When uncertainty remains, choose the least harmful, most inspectable command.
PROMPT
  )

  ai_request_with_model "$provider" "$model" "$prompt" "$input"
}

main "$@"
