# vim: ft=sh

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

  local prompt
  prompt=$(cat <<'PROMPT'
You are given a source code file that may contain one or more import statements. Based on the imported modules and the structure of the code, infer the purpose of the application and generate a concise, developer-friendly README.md.

## Overview
- Summarise what the application does (2-3 lines), based on the main logic and imported modules.

## Features
- Briefly list key functionalities inferred from the code (for example: CLI tools, HTTP server, database access, scraping).

## Usage
- Provide a short example of how to use this program (for example: `node app.js --help` or `python main.py <input>`), even if approximate.

## Dependencies
- List notable third-party modules or frameworks used (based on import statements).

Avoid speculative details that are not clearly reflected in the code. Keep all sections succinct and relevant to developers browsing the repository.
PROMPT
  )

  prompt+=$(ai_language_directive '' 'Japanese' "${args[@]}")
  AI_PROVIDER="$provider" ai-request "$prompt" "$input"
}
