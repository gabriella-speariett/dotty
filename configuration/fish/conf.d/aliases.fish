if status --is-interactive
    alias c='clear'
    alias ls='lsd'

    if command -v batcat &>/dev/null
        alias cat='batcat'
    else if command -v bat &>/dev/null
        alias cat='bat'
    end

    if command -v fdfind &>/dev/null
        alias find='fdfind'
    else if command -v fd &>/dev/null
        alias find='fd'
    end
end
