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

  # English prompt, but ask the assistant to reply in Japanese.
  local prompt="You are a concise, structured expert assistant.
Answer the user's question in **Japanese** with clear structure and minimal verbosity.

Output format:
1) Overview (1–3 lines)
2) Details (only what is necessary)
3) Steps (numbered, only if needed)
4) Cautions (assumptions, pitfalls, limitations)

Rules:
- Use plain, neutral Japanese. Avoid fluff, repetition, and self-reference.
- If unsure, state it explicitly (e.g., 「Unknown」「Unconfirmed」) rather than guessing.
- Provide code examples only when truly helpful, minimal and runnable.
- In code examples, use snake_case for identifiers and write comments in English (non-rhotic).
- Prefer lists over long paragraphs when appropriate."

  AI_PROVIDER="$provider" ai-request "$prompt" "$input"
}

