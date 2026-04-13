# vim: ft=sh

if [ -d "$HOME/.config/alacritty" ]; then
  if [ ! -e "$HOME/.config/alacritty/os.toml" ]; then
    case "$(uname)" in
      Darwin)
        ln -s "$HOME/.config/alacritty/os/mac.toml" \
              "$HOME/.config/alacritty/os.toml"
        ;;
      *)
        ln -s "$HOME/.config/alacritty/os/linux.toml" \
              "$HOME/.config/alacritty/os.toml"
        ;;
    esac
  fi
fi
