# Loki stack manifests

Thư mục này dùng để lưu các manifest triển khai Loki stack riêng biệt khỏi ELK.

## Nội dung đề xuất

- Loki Deployment
- Loki Service
- Promtail DaemonSet
- ConfigMaps liên quan

## Triển khai

```bash
kubectl apply -f monitoring/manifests/namespace.yaml
kubectl apply -n monitoring -f monitoring/manifests/
```
