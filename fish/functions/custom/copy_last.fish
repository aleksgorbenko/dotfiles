function copy_last --description "Run the previous command and copy output"
    # Get the last command from history
    set -l last_cmd (history --max=1)

    # Execute it and capture output
    set -l output (eval $last_cmd)

    # Copy to clipboard without trailing newline
    printf "%s" "$output" | pbcopy
    echo "copied!"
end
