set fish_greeting

if status is-interactive
	set -x STARSHIP_CONFIG ~/configuration/starship.toml
end
