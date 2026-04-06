function runtest --description 'Run a command N times with progress'
    if test (count $argv) -lt 2
        echo "Usage: runtest <n> <command...>"
        return 1
    end

    set n $argv[1]
    set cmd $argv[2..]

    for i in (seq 1 $n)
        set percent (math --scale=0 "100 * $i / $n")
        echo "Executing iteration $i of $n ($percent%)"
        $cmd
    end
end
