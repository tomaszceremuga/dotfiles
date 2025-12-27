if status is-interactive
end

set PATH $PATH /home/user/.local/bin

set -g fish_greeting ""

alias dater="watch -t -n 1 \"date '+%A, %d %B %Y, %H:%M:%S'\""

set -x FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git --exclude node_modules'

function ch
    rm ~/.local/share/fish/fish_history
end

function nfz
    nvim $(fzf --preview="bat --color=always {}")
end

function cda
    set dir (fd -t d --hidden . | fzf)
    if test -n "$dir"
        cd "$dir"
    end
end

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

function q
    qalc $argv
end

function cl
    clear
end
