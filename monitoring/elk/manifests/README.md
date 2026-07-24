# ELK stack placeholder

Thư mục này dùng để phân tách stack ELK khỏi Loki.

Hiện tại repo chưa chứa manifest ELK đầy đủ. Nếu cần, bạn có thể thêm:

- Elasticsearch StatefulSet
- Kibana Deployment
- Filebeat/Fluent Bit DaemonSet
- Service và PVC cho dữ liệu

## Mục tiêu

Tách riêng ELK khỏi Loki để dễ quản lý và triển khai bằng ArgoCD/GitOps.
