if test -f ~/.atuin/bin/env.fish
    source ~/.atuin/bin/env.fish
end

if status --is-interactive
    atuin init fish | source
end
