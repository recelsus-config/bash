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

  # Bidirectional JA<->EN translation with strict formatting preservation.
  local prompt="Translate between Japanese and English automatically.
Rules:
- Output only the translation text. No preface, notes, or pronunciations.
- Preserve line breaks, list markers, spacing, and markdown structure.
- Do NOT translate content inside fenced code blocks (```…```), inline code (`…`), HTML <code>…</code>, or URLs.
- Keep math, commands, and code tokens as-is.
- Prefer neutral tone and plain style. Avoid embellishment.
- For product or proper names, keep common exonyms or the original if unclear.
- When translating into Japanese, use です/ます調, natural punctuation（、。）; keep half-width ASCII for code/identifiers.
- Do not infer missing context; if a sentence is incomplete, translate faithfully without guessing."

  AI_PROVIDER="$provider" ai-request "$prompt" "$input"
}

