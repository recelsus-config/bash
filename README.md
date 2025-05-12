# Custom Bash Environment Overview

## Installation

To activate this custom bash environment, append the following line to your `~/.bashrc` (or create the file if it does not exist):

```bash
source ~/.config/bash/bashrc
```

This will load the custom bashrc from the .config/bash/ directory. 
That file, in turn, loads various environment-specific and modular configuration scripts from the settings/, scripts/, and other related files within the directory.
Ensure this repository is cloned into ~/.config/bash or a path you specify consistently.

# Custom Bash Environment Overview

## 1. Directory Structure
```
.
├── alias
├── bashrc
├── environment.example
├── scripts
│   ├── ai.sh
│   ├── discord.sh
│   ├── fzf.sh
│   ├── git.sh
│   ├── vnc.sh
│   └── xrandr.sh
└── settings
    ├── application-dir.sh
    ├── completions.sh
    ├── linux.sh
    ├── mac.sh
    ├── ps1.sh
    └── xdg.sh
```

## 2. Script Documentation

### About the `vnc` Function
This function establishes a VNC connection to a target host, reading connection details from a JSON configuration file.
It supports direct connections and connections through an SSH tunnel.

### Usage
- `vnc target_host`  # Connects to the specified target host using VNC.  Requires `jq` and a properly formatted `~/.ssh/vnc-config.json` file.

---

### About the `ai.sh` Function
This function sends a prompt and input to the Gemini API and returns the generated content. 
It constructs a JSON payload with the prompt and input, then uses `curl` to make a POST request to the Gemini API.

### Usage
- `ai-request <prompt> <input>`  # Sends a request to the Gemini API with the given prompt and input.

- `aicommit`  # Generates a commit message based on the diff and commits the changes.
- `aicommit-ja`  # Generates a Japanese commit message based on the diff and commits the changes.

- `aitrans "text to translate"`  # Translates the given text.
- `echo "text to translate" | aitrans`  # Translates the piped text.

- `aiq "your question"`  # Answers the given question in Japanese.
- `echo "your question" | aiq`  # Answers the piped question in Japanese.

- `aidoc "your source code"`  # Generates documentation for the given source code.
- `echo "your source code" | aidoc`  # Generates documentation for the piped source code.

---

### About the `discord.sh` Function
This function sends a message to a specified endpoint via a POST request, formatting the message as a JSON payload containing a username, avatar URL, and the message content. 
It reads the message either from standard input or as a command-line argument.

### Usage
- `keep "message"`  # Sends the specified message to the configured endpoint.
- `echo "message" | keep` # Sends the message piped from standard input to the endpoint.

---

### About the `git.sh` Function
This function iterates through a predefined list of directories, checks if they are git repositories, and if so, performs a `git pull` operation to update them.

### Usage
- `git-update`  # Updates git repositories in specified directories.

---

### About the `fzf.sh` Function
This function allows you to fuzzy-search through directories and then `cd` into the selected directory.
It excludes hidden directories from the search.

### Usage
- `fcd [directory]`  # Fuzzy-find a directory and cd into it, defaults to current directory if none specified.

---

### About the `xrandr.sh` Function
Sets the Virtual-1 output to 1920x1080 resolution using xrandr.

### Usage
- `xrandr-fhd`  # Sets resolution to 1920x1080
- `xrandr-hd`  # Sets resolution to 1280x720
- `xrandr-xhd`  # Sets resolution to 2240x1260
- `xrandr-mac`  # Sets resolution to 2304x1440

---

## 3. Configuration Files Overview

These files define environment settings, completions, aliases, and platform-specific configurations.

### Top-Level

#### `alias`
- Defines custom shell aliases for common commands.

#### `bashrc`
- Main entry point for the custom shell environment.

#### `environment.example`
- Example file for environment variables. Can be copied and modified as `environment`.

### `settings/` Directory

#### `application-dir.sh`
- Defines application directory paths and location-specific variables.

#### `completions.sh`
- Configures shell completion for various custom functions or tools.

#### `linux.sh`
- Platform-specific settings for Linux environments.

#### `mac.sh`
- Platform-specific settings for macOS environments.

#### `ps1.sh`
- Customizes the shell prompt (PS1) appearance and behavior.

#### `xdg.sh`
- Manages XDG Base Directory specification variables for consistent file paths.

