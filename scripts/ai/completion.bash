# bash completion fo' ai CLI
_ai_model_candidates() {
  local candidates=""
  local seen=" "
  local model

  for model in "${GEMINI_MODEL:-}" "${OPENAI_MODEL:-}" "${CODEX_CLI_MODEL:-}"; do
    if [ -z "$model" ]; then
      continue
    fi

    case "$seen" in
      *" $model "*)
        ;;
      *)
        candidates+="$model "
        seen+="$model "
        ;;
    esac
  done

  printf '%s' "$candidates"
}

_ai_completion() {
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  if [ "$COMP_CWORD" -ge 1 ]; then
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  else
    prev=""
  fi

  local command=""
  local idx=1
  while [ $idx -lt "$COMP_CWORD" ]; do
    local word="${COMP_WORDS[$idx]}"
    case "$word" in
      -m|--model|-l|--language|-p|--provider|--to)
        if [ $((idx + 1)) -lt "$COMP_CWORD" ]; then
          idx=$((idx + 2))
          continue
        else
          command=""
          break
        fi
        ;;
      -h|--help)
        idx=$((idx + 1))
        continue
        ;;
      -*)
        idx=$((idx + 1))
        continue
        ;;
      *)
        command="$word"
        break
        ;;
    esac
  done

  local commands="commit diff doc question q translate t trans cmd providers"
  local global_opts="-h --help -l --language -m --model -p --provider"
  local languages="english japanese french spanish german"
  local providers="gemini chatgpt codex-cli gemini-cli"
  local models
  models=$(_ai_model_candidates)
  local cmd_targets="win cmd ps"

  case "$command" in
    "")
      if [ "$prev" = "-" ]; then
        COMPREPLY=( $(compgen -W "$global_opts" -- "$cur") )
        return
      fi
      if [ "$COMP_CWORD" -eq 1 ]; then
        COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
      else
        COMPREPLY=( $(compgen -W "$global_opts $commands" -- "$cur") )
      fi
      return
      ;;
    doc)
      if [ "$prev" = "-p" ] || [ "$prev" = "--provider" ]; then
        COMPREPLY=( $(compgen -W "$providers" -- "$cur") )
        return
      fi
      if [ "$prev" = "-m" ] || [ "$prev" = "--model" ]; then
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
        return
      fi
      if [ "$prev" = "-l" ] || [ "$prev" = "--language" ]; then
        COMPREPLY=( $(compgen -W "$languages" -- "$cur") )
        return
      fi
      COMPREPLY=( $(compgen -W "-l --language -p --provider -m --model --full -h --help" -- "$cur") )
      return
      ;;
    translate|t|trans)
      if [ "$prev" = "-p" ] || [ "$prev" = "--provider" ]; then
        COMPREPLY=( $(compgen -W "$providers" -- "$cur") )
        return
      fi
      if [ "$prev" = "-m" ] || [ "$prev" = "--model" ]; then
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
        return
      fi
      if [ "$prev" = "-l" ] || [ "$prev" = "--language" ]; then
        COMPREPLY=( $(compgen -W "$languages" -- "$cur") )
        return
      fi
      if [ "$prev" = "--to" ]; then
        COMPREPLY=( $(compgen -W "$languages" -- "$cur") )
        return
      fi
      COMPREPLY=( $(compgen -W "-l --language -p --provider -m --model --to -h --help" -- "$cur") )
      return
      ;;
    question|q)
      if [ "$prev" = "-p" ] || [ "$prev" = "--provider" ]; then
        COMPREPLY=( $(compgen -W "$providers" -- "$cur") )
        return
      fi
      if [ "$prev" = "-m" ] || [ "$prev" = "--model" ]; then
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
        return
      fi
      if [ "$prev" = "-l" ] || [ "$prev" = "--language" ]; then
        COMPREPLY=( $(compgen -W "$languages" -- "$cur") )
        return
      fi
      COMPREPLY=( $(compgen -W "-l --language -p --provider -m --model -h --help" -- "$cur") )
      return
      ;;
    diff)
      if [ "$prev" = "-p" ] || [ "$prev" = "--provider" ]; then
        COMPREPLY=( $(compgen -W "$providers" -- "$cur") )
        return
      fi
      if [ "$prev" = "-m" ] || [ "$prev" = "--model" ]; then
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
        return
      fi
      if [ "$prev" = "-l" ] || [ "$prev" = "--language" ]; then
        COMPREPLY=( $(compgen -W "$languages" -- "$cur") )
        return
      fi
      COMPREPLY=( $(compgen -W "-l --language -p --provider -m --model -h --help" -- "$cur") )
      return
      ;;
    commit)
      if [ "$prev" = "-p" ] || [ "$prev" = "--provider" ]; then
        COMPREPLY=( $(compgen -W "$providers" -- "$cur") )
        return
      fi
      if [ "$prev" = "-m" ] || [ "$prev" = "--model" ]; then
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
        return
      fi
      if [ "$prev" = "-l" ] || [ "$prev" = "--language" ]; then
        COMPREPLY=( $(compgen -W "$languages" -- "$cur") )
        return
      fi
      if [ "$prev" = "-i" ] || [ "$prev" = "--ignore" ]; then
        COMPREPLY=( $(compgen -f -- "$cur") )
        return
      fi
      if [ "$prev" = "-id" ] || [ "$prev" = "--ignore-dir" ]; then
        COMPREPLY=( $(compgen -d -- "$cur") )
        return
      fi
      if [ "$prev" = "--prompt" ]; then
        COMPREPLY=()
        return
      fi
      COMPREPLY=( $(compgen -W "-l --language -p --provider -m --model -i --ignore -id --ignore-dir --prompt -h --help" -- "$cur") )
      return
      ;;
    cmd)
      if [ "$prev" = "-p" ] || [ "$prev" = "--provider" ]; then
        COMPREPLY=( $(compgen -W "$providers" -- "$cur") )
        return
      fi
      if [ "$prev" = "-m" ] || [ "$prev" = "--model" ]; then
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
        return
      fi
      if [ "$prev" = "--to" ]; then
        COMPREPLY=( $(compgen -W "$cmd_targets" -- "$cur") )
        return
      fi
      COMPREPLY=( $(compgen -W "-p --provider -m --model --to -h --help" -- "$cur") )
      return
      ;;
    providers)
      COMPREPLY=( $(compgen -W "-h --help" -- "$cur") )
      return
      ;;
    *)
      COMPREPLY=( $(compgen -W "$global_opts" -- "$cur") )
      return
      ;;
  esac
}

complete -F _ai_completion ai
