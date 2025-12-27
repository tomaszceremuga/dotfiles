function fish_prompt
    set path (pwd)
    if test "$path" = "$HOME"
        echo -n "> "
    else
        set short (string replace -r "^$HOME" "~" $path)
        echo -n "$short > "
    end
end
