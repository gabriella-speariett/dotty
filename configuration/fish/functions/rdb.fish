function rdb --description 'Open a telnet debug session in a running Docker container'
    set container $argv[1]
    set port (if test (count $argv) -gt 1; echo $argv[2]; else; echo 6899; end)
    docker exec -itu root $container \
        bash -c "apt update -qq && apt install -qq --assume-yes --no-install-recommends telnet && telnet localhost $port"
end
