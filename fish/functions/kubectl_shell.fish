function kubectl_shell --description "Shell into kubernetes pod by namespace and pattern"
    set -l ns $argv[1]
    set -l term $argv[2]

    kubectl get ns "$ns" >/dev/null 2>&1; or begin
        echo "namespace not found: $ns"
        return 1
    end

    set -l podID (kubectl get pods -n "$ns" \
        | grep -i "$term" \
        | awk '{print $1}' \
        | head -n1)

    if test -z "$podID"
        echo "no pods match $term in $ns"
        return 1
    end

    echo "shelling into $ns : $podID"
    kubectl exec -it -n "$ns" "$podID" -- sh
end
