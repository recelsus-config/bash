# vim: ft=sh

if [ -x "/opt/homebrew/bin/brew" ]; then
  export BREW_PREFIX=$(/opt/homebrew/bin/brew --prefix)
elif [ -x "/usr/local/bin/brew" ]; then
  export BREW_PREFIX=$(/usr/local/bin/brew --prefix)
else
  echo "Homebrew not found"
fi

if [ -n "$BREW_PREFIX" ]; then
  export PATH="$BREW_PREFIX"/bin:"$PATH"
  export PATH="$BREW_PREFIX"/sbin:"$PATH"

  if [ -f "$BREW_PREFIX/etc/bash_completion" ]; then
    . "$BREW_PREFIX/etc/bash_completion"
  fi

  case "$(uname -m)" in
    arm64)
      # ARM-specific commands
      ;;
    x86_64)
      # x86_64-specific commands
      ;;
  esac
fi

