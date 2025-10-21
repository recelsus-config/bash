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
    printf "Usage:\n"
    printf "  echo 'bash command' | ai win -m ps\n"
    printf "  ai win -m ps 'bash command'\n"
    exit 1
  fi

  local prompt
  prompt=$(cat <<'PROMPT'
You are a converter from bash to Windows-native PowerShell.

INPUT:
- A single-line or short bash pipeline that runs on Linux/macOS.

OUTPUT:
- Print only the equivalent **PowerShell** command(s), ready to paste.
- No markdown fences, no explanations.
- Prefer core PowerShell cmdlets (Get-Content, Select-String, Get-ChildItem, Invoke-RestMethod, etc.).
- For JSON, prefer Invoke-RestMethod or ConvertFrom-Json rather than jq.
- For tail -f, use Get-Content -Wait.
- For grep-like, use Select-String.
- For find, prefer Get-ChildItem -Recurse with -Filter/-Include.
- For sed-like replacements, use -replace on strings.
- Preserve semantics as closely as possible (quotes, globs, recursion).

MISSING / EXTRA REQUIREMENTS:
- If an equivalent needs a non-built-in tool, append one or more lines at the end:
  '# Requires: <package-name>'
  Use well-known names, e.g. 'PowerShell 7', 'curl (Windows 10+ builtin)', '7-Zip', etc.
- If no realistic native PowerShell one-liner exists, output the closest multi-line PowerShell snippet.

Constraints:
- Do NOT execute anything.
- Output commands only (plus optional '# Requires:' lines).
PROMPT
  )

  AI_PROVIDER="$provider" ai_request "$prompt" "$input"
}

main "$@"
