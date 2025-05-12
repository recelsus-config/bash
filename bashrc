# export LANG=ja_JP.UTF-8
# export LC_ALL=ja_JP.UTF-8

export TERM=xterm-256color
export VISUAL=vim
export EDITOR=vim

[ -f $HOME/.config/bash/environment ] && source $HOME/.config/bash/environment
[ -f $HOME/.config/bash/alias ] && source $HOME/.config/bash/alias
[ -f $HOME/.config/bash/settings/xdg.sh ] && source $HOME/.config/bash/settings/xdg.sh
[ -f $HOME/.config/bash/settings/ps1.sh ] && source $HOME/.config/bash/settings/ps1.sh
[ -f $HOME/.config/bash/settings/completions.sh ] && source $HOME/.config/bash/settings/completions.sh

export PATH="$PATH":/usr/bin
export PATH="$PATH":"$HOME"/.local/bin
export PATH="$PATH":"$XDG_DATA_HOME"/npm/bin
export PATH="$PATH":"$XDG_DATA_HOME"/go/bin
export PATH="$PATH":"/snap/bin"

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

for file in $HOME/.config/bash/scripts/*.sh; do
    [ -f "$file" ] && source "$file"
done

