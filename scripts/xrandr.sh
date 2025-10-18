# vim: ft=sh

xrandr-fhd() { # 1920x1080
  xrandr --output Virtual-1 --mode 1920x1080
}

xrandr-hd() { # 1280x720
  xrandr --newmode "1280x720_60.00"  74.48  1280 1336 1472 1664  720 721 724 746  -HSync +Vsync
  xrandr --addmode Virtual-1 1280x720_60.00
  xrandr --output Virtual-1 --mode 1280x720_60.00
}

xrandr-xhd() { # 2240x1260
  xrandr --newmode "2240x1260_60.00"  237.85  2240 2400 2640 3040  1260 1261 1264 1304  -HSync +Vsync
  xrandr --addmode Virtual-1 "2240x1260_60.00"
  xrandr --output Virtual-1 --mode "2240x1260_60.00"
}

xrandr-mac() { # 2304x1440
  xrandr --newmode "2304x1440_60.00"  280.36  2304 2472 2720 3136  1440 1441 1444 1490  -HSync +Vsync
  xrandr --addmode Virtual-1 2304x1440_60.00
  xrandr --output Virtual-1 --mode 2304x1440_60.00
}

xrandr-mba() { # 1920x1200
  xrandr --output Virtual-1 --mode 1920x1200
}

# List named modes with noted size
xrandr-list() {
  local source_path
  source_path="${BASH_SOURCE[0]}"

  if [ ! -f "$source_path" ]; then
    source_path="$HOME/.config/bash/scripts/xrandr.sh"
  fi

  if [ ! -f "$source_path" ]; then
    printf "[FAIL] Missing xrandr source file.\n" >&2
    return 1
  fi

  awk '/^xrandr-[^(]+\(\) \{ # / {
    name=$1
    sub(/\(\)/, "", name)
    split($0, bits, "#")
    if (length(bits) > 1) {
      size = bits[2]
      gsub(/^ +| +$/, "", size)
      printf("%s %s\n", name, size)
    }
  }' "$source_path"
}
