function get_pid_name --argument-names cmd_name --description "Get PID and name of process"
    ps ax -o pid,comm | grep "$cmd_name" | grep -v grep
end
