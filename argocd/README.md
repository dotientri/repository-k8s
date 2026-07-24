# ArgoCD Configuration Files

Bộ cấu hình triển khai ArgoCD với giới hạn RAM và chỉ định worker node.

## 📋 Cấu trúc tệp

- **argocd-namespace.yaml** - Tạo namespace cho ArgoCD
- **argocd-server.yaml** - Deployment cho ArgoCD Server (Web UI)
  - Memory limit: 512Mi
  - CPU limit: 500m
  - Node selector: worker-1
  
- **argocd-repo-server.yaml** - Deployment cho ArgoCD Repo Server
  - Memory limit: 1Gi
  - CPU limit: 1000m
  - Node selector: worker-2
  - Pod anti-affinity để tránh chạy cùng node
  
- **argocd-application-controller.yaml** - StatefulSet cho Application Controller
  - Memory limit: 2Gi
  - CPU limit: 1000m
  - Node selector: worker-3
  
- **argocd-rbac.yaml** - RBAC configuration (ClusterRoles, ClusterRoleBindings)
- **argocd-config.yaml** - ConfigMaps cho cấu hình chung
- **argocd-application-example.yaml** - Ví dụ ArgoCD Application resources
- **deployment-script.sh** - Script tự động triển khai

## 🚀 Triển khai nhanh

### Cách 1: Sử dụng script

```bash
chmod +x deployment-script.sh
./deployment-script.sh
```

### Cách 2: Manual

```bash
# Tạo namespace
kubectl apply -f argocd-namespace.yaml

# Tạo RBAC
kubectl apply -f argocd-rbac.yaml

# Tạo ConfigMaps
kubectl apply -f argocd-config.yaml

# Triển khai các components
kubectl apply -f argocd-server.yaml
kubectl apply -f argocd-repo-server.yaml
kubectl apply -f argocd-application-controller.yaml

# (Tùy chọn) Triển khai example applications
kubectl apply -f argocd-application-example.yaml
```

## 🔧 Tùy chỉnh cấu hình

### Thay đổi Worker Node

Sửa `nodeSelector` trong các file yaml:

```yaml
nodeSelector:
  kubernetes.io/hostname: worker-1  # Thay đổi tên worker node
  workload-type: gitops
```

Để xem tên workers:
```bash
kubectl get nodes --show-labels
```

### Thay đổi Resource Limits

Sửa `resources.limits` trong các file yaml:

```yaml
resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 500m          # Giới hạn CPU
    memory: 512Mi      # Giới hạn RAM
```

### Thay đổi số replicas

```yaml
spec:
  replicas: 2  # Thay số replica
```

## 📊 Giám sát Resource Usage

```bash
# Xem resource usage từng pod
kubectl top pods -n argocd

# Xem chi tiết pod
kubectl describe pod <pod-name> -n argocd

# Xem logs
kubectl logs -n argocd deployment/argocd-server
kubectl logs -n argocd deployment/argocd-repo-server
kubectl logs -n argocd statefulset/argocd-application-controller
```

## 🔐 Keycloak / OIDC Integration (Tùy chọn)

Thêm vào `argocd-cm` ConfigMap:

```yaml
data:
  oidc.config: |
    name: Keycloak
    issuer: https://keycloak.example.com/auth/realms/argocd
    clientID: argocd-client
    clientSecret: $oidc.keycloak.clientSecret
    requestedScopes:
    - openid
    - profile
    - email
    - groups
```

## 🔄 GitOps Repository Structure

Khuyến nghị cấu trúc repo:

```
your-repo/
├── argocd/
│   ├── applications/
│   │   ├── my-app.yaml
│   │   └── my-kustomize-app.yaml
│   └── projects/
│       └── default.yaml
├── deploy/
│   ├── app/
│   │   └── kustomization.yaml
│   └── infrastructure/
├── kustomize/
│   ├── base/
│   └── overlays/
│       └── production/
└── helm/
    └── values.yaml
```

## ⚠️ Troubleshooting

### Pod không chạy trên worker node chỉ định

```bash
# Kiểm tra node labels
kubectl describe node worker-1

# Thêm label nếu cần
kubectl label nodes worker-1 workload-type=gitops
```

### Memory/CPU limit

```bash
# Xem events
kubectl describe pod <pod-name> -n argocd

# Xem resource requests/limits
kubectl get pod <pod-name> -n argocd -o yaml | grep -A 10 resources
```

### Lỗi kết nối repo

```bash
# Kiểm tra SSH known hosts
kubectl get cm -n argocd argocd-ssh-known-hosts-cm -o yaml

# Kiểm tra repository credentials
kubectl get secret -n argocd
```

## 📝 Resource Requirements

| Component | CPU Requests | Memory Requests | CPU Limits | Memory Limits |
|-----------|-------------|-----------------|-----------|---------------|
| Server | 100m | 256Mi | 500m | 512Mi |
| Repo Server | 200m | 512Mi | 1000m | 1Gi |
| App Controller | 250m | 512Mi | 1000m | 2Gi |
| **Total** | **550m** | **1.25Gi** | **2.5** | **3.5Gi** |

## 🔗 Hữu ích

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [ArgoCD Official GitHub](https://github.com/argoproj/argo-cd)
- [Kubernetes Resource Management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Node Affinity & Pod Affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)

## 📞 Support

Nếu có vấn đề:
1. Kiểm tra logs: `kubectl logs -n argocd <component>`
2. Kiểm tra events: `kubectl describe pod <pod> -n argocd`
3. Xem status: `kubectl get all -n argocd`
