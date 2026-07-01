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
  local target_language
  target_language=$(ai_resolve_to "$@") || exit 1

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
  if [ -n "$target_language" ]; then
    local target_display
    target_display=$(ai_normalise_language_name "$target_language")
    prompt="Translate the input into ${target_display}."
    prompt+=$'\n'
    prompt+=$(cat <<'PROMPT'
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
  else
    prompt=$(cat <<'PROMPT'
Translate between Japanese and English automatically.
If the input is mainly Japanese, translate it into English.
If the input is mainly English or another language, translate it into Japanese.
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
  fi

  ai_request_with_model "$provider" "$model" "$prompt" "$input"
}

main "$@"
