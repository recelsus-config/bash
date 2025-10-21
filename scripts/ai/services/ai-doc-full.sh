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
    printf "Usage: cat file.ts | ai doc -m full [-l lang]  or  ai doc -m full [-l lang] 'source code string'\n"
    exit 1
  fi

  local prompt
  prompt=$(cat <<'PROMPT'
You are given a source file (or a small concatenated snippet). Infer a concise, developer-friendly README that reflects only what the code actually shows.

Output format (markdown):
# Overview
- 2–3 lines describing what the program does, based on main logic and imports.

## Architecture
- Brief text summary of structure (entry points, key modules/functions). No diagrams.

## Features
- Bullet list of capabilities observed in the code (CLI, HTTP, DB, scraping, etc.).

## Usage
- Minimal run example(s). For CLI, show one command; for libraries, show a short call.
- Keep each code block under 10 lines.

## Configuration
- Environment variables, flags, config files actually referenced (names only).

## Dependencies
- Notable third-party modules/frameworks inferred from imports/import-like statements.

## Limitations
- Constraints or missing pieces visible in code (e.g., TODOs, unhandled errors). If none, state "None".

Rules:
- No speculation beyond the code. If something is unclear, omit it rather than guessing.
- Preserve identifiers and API names exactly as in code.
- Keep it succinct; no boilerplate sections beyond the template above.
- Do not invent installation steps, licenses, or version numbers.
- No language switch: follow caller's language directive externally.
- Comments in examples should be English, non-rhotic; prefer snake_case.
PROMPT
  )

  prompt+=$(ai_language_directive '' 'Japanese' "${args[@]}")
  AI_PROVIDER="$provider" ai_request "$prompt" "$input"
}

main "$@"
