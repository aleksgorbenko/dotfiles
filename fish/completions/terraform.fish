
function __complete_terraform
    set -lx COMP_LINE (commandline -cp)
    test -z (commandline -ct)
    and set COMP_LINE "$COMP_LINE "
    /Users/gbko/.config/tfenv/versions/1.14.0/terraform
end
complete -f -c terraform -a "(__complete_terraform)"

