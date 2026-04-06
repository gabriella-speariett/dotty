fish_add_path ~/.local/bin

if test (uname) = Darwin
    fish_add_path /Applications/Docker.app/Contents/Resources/bin
    fish_add_path /Applications/WezTerm.app/Contents/MacOS
end
