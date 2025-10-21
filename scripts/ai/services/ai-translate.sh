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
    printf "Usage: echo 'text' | ai translate  or  ai translate your text\n"
    exit 1
  fi

  local prompt
  prompt=$(cat <<'PROMPT'
Translate between Japanese and English automatically.
Rules:
- Output only the translation text. No preface, notes, or pronunciations.
- Preserve line breaks, list markers, spacing, and markdown structure.
- Do NOT translate content inside fenced code blocks (```…```), inline code (`…`), HTML <code>…</code>, or URLs.
- Keep math, commands, and code tokens as-is.
- Prefer neutral tone and plain style. Avoid embellishment.
- For product or proper names, keep common exonyms or the original if unclear.
- When translating into Japanese, use です/ます調, natural punctuation（、。）; keep half-width ASCII for code/identifiers.
- Do not infer missing context; if a sentence is incomplete, translate faithfully without guessing.
PROMPT
  )

  AI_PROVIDER="$provider" ai_request "$prompt" "$input"
}

main "$@"
