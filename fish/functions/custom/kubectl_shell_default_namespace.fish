function kubectl_shell_default_namespace --description "Shell into kubernetes pod in default namespace by pattern"
    set -l podID (kubectl get pods | grep -i "$argv[1]" | awk '{print $1}' | head -n1)

    if test -z "$podID"
        echo "no pods match $argv[1]"
        return 1
    end

    echo "shelling into default : $podID"
    kubectl exec -it -n default "$podID" -- sh
end
