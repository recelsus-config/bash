# export LANG=ja_JP.UTF-8
# export LC_ALL=ja_JP.UTF-8

export TERM=xterm-256color

EDITOR_CANDIDATE=$(command -v nvim || command -v vim || command -v vi)
export EDITOR="$EDITOR_CANDIDATE"
export VISUAL="$EDITOR_CANDIDATE"

[ -f $HOME/.config/bash/.env ] && set -a && . "$HOME/.config/bash/.env" && set +a

[ -f $HOME/.config/bash/alias ] && source $HOME/.config/bash/alias
[ -f $HOME/.config/bash/settings/xdg.sh ] && source $HOME/.config/bash/settings/xdg.sh
[ -f $HOME/.config/bash/settings/ps1.sh ] && source $HOME/.config/bash/settings/ps1.sh
[ -f $HOME/.config/bash/settings/completions.sh ] && source $HOME/.config/bash/settings/completions.sh

export PATH="$HOME/.local/bin:$XDG_DATA_HOME/cargo/bin:$XDG_DATA_HOME/npm/bin:$XDG_DATA_HOME/go/bin:/snap/bin:$PATH"
export PATH="$HOME/.local/bin/reg-scripts/bin:$PATH"

# ===============================================
# Linux or Mac Branch
# ===============================================

SYSTEM_INFO="$(uname -sm)"
SETTINGS_DIR="$HOME/.config/bash/settings"

case "$SYSTEM_INFO" in
  *Linux*)  OS_SCRIPT="linux.sh" ;;
  *Darwin*) OS_SCRIPT="mac.sh" ;;
esac

[ -n "$OS_SCRIPT" ] && [ -f "$SETTINGS_DIR/$OS_SCRIPT" ] && source "$SETTINGS_DIR/$OS_SCRIPT"

if [ -n "$SSH_CONNECTION" ]; then
  export PS1="$PS1_SSH"
fi

# ===============================================
# sh functions
# ===============================================

if [ -d "$HOME/.config/bash/ai" ]; then
  if [ -f "$HOME/.config/bash/ai/common.sh" ]; then
    source "$HOME/.config/bash/ai/common.sh"
  fi
  for file in "$HOME/.config/bash/ai/"*.sh; do
    [ "$file" = "$HOME/.config/bash/ai/common.sh" ] && continue
    [ -f "$file" ] && source "$file"
  done
fi

for file in "$HOME/.config/bash/scripts"/*.sh; do
    [ -f "$file" ] && source "$file"
done

if [ -d "$HOME/.config/bash/scripts/fzf" ]; then
  for file in "$HOME/.config/bash/scripts/fzf"/*.sh; do
    [ -f "$file" ] && source "$file"
  done
fi

