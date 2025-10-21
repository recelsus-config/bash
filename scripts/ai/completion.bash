# bash completion fo' ai CLI
_ai_completion() {
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  if [ $COMP_CWORD -ge 1 ]; then
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  else
    prev=""
  fi

  local command=""
  local idx=1
  while [ $idx -lt $COMP_CWORD ]; do
    local word="${COMP_WORDS[$idx]}"
    case "$word" in
      -m|-l)
        if [ $((idx + 1)) -lt $COMP_CWORD ]; then
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

  local commands="commit diff doc question translate t cmd win"
  local global_opts="-h --help -l -m"
  local languages="english japanese french spanish german"

  case "$command" in
    "")
      if [ "$prev" = "-" ]; then
        COMPREPLY=( $(compgen -W "$global_opts" -- "$cur") )
        return
      fi
      if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
      else
        COMPREPLY=( $(compgen -W "$global_opts $commands" -- "$cur") )
      fi
      return
      ;;
    doc)
      if [ "$prev" = "-m" ]; then
        COMPREPLY=( $(compgen -W "full" -- "$cur") )
        return
      fi
      if [ "$prev" = "-l" ]; then
        COMPREPLY=( $(compgen -W "$languages" -- "$cur") )
        return
      fi
      COMPREPLY=( $(compgen -W "-l -m -h --help" -- "$cur") )
      return
      ;;
    translate|t)
      if [ "$prev" = "-l" ]; then
        COMPREPLY=( $(compgen -W "$languages" -- "$cur") )
        return
      fi
      COMPREPLY=( $(compgen -W "-l -h --help" -- "$cur") )
      return
      ;;
    question)
      if [ "$prev" = "-l" ]; then
        COMPREPLY=( $(compgen -W "$languages" -- "$cur") )
        return
      fi
      COMPREPLY=( $(compgen -W "-l -h --help" -- "$cur") )
      return
      ;;
    diff|commit)
      if [ "$prev" = "-l" ]; then
        COMPREPLY=( $(compgen -W "$languages" -- "$cur") )
        return
      fi
      COMPREPLY=( $(compgen -W "-l -h --help" -- "$cur") )
      return
      ;;
    win)
      if [ "$prev" = "-m" ]; then
        COMPREPLY=( $(compgen -W "ps cmd" -- "$cur") )
        return
      fi
      COMPREPLY=( $(compgen -W "-m -h --help" -- "$cur") )
      return
      ;;
    cmd)
      COMPREPLY=()
      return
      ;;
    *)
      COMPREPLY=( $(compgen -W "$global_opts" -- "$cur") )
      return
      ;;
  esac
}

complete -F _ai_completion ai
