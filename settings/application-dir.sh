# vim: ft=sh

export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export RANDFILE="$XDG_CONFIG_HOME"/openssl/rnd
export LESSHISTFILE=-

export HISTFILE="$XDG_STATE_HOME"/bash/history
export BASH_SESSION="$XDG_STATE_HOME/bash/sessions"
export TERMINFO="$XDG_DATA_HOME"/terminfo

export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export GOPATH="$XDG_DATA_HOME"/go
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export CONAN_USER_HOME="$XDG_DATA_HOME"/conan
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
