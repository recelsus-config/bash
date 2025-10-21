# vim: ft=sh

aidoc() {
  local provider
  provider=$(ai_resolve_provider "${AI_PROVIDER:-gemini}" "$@") || return 1

  local args=("$@")
  local input=""

  if [ -t 0 ]; then
    input=$(ai_collect_positionals "${args[@]}")
  else
    input=$(cat)
  fi

  if [ -z "$input" ]; then
    printf "Usage: echo 'your code' | aidoc [-l]  or  aidoc [-l] 'code string'\n"
    return 1
  fi

  # Developer-facing, concise doc generator for a single function/module snippet.
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
  AI_PROVIDER="$provider" ai-request "$prompt" "$input"
}

aidoc-full() {
  local provider
  provider=$(ai_resolve_provider "${AI_PROVIDER:-gemini}" "$@") || return 1

  local args=("$@")
  local input=""

  if [ -t 0 ]; then
    input=$(ai_collect_positionals "${args[@]}")
  else
    input=$(cat)
  fi

  if [ -z "$input" ]; then
    printf "Usage: cat file.ts | aidoc-full [-l]  or  aidoc-full [-l] 'source code string'\n"
    return 1
  fi

  # README-style summariser for a single-file program or small codebase.
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
  AI_PROVIDER="$provider" ai-request "$prompt" "$input"
}


