# frg: safe-by-default ripgrep + fzf jump
#   Usage examples:
#     frg path                       # interactively search under ./path (keyword optional)
#     frg path -k "TODO"             # search path for keyword
#     frg -k password                # search current directory
#     frg path --include-lib -k foo  # include library/build dirs

frg() {
  command -v rg >/dev/null 2>&1 || { printf 'rg not found\n' >&2; return 1; }
  command -v fzf >/dev/null 2>&1 || { printf 'fzf not found\n' >&2; return 1; }

  local max_size="${FRG_DEFAULT_MAX_SIZE:-2M}"
  local include_lib=0
  local allow_binary=0
  local disable_excludes=0
  local disable_size_limit=0

  local search_root=""
  local keyword=""
  local args=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --include-lib) include_lib=1; shift ;;
      --binary)      allow_binary=1; shift ;;
      --no-size-limit) disable_size_limit=1; shift ;;
      --size=*)        max_size="${1#*=}"; shift ;;
      --all)         disable_excludes=1; disable_size_limit=1; include_lib=1; allow_binary=1; shift ;;
      --keyword=*)   keyword="${1#*=}"; shift ;;
      --keyword)     shift; [[ $# -gt 0 ]] || { printf 'frg: --keyword requires argument\n' >&2; return 2; }; keyword="$1"; shift ;;
      -k)            shift; [[ $# -gt 0 ]] || { printf 'frg: -k requires argument\n' >&2; return 2; }; keyword="$1"; shift ;;
      --)            shift
                     if [[ $# -gt 0 ]]; then
                       if [[ -z $keyword ]]; then
                         keyword="$1"; shift
                         while [[ $# -gt 0 ]]; do
                           keyword+=" $1"; shift
                         done
                       else
                         printf 'frg: unexpected trailing arguments\n' >&2
                         return 2
                       fi
                     fi
                     break ;;
      -*)            printf 'frg: unknown option: %s\n' "$1" >&2; return 2 ;;
      *)             if [[ -z $search_root ]]; then
                       search_root="$1"
                       shift
                     else
                       printf 'frg: unexpected argument: %s\n' "$1" >&2
                       return 2
                     fi ;;
    esac
  done

  if [[ -z $search_root ]]; then
    search_root='.'
  fi

  if [[ ! -d $search_root && ! -f $search_root ]]; then
    printf 'frg: path not found: %s\n' "$search_root" >&2
    return 1
  fi

  args+=(--no-heading --line-number --hidden -S)

  if [[ $disable_size_limit -eq 0 ]]; then
    args+=(--max-filesize "$max_size")
  fi

  if [[ $allow_binary -eq 1 ]]; then
    args+=(-a)
  fi

  if [[ $disable_excludes -eq 0 ]]; then
    local -a bin_globs=(
      '!*.png' '!*.jpg' '!*.jpeg' '!*.gif' '!*.webp' '!*.bmp' '!*.ico'
      '!*.pdf' '!*.ps' '!*.eps' '!*.ai'
      '!*.zip' '!*.gz' '!*.bz2' '!*.xz' '!*.7z' '!*.rar' '!*.tar' '!*.tgz' '!*.zst'
      '!*.mp3' '!*.flac' '!*.wav' '!*.ogg' '!*.m4a'
      '!*.mp4' '!*.mov' '!*.avi' '!*.mkv' '!*.webm'
      '!*.exe' '!*.dll' '!*.so' '!*.dylib' '!*.o' '!*.a' '!*.bin' '!*.class' '!*.wasm'
      '!*.iso' '!*.img'
    )
    for g in "${bin_globs[@]}"; do args+=(--glob "$g"); done

    if [[ $include_lib -eq 0 ]]; then
      local -a lib_dirs=(
        '!.git/**' '!node_modules/**' '!vendor/**' '!dist/**' '!build/**' '!target/**'
        '!.venv/**' '!venv/**' '!__pycache__/**' '!.cache/**' '!.mypy_cache/**' '!.pytest_cache/**'
        '!.next/**' '!.nuxt/**' '!.gradle/**' '!.idea/**' '!.vscode/**'
        '!Pods/**' '!Carthage/**' '!DerivedData/**' '!.terraform/**' '!.direnv/**'
      )
      for g in "${lib_dirs[@]}"; do args+=(--glob "$g"); done
    fi
  fi

  local query="$keyword"
  local header_info="root: $search_root"
  if [[ -n $keyword ]]; then
    header_info+=" | keyword: $keyword"
  else
    header_info+=" | keyword: (match all)"
  fi
  local fzf_header
  printf -v fzf_header '%s\n%s' "$header_info" 'Enter=open, preview shows context\nTips: Alt-p toggle preview, Alt-j/k scroll'

  local preview_cmd
  read -r -d '' preview_cmd <<'PREVIEW'
bash -c '
file="$1"
line="$2"
if [[ -z "$file" || ! -e "$file" ]]; then
  exit 0
fi
if [[ ! "$line" =~ ^[0-9]+$ ]]; then
  line=1
fi
start=$(( line > 20 ? line - 20 : 1 ))
end=$(( line + 20 ))
if command -v bat >/dev/null 2>&1; then
  bat --color=always --highlight-line "$line" -r "${start}:${end}" "$file"
else
  nl -ba "$file" | sed -n "${start},${end}p"
fi
' -- {1} {2}
PREVIEW

  local pick file line
  pick="$(
    rg "${args[@]}" -- "$query" "$search_root" 2>/dev/null |
    fzf --delimiter=: --nth=3.. \
        --ansi \
        --header="$fzf_header" \
        --bind 'alt-p:toggle-preview,alt-j:preview-down,alt-k:preview-up' \
        --preview="$preview_cmd" \
        --preview-window=right:60%:wrap
  )" || return

  file="${pick%%:*}"
  line="${pick#*:}"; line="${line%%:*}"

  [[ -n $file && -n $line ]] && "${EDITOR:-nvim}" "+${line}" "$file"
}

