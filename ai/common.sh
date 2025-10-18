# vim: ft=sh

ai_normalise_language_name() {
  local raw="$1"

  if [ -z "$raw" ]; then
    return
  fi

  local lower_case
  lower_case=$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]')

  case "$lower_case" in
    eng|en|english)
      printf 'English'
      ;;
    ja|jp|jpn|japanese)
      printf 'Japanese'
      ;;
    fr|fra|fre|french)
      printf 'French'
      ;;
    es|spa|spanish)
      printf 'Spanish'
      ;;
    de|ger|deu|german)
      printf 'German'
      ;;
    *)
      printf '%s' "${lower_case^}"
      ;;
  esac
}

ai_language_directive() {
  local base_language="$1"
  local flag_language="$2"
  shift 2

  local chosen=""
  local saw_flag=0

  while [ $# -gt 0 ]; do
    case "$1" in
      -l)
        saw_flag=1
        if [ $# -gt 1 ] && [[ "$2" != -* ]]; then
          chosen="$2"
          shift
        else
          chosen="$flag_language"
        fi
        ;;
    esac
    shift
  done

  if [ "$saw_flag" -eq 0 ]; then
    chosen="$base_language"
  fi

  if [ -z "$chosen" ]; then
    return
  fi

  local display
  display=$(ai_normalise_language_name "$chosen")

  if [ -z "$display" ]; then
    return
  fi

  printf '\n\n***Please output in %s.***\nAssume the intended audience uses %s.\n' "$display" "$display"
}

ai_resolve_provider() {
  local default_provider
  default_provider=$(printf '%s' "${1:-gemini}" | tr '[:upper:]' '[:lower:]')
  shift

  local chosen="$default_provider"

  while [ $# -gt 0 ]; do
    case "$1" in
      -p)
        shift
        if [ $# -gt 0 ]; then
          local flag_value
          flag_value=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
          case "$flag_value" in
            gemini|openai|chatgpt)
              chosen="$flag_value"
              ;;
            *)
              printf "[FAIL] Unknown AI provideh: %s\n" "$1" >&2
              return 1
              ;;
          esac
          shift
          continue
        fi
        printf "[FAIL] The -p flag expects a provideh name.\n" >&2
        return 1
        ;;
    esac
    shift
  done

  case "$chosen" in
    gemini|openai|chatgpt)
      ;;
    *)
      printf "[FAIL] Unknown AI provideh: %s\n" "$chosen" >&2
      return 1
      ;;
  esac

  if [ "$chosen" = "chatgpt" ]; then
    chosen="openai"
  fi

  printf '%s' "$chosen"
}

ai_collect_positionals() {
  local collected=()

  while [ $# -gt 0 ]; do
    case "$1" in
      -p)
        shift
        if [ $# -gt 0 ]; then
          shift
        fi
        continue
        ;;
      -l)
        shift
        if [ $# -gt 0 ] && [[ "$1" != -* ]]; then
          shift
        fi
        continue
        ;;
      --)
        shift
        while [ $# -gt 0 ]; do
          collected+=("$1")
          shift
        done
        break
        ;;
      -*)
        shift
        continue
        ;;
      *)
        collected+=("$1")
        shift
        ;;
    esac
  done

  if [ ${#collected[@]} -gt 0 ]; then
    printf '%s' "${collected[*]}"
  fi
}
