# must provide namespace
function ksh() {
  ns="$1"
  term="$2"

  kubectl get ns "$ns" >/dev/null 2>&1 || {
    echo "namespace not found: $ns"
    return 1
  }

  podID="$(kubectl get pods -n "$ns" \
            | grep -i "$term" \
            | awk '{print $1}' \
            | head -n1)"

  if [ -z "$podID" ]; then
    echo "no pods match $term in $ns"
    return 1
  fi
    echo "shelling into $ns : $podID"
  kubectl exec -it -n "$ns" "$podID" -- sh
}

# default namespace
function kshd() {
  podID="$(kgp | grep -i "$1" | awk '{print $1}' | head -n1)"

  if [ -z "$podID" ]; then
    echo "no pods match $1"
    return 1
  fi
    echo "shelling into default : $podID"
    kubectl exec -it -n default "$podID" -- sh
}
