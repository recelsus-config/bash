# vim: ft=sh

aidiff() {
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
Please analyse the following git diff and explain the changes in detail.
Format:
## Summary
- High-level summary of what was changed and why.

## Changes
- List each file with:
  - Purpose of change
  - What logic or behaviour was added, removed, or modified

Use plain, technical language.
Be concise but specific.
This is for a developer reviewing the code.
PROMPT
  )

  prompt+=$(ai_language_directive '' 'Japanese' "$@")
  AI_PROVIDER="$provider" ai-request "$prompt" "$diff_output"
}
