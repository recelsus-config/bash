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
Write a high-quality Git commit message for the staged unified diff.

Style and constraints:
- Prefer Conventional Commits if a clear type exists:
  feat|fix|docs|refactor|perf|test|chore|build|ci (optionally with scope).
  Example: fix(parser): handle empty tokens
- Subject line: imperative mood, concise, <= 72 characters, no trailing period.
- If helpful, add a short body after a blank line (1–3 lines) explaining rationale.
- Then add a brief per-file change list:
  - path/to/file: what changed (added/modified/removed/renamed) in 1 short phrase
- If there is any breaking change, include a final line:
  BREAKING CHANGE: <description>
- Wrap lines at ~72 columns.
- ASCII only. No backticks, no fenced blocks, no Markdown headings.
- Output only the commit message; no extra commentary.

Be specific but do not invent details that are not evident from the diff.
PROMPT
  )

  prompt+=$(ai_language_directive 'English' 'Japanese' "$@")

  AI_PROVIDER="$provider" git commit -t <(ai_request "$prompt" "$diff_output")
}

main "$@"
