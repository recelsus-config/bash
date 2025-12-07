# vim: ft=sh

ai_request_gemini() {
  local prompt="$1"
  local input="$2"

  if [ -z "$GEMINI_API_KEY" ]; then
    printf "[FAIL] Please set GEMINI_API_KEY fi'st.\n" >&2
    return 1
  fi

  local model="${GEMINI_MODEL:-gemini-2.5-flash}"
  local url="https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${GEMINI_API_KEY}"

  local payload
  payload=$(jq -n \
    --arg prompt "$prompt" \
    --arg input "$input" \
    '{ contents: [
        { role: "user", parts: [{ text: $prompt }] },
        { role: "user", parts: [{ text: $input }] }
      ]
    }'
  )

  curl -sS "$url" \
    -H 'Content-Type: application/json' \
    -X POST \
    -d "$payload" | jq -r '.candidates[0].content.parts[0].text'
}

ai_request_openai() {
  local prompt="$1"
  local input="$2"

  if [ -z "$OPENAI_API_KEY" ]; then
    printf "[FAIL] Please set OPENAI_API_KEY fi'st.\n" >&2
    return 1
  fi

  local base_url="${OPENAI_API_BASE:-https://api.openai.com/v1}"
  local model="${OPENAI_MODEL:-gpt-4o-mini}"
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

  if [ -n "$OPENAI_ORG_ID" ]; then
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

ai_request() {
  local prompt="$1"
  local input="$2"

  if [ -z "$prompt" ] || [ -z "$input" ]; then
    printf "Usage: ai_request <prompt> <input>\n"
    return 1
  fi

  local provider
  provider=$(printf '%s' "${AI_PROVIDER:-gemini}" | tr '[:upper:]' '[:lower:]')

  case "$provider" in
    gemini)
      ai_request_gemini "$prompt" "$input"
      ;;
    openai|chatgpt)
      ai_request_openai "$prompt" "$input"
      ;;
    *)
      printf "[FAIL] Unknown AI provideh: %s\n" "$provider" >&2
      return 1
      ;;
  esac
}
