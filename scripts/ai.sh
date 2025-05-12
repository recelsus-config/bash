# vim: ft=sh

##
# Request wrapper
##

ai-request() {
  local prompt="$1"
  local input="$2"

  if [ -z "$prompt" ] || [ -z "$input" ]; then
    echo "Usage: ai-request <prompt> <input>"
    return 1
  fi

  local json=$(jq -n \
    --arg prompt "$prompt" \
    --arg input "$input" \
    '{ contents: [
        { role: "user", parts: [{ text: $prompt }] },
        { role: "user", parts: [{ text: $input }] }
      ]
    }')

  curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}" \
    -H 'Content-Type: application/json' \
    -X POST \
    -d "$json" | jq -r '.candidates[0].content.parts[0].text'
}

##
# Commit message generator
##

# Shared commit prompt (English, base)
_ai_commit_prompt="Write a commit message for the following diff.

Format:
1. 1–3 lines summary
2. Edited files with changes (bullet list)

Example:
Updated xxx, fixed yyy, added zzz.

- xxx.cpp: fixed A, changed request()
- yyy.hpp: fixed response
- zzz.md: added doc
"

aicommit() {
  local input=$(git diff --staged)
  git commit -t <(ai-request "$_ai_commit_prompt" "$input")
}

aicommit-ja() {
  local input=$(git diff --staged)
  local prompt="$_ai_commit_prompt \n\n Please reply in Japanese."
  git commit -t <(ai-request "$prompt" "$input")
}

##
# Translate
##

aitrans() {
  local input=""
  if [ -t 0 ]; then
    input="$*"
  else
    input=$(cat)
  fi

  if [ -z "$input" ]; then
    echo "Usage: echo 'text' | aitrans  or  aitrans your text"
    return 1
  fi

  local prompt="If the text is in Japanese, translate it into English. If the text is in English, translate it into Japanese. Do not include pronunciation guides or transliterations."
  ai-request "$prompt" "$input"
}

##
# Question and Answer
##

aiq() {
  local input=""
  if [ -t 0 ]; then
    input="$*"
  else
    input=$(cat)
  fi

  if [ -z "$input" ]; then
    echo "Usage: echo 'your question' | aiq  or  aiq your question"
    return 1
  fi

  local prompt="Answer the following question clearly and in a well-structured manner. Use plain and neutral language. Avoid unnecessary repetition. Please reply in Japanese."
  ai-request "$prompt" "$input"
}

aidoc() {
  local input=""
  if [ -t 0 ]; then
    input="$*"
  else
    input=$(cat)
  fi

  if [ -z "$input" ]; then
    echo "Usage: echo 'your question' | aiq  or  aiq your question"
    return 1
  fi

  local prompt="Given the following source code, generate documentation in the specified format. Keep explanations brief and clear. Focus on summarizing what the code does, and provide a usage section. Use the following format:
                ## About the \`xxx\` Function
                description(1-2 lines)
                ### Usage
                - \`command [options]\`  # short comment explaining usage"

  ai-request "$prompt" "$input"
}


