# vim: ft=sh

aidoc() {
  local provider
  provider=$(ai_resolve_provider "${AI_PROVIDER:-gemini}" "$@") || return 1

  local args=("$@")
  local input=""

  if [ -t 0 ]; then
    input=$(ai_collect_positionals "${args[@]}")
  else
    input=$(cat)
  fi

  if [ -z "$input" ]; then
    printf "Usage: echo 'your code' | aidoc [-l]  or  aidoc [-l] 'code string'\n"
    return 1
  fi

  local prompt
  prompt=$(cat <<'PROMPT'
Given the following source code, generate documentation in the specified format. Keep explanations brief and clear. Focus on summarising what the code does, and provide a usage section. Use the following format:
## About the `xxx` Function
description (1-2 lines)
### Usage
- `command [options]`  # short comment explaining usage
PROMPT
  )

  prompt+=$(ai_language_directive '' 'Japanese' "${args[@]}")
  AI_PROVIDER="$provider" ai-request "$prompt" "$input"
}
