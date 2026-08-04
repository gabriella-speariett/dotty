if status is-interactive
	set -x STARSHIP_CONFIG ~/configuration/starship.toml
	set -g fish_greeting ""
	fish_vi_key_bindings
end
