#!/usr/bin/env bash
set -euo pipefail

print_provider_status() {
  local provider="$1"
  local available="$2"
  local model="$3"
  local source="$4"

  if [ -z "$model" ]; then
    model="-"
  fi

  printf '%-12s %-9s %-24s %s\n' "$provider" "$available" "$model" "$source"
}

main() {
  printf '%-12s %-9s %-24s %s\n' 'provider' 'available' 'model' 'source'
  printf '%-12s %-9s %-24s %s\n' '--------' '---------' '-----' '------'

  if [ -n "${GEMINI_API_KEY:-}" ]; then
    print_provider_status 'gemini' 'yes' "${GEMINI_MODEL:-}" 'GEMINI_API_KEY'
  else
    print_provider_status 'gemini' 'no' "${GEMINI_MODEL:-}" 'GEMINI_API_KEY'
  fi

  if [ -n "${OPENAI_API_KEY:-}" ]; then
    print_provider_status 'chatgpt' 'yes' "${OPENAI_MODEL:-}" 'OPENAI_API_KEY'
  else
    print_provider_status 'chatgpt' 'no' "${OPENAI_MODEL:-}" 'OPENAI_API_KEY'
  fi

  if command -v codex >/dev/null 2>&1; then
    print_provider_status 'codex-cli' 'yes' "${CODEX_CLI_MODEL:-}" "$(command -v codex)"
  else
    print_provider_status 'codex-cli' 'no' "${CODEX_CLI_MODEL:-}" 'PATH: codex'
  fi

  if command -v gemini >/dev/null 2>&1; then
    print_provider_status 'gemini-cli' 'yes' "${GEMINI_MODEL:-}" "$(command -v gemini)"
  else
    print_provider_status 'gemini-cli' 'no' "${GEMINI_MODEL:-}" 'PATH: gemini'
  fi
}

main "$@"
