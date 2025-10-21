#!/usr/bin/env bash
set -euo pipefail

script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ai_root="$(cd "${script_path}/.." && pwd)"

source "${ai_root}/lib/common.sh"
source "${ai_root}/lib/request.sh"

main() {
  local provider
  provider=$(ai_resolve_provider "${AI_PROVIDER:-gemini}" "$@") || exit 1

  local diff_output
  diff_output=$(git diff --staged)

  if [ -z "$diff_output" ]; then
    printf 'No staged change seen.\n'
    exit 1
  fi

  local prompt
  prompt=$(cat <<'PROMPT'
You are a senior code reviewer. Analyze the following unified git diff (from `git diff --staged`) and produce a structured, developer-oriented review.

Output format:
## Summary
- 3–6 bullets that capture the intent and scope.

## Per-file Changes
- <path>:
  - change_type: added | modified | deleted | renamed
  - intent: what the change tries to achieve
  - key_edits: reference diff hunks (e.g., @@ -12,6 +12,8 @@) and describe logic added/removed/modified
  - risks_edge_cases: concrete pitfalls or regressions to watch for
  - perf_security: note any performance or security implications (only if applicable)

## Breaking_Changes
- List breaking API/CLI/behavior changes or say "None".

## Tests
- Test ideas (unit/integration/manual) that validate the change.

## Migration_Docs_TODO
- Required migrations, docs updates, or follow-ups.

Rules:
- Be concise but specific; do not restate large code blocks.
- Quote only minimal critical lines when necessary using fenced code blocks; keep each quoted snippet <= 5 lines.
- Prefer actionable language over generic advice.
- If something is unclear from the diff, state the assumption explicitly rather than guessing.
PROMPT
  )

  prompt+=$(ai_language_directive '' 'Japanese' "$@")
  AI_PROVIDER="$provider" ai_request "$prompt" "$diff_output"
}

main "$@"
