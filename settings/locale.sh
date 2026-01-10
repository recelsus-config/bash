# Prefer a working locale to avoid startup warnings on remote hosts.
if command -v locale >/dev/null 2>&1; then
  available_locales="$(locale -a 2>/dev/null)"

  select_locale() {
    local candidate
    for candidate in "$@"; do
      if printf '%s\n' "$available_locales" | grep -qx "$candidate"; then
        printf '%s' "$candidate"
        return 0
      fi
    done
    return 1
  }

  preferred_locale="$(select_locale ja_JP.UTF-8 en_US.UTF-8 C.UTF-8 C)"
  if [ -n "$preferred_locale" ]; then
    export LANG="$preferred_locale"
    export LC_ALL="$preferred_locale"
    export LC_CTYPE="$preferred_locale"
  fi
fi
