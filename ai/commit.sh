# vim: ft=sh

aicommit() {
  local provider
  provider=$(ai_resolve_provider "${AI_PROVIDER:-gemini}" "$@") || return 1

  local diff_output
  diff_output=$(git diff --staged)

  if [ -z "$diff_output" ]; then
    printf 'No staged change seen.\n'
    return 1
  fi

  local prompt
  prompt=$(cat <<'PROMPT'
Write a commit message for the following diff.
Format:
1. 1-3 lines summary
2. Edited files with changes (bullet list)

Example:
Updated xxx, fixed yyy, added zzz.

- xxx.cpp: fixed A, changed request()
- yyy.hpp: fixed response
- zzz.md: added doc

Note: The output will be directly used as a commit message, so do not include any backticks ``` , blocks, or any responses unrelated to the commit message. Only include the commit message itself.
PROMPT
  )

  prompt+=$(ai_language_directive 'English' 'Japanese' "$@")

  AI_PROVIDER="$provider" git commit -t <(ai-request "$prompt" "$diff_output")
}
