# Custom Bash Environment

## Installation
1. Clone this repository into `~/.config/bash` (or adjust the paths below to match your location).
2. Append the following line to your `~/.bashrc` (create the file if necessary):
   ```bash
   source ~/.config/bash/bashrc
   ```
3. Restart the shell or run `source ~/.config/bash/bashrc` to apply the configuration.

Optional machine-specific values (tokens, secrets, etc.) can be placed in `~/.config/bash/.env`; it will be loaded automatically when present.

## Directory Layout
```
.
├── alias                # Shell aliases
├── bashrc               # Entry point that sources the rest of the setup
├── scripts/
│   ├── ai/              # AI CLI entry (ai) plus lib/ and services/
│   ├── git.sh           # Batch git pull helper
│   ├── vnc.sh           # VNC launcher with SSH tunnelling support
│   ├── xrandr.sh        # Handy display presets
│   └── fzf/
│       ├── cd.sh        # fcd: interactive directory browser
│       └── rg.sh        # frg: ripgrep + fzf jump helper
└── settings/            # Prompt, XDG, platform tweaks, etc.
```

## Feature Overview & Dependencies
Each feature is optional; if a dependency is missing, only that feature will fail while the rest of the environment keeps working.

### `vnc` (scripts/vnc.sh)
- **Purpose**: Open RealVNC Viewer against hosts defined in `~/.ssh/config`, reusing `ssh -J` style jumps. Supports `-p`, `-P`, `-L`, `-J`, `-l`, and `-h` options.
- **Required**: `ssh`; RealVNC Viewer (`/Applications/VNC Viewer.app/...` on macOS or `/usr/bin/vncviewer` on Linux).
- **Optional**: None.

### `fcd` (scripts/fzf/cd.sh)
- **Purpose**: Interactive directory navigation with previews and incremental descent/ascent (`Ctrl-F` / `Ctrl-U`).
- **Required**: `fzf`, standard `find` command.
- **Optional**: None.

### `frg` (scripts/fzf/rg.sh)
- **Purpose**: Search a path with ripgrep and jump via fzf. Supports `-k/--keyword`, safe defaults, and library directory filters.
- **Required**: `rg`, `fzf`.
- **Optional**: `bat` for syntax-highlighted previews (falls back to `nl` + `sed`).

### AI CLI (`scripts/ai/`)
- **Purpose**: `ai` command that dispatches to commit/doc/diff/question/translate helpers, a shell command suggester (`ai cmd`), and Windows converters (`ai win -m ps|cmd`) backed by Gemini or OpenAI APIs.
- **Required**: Network access and provider-specific API keys defined in environment variables (`GEMINI_API_KEY`, `OPENAI_API_KEY`, etc.).
- **Optional**: None.

### `git.sh`
- **Purpose**: Iterate over registered repositories and run `git pull`.
- **Required**: `git`.
- **Optional**: None.

### `xrandr.sh`
- **Purpose**: Preset display resolutions for X11 environments.
- **Required**: `xrandr` (Linux).
- **Optional**: None.

## Usage Notes
- New shell functions become available after sourcing `bashrc`. To reload without restarting the shell, run `source ~/.config/bash/bashrc`.
- The environment is designed so that missing optional tools do not break everything; only the corresponding helper will warn or become a no-op.
- Modify or extend `scripts/` and `settings/` to tailor the environment for additional tooling.
