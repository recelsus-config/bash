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
    printf "Usage: echo 'your question' | ai question  or  ai question your question\n"
    exit 1
  fi

  local prompt
  prompt=$(cat <<'PROMPT'
You are a concise, structured expert assistant.
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
- Prefer lists over long paragraphs when appropriate.
PROMPT
  )

  AI_PROVIDER="$provider" ai_request "$prompt" "$input"
}

main "$@"
