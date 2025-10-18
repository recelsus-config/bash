# vim: ft=sh

aiq() {
  local provider
  provider=$(ai_resolve_provider "${AI_PROVIDER:-gemini}" "$@") || return 1

  local input=""
  if [ -t 0 ]; then
    input=$(ai_collect_positionals "$@")
  else
    input=$(cat)
  fi

  if [ -z "$input" ]; then
    printf "Usage: echo 'your question' | aiq  or  aiq your question\n"
    return 1
  fi

  local prompt="Answer the following question clearly and in a well-structured manner. Use plain and neutral language. Avoid unnecessary repetition. Please reply in Japanese."
  AI_PROVIDER="$provider" ai-request "$prompt" "$input"
}
