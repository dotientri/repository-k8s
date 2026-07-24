# Kubernetes GitOps Repository

Repo này dùng để quản lý các tài nguyên Kubernetes theo hướng GitOps, bao gồm:

- ArgoCD: triển khai và quản lý các ứng dụng trên cluster
- Monitoring: Prometheus + Alertmanager + Grafana + Loki/Promtail
- GitOps applications: các ứng dụng mẫu và cấu hình triển khai

## Cấu trúc thư mục

```text
.
├── argocd/                 # Manifests triển khai ArgoCD
├── gitops/                 # Các ứng dụng và cấu hình GitOps
│   └── applications/       # Ví dụ Application CR cho ArgoCD
├── monitoring/             # Stack observability
│   ├── manifests/          # Manifests hiện tại cho Prometheus/Grafana/Loki
│   ├── loki/              # Hướng dẫn và manifests cho Loki stack
│   └── elk/               # Khu vực dành cho ELK stack riêng
```

## Triển khai nhanh

1. Triển khai ArgoCD:
   ```bash
   cd argocd
   ./deployment-script.sh
   ```

2. Triển khai monitoring:
   ```bash
   kubectl apply -f monitoring/manifests/namespace.yaml
   kubectl apply -n monitoring -f monitoring/manifests/
   ```

3. Đăng ký GitOps applications trong ArgoCD:
   ```bash
   kubectl apply -f gitops/applications/
   ```

## Lưu ý

- Loki/Promtail là lựa chọn hiện tại cho logging stack.
- ELK có thể được tách riêng trong thư mục [monitoring/elk](monitoring/elk) nếu bạn muốn triển khai một stack logging khác.
- ArgoCD có thể triển khai repo này nếu cluster đã có đủ quyền truy cập và node phù hợp cho các pod.
