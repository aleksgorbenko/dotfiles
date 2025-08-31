# kubectl
alias k="kubectl"
alias kg="kubectl get"
alias kgp="kubectl get pods"
alias kgd="kubectl get deployments"
alias kgs="kubectl get services"
alias kga="kubectl get all"

alias kd="kubectl describe"
alias kl="kubectl logs"
alias klf="kubectl logs -f"
alias ka="kubectl apply"
alias kpf="kubectl port-forward"

alias kdel="kubectl delete"
alias kda="kubectl delete --all"
alias kdap="kubectl delete --all pods"
alias kdad="kubectl delete --all deployments"

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
