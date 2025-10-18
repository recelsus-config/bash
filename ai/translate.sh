# vim: ft=sh

aitrans() {
  local provider
  provider=$(ai_resolve_provider "${AI_PROVIDER:-gemini}" "$@") || return 1

  local input=""
  if [ -t 0 ]; then
    input=$(ai_collect_positionals "$@")
  else
    input=$(cat)
  fi

  if [ -z "$input" ]; then
    printf "Usage: echo 'text' | aitrans  or  aitrans your text\n"
    return 1
  fi

  local prompt="If the text is in Japanese, translate it into English. If the text is in English, translate it into Japanese. Do not include pronunciation guides or transliterations."
  AI_PROVIDER="$provider" ai-request "$prompt" "$input"
}
