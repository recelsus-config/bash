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
    printf "  echo 'bash command' | ai win -m cmd\n"
    printf "  ai win -m cmd 'bash command'\n"
    exit 1
  fi

  local prompt
  prompt=$(cat <<'PROMPT'
You are a converter from bash to Windows-native cmd.exe (Command Prompt).

INPUT:
- A single-line or short bash pipeline that runs on Linux/macOS.

OUTPUT:
- Print only the equivalent **cmd.exe** command(s), ready to paste.
- No markdown fences, no explanations.
- Prefer built-in cmd tools: type, more, dir, copy, move, del, rmdir, for /f, set, findstr, certutil, tar (Windows 10+), powershell.exe if strictly necessary.
- Keep quoting compatible with cmd (use double quotes, percent variables like %VAR%).

FALLBACKS AND REQUIREMENTS:
- cmd lacks many Unix tools (awk/sed/jq/xargs/etc.). If the bash command relies on such tools and there is no sane pure-cmd equivalent, do ONE of the following:
  1) Provide a pragmatic pure-cmd workaround if possible (e.g., 'findstr', 'for /f', 'certutil -decode', 'tar').
  2) Otherwise, provide a one-liner that shells out to PowerShell via: powershell -NoProfile -Command "...".
- Whenever a non-built-in tool is required, append one or more lines at the end:
  '# Requires: <package-name>'
  Use recognisable names only, e.g.:
    - 'GnuWin32 sed' (sed)
    - 'GnuWin32 awk' (awk)
    - 'Git for Windows (GNU tools)' (collection of grep/sed/awk)
    - 'curl (Windows 10+ builtin)'
    - '7-Zip' (7z)
    - 'PowerShell' (if you used powershell.exe)
- Keep the main command minimal and paste-ready. Do not explain.

Constraints:
- Do NOT execute anything.
- Output commands only (plus optional '# Requires:' lines).
PROMPT
  )

  AI_PROVIDER="$provider" ai_request "$prompt" "$input"
}

main "$@"
