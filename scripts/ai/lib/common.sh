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
      -l|--language)
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
  default_provider=$(printf '%s' "${1:-}" | tr '[:upper:]' '[:lower:]')
  shift

  local chosen="$default_provider"

  while [ $# -gt 0 ]; do
    case "$1" in
      -p|--provider)
        local provider_flag="$1"
        shift
        if [ $# -gt 0 ]; then
          local flag_value
          flag_value=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
          case "$flag_value" in
            gemini|chatgpt|codex-cli|gemini-cli)
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
        printf "[FAIL] The %s flag expects a provideh name.\n" "$provider_flag" >&2
        return 1
        ;;
    esac
    shift
  done

  if [ -z "$chosen" ]; then
    printf "[FAIL] Please set DEFAULT_AI_PROVIDER o' pass -p/--provider.\n" >&2
    return 1
  fi

  case "$chosen" in
    gemini|chatgpt|codex-cli|gemini-cli)
      ;;
    *)
      printf "[FAIL] Unknown AI provideh: %s\n" "$chosen" >&2
      return 1
      ;;
  esac

  printf '%s' "$chosen"
}

ai_resolve_model() {
  local provider="$1"
  shift

  local chosen=""
  case "$provider" in
    gemini)
      chosen="${GEMINI_MODEL:-}"
      ;;
    chatgpt)
      chosen="${OPENAI_MODEL:-}"
      ;;
    codex-cli)
      chosen="${CODEX_CLI_MODEL:-}"
      ;;
    gemini-cli)
      chosen="${GEMINI_MODEL:-}"
      ;;
    *)
      printf "[FAIL] Unknown AI provideh: %s\n" "$provider" >&2
      return 1
      ;;
  esac

  while [ $# -gt 0 ]; do
    case "$1" in
      -m|--model)
        local model_flag="$1"
        shift
        if [ $# -gt 0 ] && [[ "$1" != -* ]]; then
          chosen="$1"
          shift
          continue
        fi
        printf "[FAIL] The %s flag expects a model name.\n" "$model_flag" >&2
        return 1
        ;;
    esac
    shift
  done

  if [ -z "$chosen" ]; then
    case "$provider" in
      gemini)
        printf "[FAIL] Please set GEMINI_MODEL o' pass -m/--model.\n" >&2
        ;;
      chatgpt)
        printf "[FAIL] Please set OPENAI_MODEL o' pass -m/--model.\n" >&2
        ;;
      codex-cli|gemini-cli)
        ;;
    esac
    case "$provider" in
      codex-cli|gemini-cli)
        ;;
      *)
        return 1
        ;;
    esac
  fi

  printf '%s' "$chosen"
}

ai_resolve_to() {
  local chosen=""

  while [ $# -gt 0 ]; do
    case "$1" in
      --to)
        shift
        if [ $# -gt 0 ] && [[ "$1" != -* ]]; then
          chosen="$1"
          shift
          continue
        fi
        printf "[FAIL] The --to flag expects a value.\n" >&2
        return 1
        ;;
    esac
    shift
  done

  printf '%s' "$chosen"
}

ai_collect_positionals() {
  local collected=()

  while [ $# -gt 0 ]; do
    case "$1" in
      -p|--provider)
        shift
        if [ $# -gt 0 ]; then
          shift
        fi
        continue
        ;;
      -m|--model|--to)
        shift
        if [ $# -gt 0 ] && [[ "$1" != -* ]]; then
          shift
        fi
        continue
        ;;
      --full)
        shift
        continue
        ;;
      -l|--language)
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
