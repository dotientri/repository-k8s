#!/bin/bash
# Script triển khai ArgoCD với các cấu hình RAM và worker node

set -e

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}===== ArgoCD Deployment Script =====${NC}"

# Kiểm tra kubectl
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}kubectl không được cài đặt${NC}"
    exit 1
fi

# Kiểm tra connection tới cluster
echo -e "${YELLOW}Kiểm tra kết nối Kubernetes...${NC}"
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}Không thể kết nối tới Kubernetes cluster${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Kết nối thành công${NC}"

# 1. Tạo namespace
echo -e "${YELLOW}1. Tạo namespace argocd...${NC}"
kubectl apply -f argocd-namespace.yaml

# 2. Áp dụng RBAC
echo -e "${YELLOW}2. Cấu hình RBAC...${NC}"
kubectl apply -f argocd-rbac.yaml

# 3. Áp dụng ConfigMaps
echo -e "${YELLOW}3. Cấu hình ConfigMaps...${NC}"
kubectl apply -f argocd-config.yaml

# 4. Tạo Repo Server Secrets (nếu cần)
echo -e "${YELLOW}4. Tạo TLS secrets cho repo server...${NC}"
# Tạo self-signed cert nếu chưa có
if ! kubectl get secret -n argocd argocd-repo-server-tls &> /dev/null; then
    echo "Tạo TLS certificate cho repo server..."
    
    # Tạo private key
    openssl genrsa -out /tmp/repo-server-key.pem 2048
    
    # Tạo certificate
    openssl req -new -x509 -key /tmp/repo-server-key.pem -out /tmp/repo-server-cert.pem \
        -subj "/CN=argocd-repo-server.argocd.svc.cluster.local" \
        -addext "subjectAltName=DNS:argocd-repo-server,DNS:argocd-repo-server.argocd,DNS:argocd-repo-server.argocd.svc,DNS:argocd-repo-server.argocd.svc.cluster.local" \
        -days 365
    
    # Tạo secret
    kubectl create secret tls argocd-repo-server-tls \
        --cert=/tmp/repo-server-cert.pem \
        --key=/tmp/repo-server-key.pem \
        -n argocd
    
    # Clean up
    rm -f /tmp/repo-server-key.pem /tmp/repo-server-cert.pem
    
    echo -e "${GREEN}✓ TLS secret tạo thành công${NC}"
fi

# 5. Deploy ArgoCD components
echo -e "${YELLOW}5. Triển khai ArgoCD Server...${NC}"
kubectl apply -f argocd-server.yaml

echo -e "${YELLOW}6. Triển khai ArgoCD Repo Server...${NC}"
kubectl apply -f argocd-repo-server.yaml

echo -e "${YELLOW}7. Triển khai ArgoCD Application Controller...${NC}"
kubectl apply -f argocd-application-controller.yaml

# 6. Chờ pod sẵn sàng
echo -e "${YELLOW}8. Chờ pods sẵn sàng...${NC}"
kubectl rollout status deployment/argocd-server -n argocd --timeout=5m
kubectl rollout status deployment/argocd-repo-server -n argocd --timeout=5m
kubectl rollout status statefulset/argocd-application-controller -n argocd --timeout=5m

echo -e "${GREEN}✓ ArgoCD pods đã sẵn sàng${NC}"

# 7. Hiển thị thông tin
echo -e "${GREEN}===== Triển khai hoàn tất =====${NC}"
echo -e "${YELLOW}Thông tin pods:${NC}"
kubectl get pods -n argocd -o wide

echo -e "${YELLOW}Thông tin services:${NC}"
kubectl get svc -n argocd

echo -e "${YELLOW}Thông tin resource usage:${NC}"
kubectl top pods -n argocd --no-headers 2>/dev/null || echo "Metrics server chưa được cài đặt"

# 8. Lấy token admin
echo -e "${YELLOW}Lấy token admin ArgoCD:${NC}"
ADMIN_TOKEN=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d || echo "Secret chưa tạo")

if [ "$ADMIN_TOKEN" != "Secret chưa tạo" ]; then
    echo -e "${GREEN}Admin Token: $ADMIN_TOKEN${NC}"
fi

echo -e "${GREEN}===== Setup hoàn tất! =====${NC}"
echo -e "${YELLOW}Hướng dẫn tiếp theo:${NC}"
echo "1. Port forward: kubectl port-forward -n argocd svc/argocd-server 8080:80"
echo "2. Truy cập: https://localhost:8080"
echo "3. Username: admin"
echo "4. Password: [xem ở trên]"
