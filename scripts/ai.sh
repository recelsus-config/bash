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
# Language flag
##
parse_language_flag() {
  local use_language=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -l)
        use_language="japanese"
        ;;
    esac
    shift
  done

  if [ -n "$use_language" ]; then
    echo -e "\n\nOutput in ${use_language^}. \nPlease generate the result under the assumption that the intended reader is a ${use_language} speaker."
  fi
}

##
# Commit message generator
##
aicommit() {
  local args=("$@")
  local input=$(git diff --staged)

  local prompt="Write a commit message for the following diff.
                Format:
                1. 1–3 lines summary
                2. Edited files with changes (bullet list)

                Example:
                Updated xxx, fixed yyy, added zzz.

                - xxx.cpp: fixed A, changed request()
                - yyy.hpp: fixed response
                - zzz.md: added doc"

  prompt+=$(parse_language_flag "${args[@]}")

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

##
# Code Documentation Generator
##
aidoc() {
  local input=""
  local args=("$@")

  if [ -t 0 ]; then
    input="${args[*]}"
  else
    input=$(cat)
  fi

  if [ -z "$input" ]; then
    echo "Usage: echo 'your code' | aidoc [-l]  or  aidoc [-l] 'code string'"
    return 1
  fi

  local prompt="Given the following source code, generate documentation in the specified format. Keep explanations brief and clear. Focus on summarizing what the code does, and provide a usage section. Use the following format:
                ## About the \`xxx\` Function
                description (1-2 lines)
                ### Usage
                - \`command [options]\`  # short comment explaining usage"

  prompt+=$(parse_language_flag "${args[@]}")
  ai-request "$prompt" "$input"
}

##
# Full Code Documentation Generator
##
aidoc-full() {
  local input=""
  local args=("$@")

  if [ -t 0 ]; then
    input="${args[*]}"
  else
    input=$(cat)
  fi

  if [ -z "$input" ]; then
    echo "Usage: cat file.ts | aidoc-full [-l]  or  aidoc-full [-l] 'source code string'"
    return 1
  fi

  local prompt="You are given a source code file that may contain one or more import statements. Based on the imported modules and the structure of the code, infer the purpose of the application and generate a concise, developer-friendly README.md.
  
                ## Overview
                - Summarize what the application does (2-3 lines), based on the main logic and imported modules.

                ## Features
                - Briefly list key functionalities inferred from the code (e.g., CLI tools, HTTP server, database access, scraping, etc.)

                ## Usage
                - Provide a short example of how to use this program (e.g., \`node app.js --help\` or \`python main.py <input>\`), even if approximate.

                ## Dependencies
                - List notable third-party modules or frameworks used (based on import statements).

                Avoid speculative details that aren't clearly reflected in the code. Keep all sections succinct and relevant to developers browsing the repository."

  prompt+=$(parse_language_flag "${args[@]}")
  ai-request "$prompt" "$input"
}

