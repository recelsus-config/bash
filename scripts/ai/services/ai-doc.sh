#!/usr/bin/env bash
set -euo pipefail

script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ai_root="$(cd "${script_path}/.." && pwd)"

source "${ai_root}/lib/common.sh"
source "${ai_root}/lib/request.sh"

main() {
  local provider
  provider=$(ai_resolve_provider "${AI_PROVIDER:-gemini}" "$@") || exit 1

  local args=("$@")
  local input=""
  local positional=""

  positional=$(ai_collect_positionals "${args[@]}")
  if [ -n "$positional" ]; then
    input="$positional"
  elif [ ! -t 0 ]; then
    input=$(cat)
  fi

  if [ -z "$input" ]; then
    printf "Usage: echo 'your code' | ai doc [-l lang]  or  ai doc [-l lang] 'code string'\n"
    printf "Hint: ai doc -m full switches to full-file mode.\n"
    exit 1
  fi

  local prompt
  prompt=$(cat <<'PROMPT'
You will receive a short source snippet (often a single function or small module). Generate brief, developer-oriented documentation strictly grounded in the code.

Output format (markdown):
## About `<symbol>`
- 1–2 lines describing what it does, based only on the code.

### Signature
- Language-appropriate signature (if inferable).

### Parameters
- List each parameter with type/role (only if visible in code).

### Returns
- What is returned and when (only if visible).

### Side Effects / Errors
- Notable I/O, state changes, exceptions, exit codes (only if visible).

### Usage
- One minimal example (command or call). Keep code under 10 lines.

Rules:
- Do not speculate beyond what the code shows. If uncertain, omit.
- Preserve identifiers and code tokens exactly; do not rename anything.
- Keep it concise; avoid boilerplate and marketing language.
- No language switch: follow caller's language directive externally.
- No front matter, no extra sections beyond the template above.
- Do not restate large code blocks; quote minimally when necessary.
- Prefer snake_case in examples; comments in English, non-rhotic.
PROMPT
  )

  prompt+=$(ai_language_directive '' 'Japanese' "${args[@]}")
  AI_PROVIDER="$provider" ai_request "$prompt" "$input"
}

main "$@"
