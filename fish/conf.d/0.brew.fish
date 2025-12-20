# Initialize Homebrew
# This must run first (0. prefix) to ensure brew is available for other tools
if test -d /opt/homebrew
    eval (/opt/homebrew/bin/brew shellenv)
end
