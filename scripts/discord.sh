# vim: ft=sh

keep() {
  local endpoint="${DISCORD_WEBHOOK}"

  username="bash"
  avatar_url="https://www.powerpyx.com/wp-content/uploads/pokemon-sword-shield-Pyukumuku.jpg"

  local message
  if [ -p /dev/stdin ]; then
    message=$(cat -)
  else
    message="$1"
  fi

  if [ -z "$message" ]; then
    echo "Error: Message is empty. Usage: keep \"message\" or echo \"message\" | keep"
    return 1
  fi

  local json_payload
  json_payload=$(jq -n \
    --arg username "$username" \
    --arg avatar_url "$avatar_url" \
    --arg content "$message" \
    '{username: $username, avatar_url: $avatar_url, content: $content}')

  curl -X POST "$endpoint" \
       -H "Content-Type: application/json" \
       -d "$json_payload"
}

