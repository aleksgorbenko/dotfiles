function go_rm_bin --description "Remove a Go binary from GOBIN/<binary_name>"
    if test (count $argv) -eq 0
        echo "Error: Binary name required"
        return 1
    end

    set binary_path "$GOBIN/$argv[1]"

    if test -f "$binary_path"
        rm "$binary_path"
        echo "✅ Removed: $binary_path"
    else
        echo "❌ No such file: $binary_path"
        return 1
    end
end
