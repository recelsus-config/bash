# vim: ft=sh

ai_request_gemini() {
  local prompt="$1"
  local input="$2"

  if [ -z "${GEMINI_API_KEY:-}" ]; then
    printf "[FAIL] Please set GEMINI_API_KEY fi'st.\n" >&2
    return 1
  fi

  if [ -z "${GEMINI_MODEL:-}" ]; then
    printf "[FAIL] Please set GEMINI_MODEL o' pass -m/--model.\n" >&2
    return 1
  fi

  local model="${GEMINI_MODEL}"
  local url="https://generativelanguage.googleapis.com/v1beta/interactions"

  local payload
  payload=$(jq -n \
    --arg model "$model" \
    --arg prompt "$prompt" \
    --arg input "$input" \
    '{ model: $model,
       input: ($prompt + "\n\n" + $input)
    }'
  )

  curl --max-time "${GEMINI_TIMEOUT:-60}" -sS "$url" \
    -H 'Content-Type: application/json' \
    -H "x-goog-api-key: ${GEMINI_API_KEY}" \
    -X POST \
    -d "$payload" | jq -er '
      if .error.message then
        ("[FAIL] Gemini API: " + .error.message + "\n") | halt_error(1)
      else
        first(.steps[]? | select(.type == "model_output") | .content[]?.text) //
        .output_text //
        .output //
        .response.text //
        .candidates[0].content.parts[0].text
      end
    '
}

ai_request_openai() {
  local prompt="$1"
  local input="$2"

  if [ -z "${OPENAI_API_KEY:-}" ]; then
    printf "[FAIL] Please set OPENAI_API_KEY fi'st.\n" >&2
    return 1
  fi

  if [ -z "${OPENAI_MODEL:-}" ]; then
    printf "[FAIL] Please set OPENAI_MODEL o' pass -m/--model.\n" >&2
    return 1
  fi

  local base_url="${OPENAI_API_BASE:-https://api.openai.com/v1}"
  local model="${OPENAI_MODEL}"
  local endpoint="${base_url%/}/chat/completions"

  local payload
  payload=$(jq -n \
    --arg model "$model" \
    --arg prompt "$prompt" \
    --arg input "$input" \
    '{ model: $model,
       messages: [
         { role: "system", content: $prompt },
         { role: "user", content: $input }
       ]
     }'
  )

  if [ -n "${OPENAI_ORG_ID:-}" ]; then
    curl -sS "$endpoint" \
      -H 'Content-Type: application/json' \
      -H "Authorization: Bearer ${OPENAI_API_KEY}" \
      -H "OpenAI-Organization: ${OPENAI_ORG_ID}" \
      -X POST \
      -d "$payload" | jq -r '.choices[0].message.content'
  else
    curl -sS "$endpoint" \
      -H 'Content-Type: application/json' \
      -H "Authorization: Bearer ${OPENAI_API_KEY}" \
      -X POST \
      -d "$payload" | jq -r '.choices[0].message.content'
  fi
}

ai_request_codex_cli() {
  local prompt="$1"
  local input="$2"

  if ! command -v codex >/dev/null 2>&1; then
    printf "[FAIL] codex CLI not found in PATH.\n" >&2
    return 1
  fi

  local combined="${prompt}"$'\n\n'"${input}"
  local output_file
  output_file=$(mktemp "${TMPDIR:-/tmp}/ai-codex.XXXXXX")

  local args=(exec --skip-git-repo-check --sandbox read-only --color never -o "$output_file")
  if [ -n "${CODEX_CLI_MODEL:-}" ]; then
    args+=(-m "$CODEX_CLI_MODEL")
  fi

  if ! codex "${args[@]}" "$combined" >/dev/null; then
    rm -f "$output_file"
    return 1
  fi

  cat "$output_file"
  rm -f "$output_file"
}

ai_request_gemini_cli() {
  local prompt="$1"
  local input="$2"

  if ! command -v gemini >/dev/null 2>&1; then
    printf "[FAIL] gemini CLI not found in PATH.\n" >&2
    return 1
  fi

  local combined="${prompt}"$'\n\n'"${input}"
  local args=(--output-format text)
  if [ -n "${GEMINI_CLI_MODEL:-}" ]; then
    args+=(-m "$GEMINI_CLI_MODEL")
  fi

  gemini "${args[@]}" "$combined"
}

ai_request() {
  local prompt="$1"
  local input="$2"

  if [ -z "$prompt" ] || [ -z "$input" ]; then
    printf "Usage: ai_request <prompt> <input>\n"
    return 1
  fi

  local provider
  provider=$(printf '%s' "${AI_PROVIDER:-${DEFAULT_AI_PROVIDER:-}}" | tr '[:upper:]' '[:lower:]')

  if [ -z "$provider" ]; then
    printf "[FAIL] Please set DEFAULT_AI_PROVIDER o' pass -p/--provider.\n" >&2
    return 1
  fi

  case "$provider" in
    gemini)
      ai_request_gemini "$prompt" "$input"
      ;;
    chatgpt)
      ai_request_openai "$prompt" "$input"
      ;;
    codex-cli)
      ai_request_codex_cli "$prompt" "$input"
      ;;
    gemini-cli)
      ai_request_gemini_cli "$prompt" "$input"
      ;;
    *)
      printf "[FAIL] Unknown AI provideh: %s\n" "$provider" >&2
      return 1
      ;;
  esac
}

ai_request_with_model() {
  local provider="$1"
  local model="$2"
  local prompt="$3"
  local input="$4"

  case "$provider" in
    gemini)
      AI_PROVIDER="$provider" GEMINI_MODEL="$model" ai_request "$prompt" "$input"
      ;;
    chatgpt)
      AI_PROVIDER="$provider" OPENAI_MODEL="$model" ai_request "$prompt" "$input"
      ;;
    codex-cli)
      AI_PROVIDER="$provider" CODEX_CLI_MODEL="$model" ai_request "$prompt" "$input"
      ;;
    gemini-cli)
      AI_PROVIDER="$provider" GEMINI_CLI_MODEL="$model" ai_request "$prompt" "$input"
      ;;
    *)
      printf "[FAIL] Unknown AI provideh: %s\n" "$provider" >&2
      return 1
      ;;
  esac
}
