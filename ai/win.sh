# vim: ft=sh

# aips: translate a bash command into a Windows-native PowerShell command.
aips() {
  local provider
  provider=$(ai_resolve_provider "${AI_PROVIDER:-gemini}" "$@") || return 1

  local input=""
  if [ -t 0 ]; then
    input=$(ai_collect_positionals "$@")
  else
    input=$(cat)
  fi

  if [ -z "$input" ]; then
    printf "Usage:\n"
    printf "  echo 'bash command' | aips\n"
    printf "  aips 'bash command'\n"
    return 1
  fi

  # Prompt: bash -> PowerShell. Output only commands, plus optional '# Requires:' lines.
  local prompt="
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
"

  AI_PROVIDER="$provider" ai-request "$prompt" "$input"
}

# aicmd: translate a bash command into a Windows-native cmd.exe command.
aicmd() {
  local provider
  provider=$(ai_resolve_provider "${AI_PROVIDER:-gemini}" "$@") || return 1

  local input=""
  if [ -t 0 ]; then
    input=$(ai_collect_positionals "$@")
  else
    input=$(cat)
  fi

  if [ -z "$input" ]; then
    printf "Usage:\n"
    printf "  echo 'bash command' | aicmd\n"
    printf "  aicmd 'bash command'\n"
    return 1
  fi

  # Prompt: bash -> cmd.exe. If not feasible, provide best-effort and list required packages.
  local prompt="
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
  2) Otherwise, provide a one-liner that shells out to PowerShell via: powershell -NoProfile -Command \"...\".
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
"

  AI_PROVIDER="$provider" ai-request "$prompt" "$input"
}

