# vim: ft=sh

for file in "$XDG_DATA_HOME"/bash_completion/*; do
    [ -f "$file" ] && source "$file"
done

if [ -f /usr/share/git/completion/git-prompt.sh ]; then
    source /usr/share/git/completion/git-prompt.sh
fi

if [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
    source /usr/share/git-core/contrib/completion/git-prompt.sh
fi

if [ -f "$HOME/.config/bash/scripts/ai/completion.bash" ]; then
    source "$HOME/.config/bash/scripts/ai/completion.bash"
fi
