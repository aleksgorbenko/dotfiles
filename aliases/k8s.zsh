# kubectl
alias k="kubectl"
alias kg="kubectl get"
alias kgp="kubectl get pods"
alias kgd="kubectl get deployments"
alias kgs="kubectl get services"
alias kga="kubectl get all"
alias kgns="kubectl get namespaces"
alias kgnp="kubectl get networkpolicy"
alias kgev="kubectl get events"
alias kgen="kubectl get endpoints"
alias kgsc="kubectl get storageclass"

alias kconf="kubectl config view | bat -l yaml"

alias ked-s="kubectl edit secret"
alias ked-s="kubectl edit configmap"


alias kd="kubectl describe"
alias kl="kubectl logs"
alias klf="kubectl logs -f"
alias ka="kubectl apply"
alias kpf="kubectl port-forward"

alias kdel="kubectl delete"
alias kda="kubectl delete --all"
alias kdap="kubectl delete --all pods"
alias kdad="kubectl delete --all deployments"

# must provide namespace
ksh() {
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
kshd() {
  podID="$(kgp | grep -i "$1" | awk '{print $1}' | head -n1)"

  if [ -z "$podID" ]; then
    echo "no pods match $1"
    return 1
  fi
    echo "shelling into default : $podID"
    kubectl exec -it -n default "$podID" -- sh
}

# kubectx
alias kc="kubectx"
alias kcu="kubectl config unset current-context"
alias ukc="unset KUBECONFIG"

# minikube
alias mk="minikube"
alias mks="minikube start"
alias mkst="minikube stop"
alias mkd="minikube delete"
alias mkrs="minikube delete; minikube start"

# Flux aliases

alias fgk="flux get kustomizations --all-namespaces"
alias fgs="flux get sources git --all-namespaces"
alias frk="flux reconcile kustomization --with-source" # --namespace"
alias frg="flux reconcile source git" # --namespace"
alias fsk="flux suspend kustomization" # --namespace"
alias frkz="flux resume kustomization" # --namespace"
alias fshr="flux suspend helmrelease" # --namespace"
alias frhr="flux resume helmrelease" # --namespace"
alias fghr="flux get helmreleases" # --all-namespaces"
alias frhl="flux reconcile helmrelease --with-source" # --namespace"
alias fdk="flux delete kustomization" # --namespace"
alias fdhr="flux delete helmrelease" # --namespace"
alias fchk="flux check --pre"

# eksctl
