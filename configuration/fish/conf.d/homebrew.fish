if test (uname) = Darwin
    fish_add_path /opt/homebrew/bin

    # GNU tools (brew: gnu-sed, coreutils, grep)
    fish_add_path /opt/homebrew/opt/gnu-sed/libexec/gnubin
    fish_add_path /opt/homebrew/opt/coreutils/libexec/gnubin
    fish_add_path /opt/homebrew/opt/grep/libexec/gnubin
end
