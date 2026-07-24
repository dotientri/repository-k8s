# Monitoring stack (Prometheus + Alertmanager(Telegram) + Grafana + Loki)

Thư mục này chứa các manifests Kubernetes tối thiểu để triển khai một stack monitoring đơn giản trong namespace `monitoring`.

Files included:
- `manifests/namespace.yaml` - namespace `monitoring`
- `manifests/*.yaml` - manifests cho Prometheus, Alertmanager, Grafana, Loki, Promtail

Quick start
1. Tạo namespace và secret Telegram (thay thế token/chat id thật):

```bash
kubectl apply -f manifests/namespace.yaml
kubectl apply -f manifests/alertmanager-secret.yaml
```

2. Áp dụng các manifests:

```bash
kubectl apply -n monitoring -f manifests/alertmanager-config.yaml
kubectl apply -n monitoring -f manifests/alertmanager-deployment.yaml
kubectl apply -n monitoring -f manifests/alertmanager-service.yaml
kubectl apply -n monitoring -f manifests/prometheus-config.yaml
kubectl apply -n monitoring -f manifests/prometheus-deployment.yaml
kubectl apply -n monitoring -f manifests/prometheus-service.yaml
kubectl apply -n monitoring -f manifests/grafana-deployment.yaml
kubectl apply -n monitoring -f manifests/grafana-service.yaml
# Loki + Promtail instead of ELK
kubectl apply -n monitoring -f manifests/loki-configmap.yaml
kubectl apply -n monitoring -f manifests/loki-deployment.yaml
kubectl apply -n monitoring -f manifests/loki-service.yaml
kubectl apply -n monitoring -f manifests/promtail-configmap.yaml
kubectl apply -n monitoring -f manifests/promtail-daemonset.yaml
# (Optional) Provision Grafana datasource from configmap
kubectl apply -n monitoring -f manifests/grafana-datasource-loki.yaml
```

3. Tạo Telegram bot (BotFather) và lấy token, chat ID
- Mở Telegram, tìm `@BotFather` và tạo bot mới (`/newbot`), theo hướng dẫn để lấy token.
- Lấy `chat_id`: gửi tin nhắn tới bot, sau đó mở `https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates` để xem `chat.id`.

4. Cấu hình Alertmanager gửi tới Telegram
- Cập nhật `manifests/alertmanager-secret.yaml` với `TELEGRAM_BOT_TOKEN` và `TELEGRAM_CHAT_ID`, rồi `kubectl apply -f` lại. Alertmanager deployment đọc secret làm biến môi trường và dùng trong config.

Notes & next steps
- Đây là cấu hình tối giản: trong môi trường production cần PVC bền vững cho Prometheus/Alertmanager/Grafana, cấu hình bảo mật, RBAC, và scaling.
 - Để Grafana hiển thị dashboards tự động, bạn có thể thêm ConfigMap provisioning cho datasources và dashboards.
