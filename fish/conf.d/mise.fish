# Initialize mise (version manager)
# This adds mise shims to PATH and enables shell integration
# Use full path since Homebrew might not be in PATH yet during conf.d loading
if test -x /opt/homebrew/bin/mise
    /opt/homebrew/bin/mise activate fish | source
end
