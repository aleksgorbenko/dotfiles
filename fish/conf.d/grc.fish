# Colored output for common unix commands (grc)
if test -f /opt/homebrew/etc/grc.fish
    source /opt/homebrew/etc/grc.fish

    # Disable GRC for problematic commands that hang
    functions -e netstat 2>/dev/null
end
