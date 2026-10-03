fish_add_path ~/.local/bin

if test (uname) = Darwin
    fish_add_path /Applications/Docker.app/Contents/Resources/bin
    fish_add_path /Applications/WezTerm.app/Contents/MacOS
end

# Tools installed by mise (Linux)
if test -d ~/.local/share/mise/shims
    fish_add_path ~/.local/share/mise/shims
end
