if status --is-interactive && command -q zoxide
    zoxide init --cmd cd fish | source
end
