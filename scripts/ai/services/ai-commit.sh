#!/usr/bin/env bash
set -euo pipefail

script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ai_root="$(cd "${script_path}/.." && pwd)"

source "${ai_root}/lib/common.sh"
source "${ai_root}/lib/request.sh"

show_usage() {
  cat <<'USAGE'
Usage: ai commit [options]

Options:
  -l, --language <lang>       Language override
  -p, --provider <provider>   AI provider (gemini, openai, chatgpt)
  -i, --ignore <path>         Omit a staged file from the diff sent to AI
  -id, --ignore-dir <path>    Omit staged files under a directory from the diff sent to AI
  --prompt <text>             Add an extra instruction for the commit message

Ignored files are still sent as name/status lines so the commit message can
mention that they were added, modified, deleted, or renamed.
-i, -id, and --prompt can be repeated.
USAGE
}

normalise_ai_commit_path() {
  local path="$1"
  path="${path#./}"
  path="${path%/}"
  printf '%s' "$path"
}

is_ai_commit_ignored_path() {
  local path="$1"
  shift

  local ignore_count="$1"
  shift

  local idx=0
  while [ $idx -lt "$ignore_count" ]; do
    if [ "$path" = "$1" ]; then
      return 0
    fi
    shift
    idx=$((idx + 1))
  done

  local ignore_dir
  for ignore_dir in "$@"; do
    if [ "$path" = "$ignore_dir" ] || [[ "$path" == "$ignore_dir/"* ]]; then
      return 0
    fi
  done

  return 1
}

format_ai_commit_status_line() {
  local status="$1"
  shift

  local change_type="$status"
  case "$status" in
    A)
      change_type="added"
      ;;
    M)
      change_type="modified"
      ;;
    D)
      change_type="deleted"
      ;;
    R*)
      change_type="renamed"
      ;;
    C*)
      change_type="copied"
      ;;
  esac

  if [ "$#" -ge 2 ]; then
    printf -- '- %s -> %s: %s\n' "$1" "$2" "$change_type"
  elif [ "$#" -eq 1 ]; then
    printf -- '- %s: %s\n' "$1" "$change_type"
  fi
}

main() {
  local provider
  provider=$(ai_resolve_provider "${AI_PROVIDER:-gemini}" "$@") || exit 1

  local ignore_paths=()
  local ignore_dirs=()
  local extra_prompts=()
  while [ $# -gt 0 ]; do
    case "$1" in
      -h|--help)
        show_usage
        return 0
        ;;
      -i|--ignore)
        local ignore_flag="$1"
        shift
        if [ $# -eq 0 ] || [[ "$1" = -* ]]; then
          printf '[FAIL] The %s flag expects a path.\n' "$ignore_flag" >&2
          exit 1
        fi
        ignore_paths+=("$(normalise_ai_commit_path "$1")")
        ;;
      -id|--ignore-dir)
        local ignore_dir_flag="$1"
        shift
        if [ $# -eq 0 ] || [[ "$1" = -* ]]; then
          printf '[FAIL] The %s flag expects a path.\n' "$ignore_dir_flag" >&2
          exit 1
        fi
        ignore_dirs+=("$(normalise_ai_commit_path "$1")")
        ;;
      --prompt)
        shift
        if [ $# -eq 0 ] || [[ "$1" = -* ]]; then
          printf '[FAIL] The --prompt flag expects text.\n' >&2
          exit 1
        fi
        extra_prompts+=("$1")
        ;;
    esac
    shift
  done

  local included_paths=()
  local omitted_paths=()
  local path
  while IFS= read -r -d '' path; do
    path=$(normalise_ai_commit_path "$path")
    if is_ai_commit_ignored_path "$path" "${#ignore_paths[@]}" "${ignore_paths[@]}" "${ignore_dirs[@]}"; then
      omitted_paths+=("$path")
    else
      included_paths+=("$path")
    fi
  done < <(git diff --staged --name-only -z)

  local diff_output
  if [ ${#included_paths[@]} -gt 0 ]; then
    diff_output=$(git diff --staged -- "${included_paths[@]}")
  else
    diff_output=""
  fi

  local omitted_output=""
  if [ ${#omitted_paths[@]} -gt 0 ]; then
    local status
    while IFS= read -r -d '' status; do
      if [[ "$status" = R* ]] || [[ "$status" = C* ]]; then
        local old_path
        local new_path
        IFS= read -r -d '' old_path
        IFS= read -r -d '' new_path
        omitted_output+="$(format_ai_commit_status_line "$status" "$old_path" "$new_path")"
        omitted_output+=$'\n'
      else
        local changed_path
        IFS= read -r -d '' changed_path
        omitted_output+="$(format_ai_commit_status_line "$status" "$changed_path")"
        omitted_output+=$'\n'
      fi
    done < <(git diff --staged --name-status -z -- "${omitted_paths[@]}")
  fi

  if [ -z "$diff_output" ] && [ -z "$omitted_output" ]; then
    printf 'No staged change seen.\n'
    exit 1
  fi

  if [ -n "$omitted_output" ]; then
    diff_output+=$'\n\n'
    diff_output+='Omitted staged files (diff content intentionally not sent):'
    diff_output+=$'\n'
    diff_output+="$omitted_output"
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

  if [ ${#extra_prompts[@]} -gt 0 ]; then
    prompt+=$'\n\nAdditional user instructions:\n'
    local extra_prompt
    for extra_prompt in "${extra_prompts[@]}"; do
      prompt+="$(printf -- '- %s\n' "$extra_prompt")"
    done
  fi

  AI_PROVIDER="$provider" git commit -t <(ai_request "$prompt" "$diff_output")
}

main "$@"
