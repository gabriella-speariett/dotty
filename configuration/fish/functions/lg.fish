function lg
    # Find all .yml files in the directory and join them with commas
    set -l config_files (string join "," $XDG_CONFIG_HOME/lazygit/*.yml)

    if test -n "$config_files"
        lazygit --use-config-file="$config_files" $argv
    else
        lazygit $argv
    end
end
