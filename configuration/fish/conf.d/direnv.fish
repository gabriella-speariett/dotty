if status --is-interactive && command -q direnv
    direnv hook fish | source
    set -g DIRENV_LOG_FORMAT ""
end
