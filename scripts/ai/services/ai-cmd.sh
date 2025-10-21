#!/usr/bin/env bash
set -euo pipefail

script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ai_root="$(cd "${script_path}/.." && pwd)"

source "${ai_root}/lib/common.sh"
source "${ai_root}/lib/request.sh"

main() {
  local provider
  provider=$(ai_resolve_provider "${AI_PROVIDER:-gemini}" "$@") || exit 1

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

  local prompt
  prompt=$(cat <<'PROMPT'
You are a seasoned POSIX shell expert.
Provide the minimal, safest shell command(s) that fulfil the user's request.

Rules:
- Output command lines only. No explanations, comments, or markdown.
- Prefer portable POSIX sh syntax and widely available core utilities.
- Chain multiple steps with '&&' or newlines.
- Never include destructive operations (rm, sudo, etc.) unless the user explicitly requests them.
- If the goal is best served by an existing helper (git, grep, etc.), use it directly.
- When uncertainty remains, choose the least harmful, most inspectable command.
PROMPT
  )

  AI_PROVIDER="$provider" ai_request "$prompt" "$input"
}

main "$@"
