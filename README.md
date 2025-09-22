# VM Monitoring System với Grafana + Prometheus

Hệ thống monitoring VM sử dụng Grafana và Prometheus để theo dõi tài nguyên hệ thống, lưu lượng mạng, và các dịch vụ đang chạy.

## 🚀 Tính năng

- **Monitoring tài nguyên hệ thống**: CPU, Memory, Disk, Load Average
- **Monitoring lưu lượng mạng**: Network traffic, bandwidth usage
- **Monitoring dịch vụ**: Service status, uptime
- **Alerting**: Cảnh báo khi có vấn đề xảy ra
- **Dashboard trực quan**: Giao diện Grafana dễ sử dụng

## 📋 Yêu cầu hệ thống

- Docker và Docker Compose
- ít nhất 2GB RAM
- 10GB disk space

## 🛠️ Cài đặt

### 1. Clone repository
```bash
git clone <repository-url>
cd monitoring-vm
```

### 2. Khởi động hệ thống
```bash
docker-compose up -d
```

### 3. Truy cập các dịch vụ

- **Grafana Dashboard**: http://localhost:3000
  - Username: `admin`
  - Password: `admin123`

- **Prometheus**: http://localhost:9090

- **Node Exporter**: http://localhost:9100

- **cAdvisor**: http://localhost:8080

## 📊 Dashboard

Sau khi đăng nhập vào Grafana, bạn sẽ thấy dashboard "VM Monitoring Dashboard" với các metrics:

### CPU Usage
- Hiển thị % CPU đang được sử dụng
- Cảnh báo khi CPU > 80%

### Memory Usage  
- Hiển thị % RAM đang được sử dụng
- Cảnh báo khi Memory > 85%

### Network Traffic
- Lưu lượng mạng RX/TX
- Theo dõi bandwidth real-time

### Disk I/O
- Tốc độ đọc/ghi disk
- Monitoring disk performance

### System Load Average
- Load average 1m, 5m, 15m
- Cảnh báo khi load > 4

## 🔔 Alerting

Hệ thống có các alert rules được cấu hình sẵn:

- **High CPU Usage**: CPU > 80% trong 5 phút
- **High Memory Usage**: Memory > 85% trong 5 phút  
- **High Disk Usage**: Disk > 90% trong 5 phút
- **High Load Average**: Load > 4 trong 5 phút
- **Service Down**: Service không hoạt động
- **Network Interface Down**: Network interface bị down

## 🐳 Các container

- **prometheus**: Thu thập và lưu trữ metrics
- **grafana**: Dashboard và visualization
- **node-exporter**: Thu thập system metrics
- **cadvisor**: Thu thập container metrics
- **nginx-exporter**: Thu thập nginx metrics (nếu có)

## 📁 Cấu trúc thư mục

```
monitoring-vm/
├── docker-compose.yml          # Docker Compose configuration
├── prometheus/
│   ├── prometheus.yml         # Prometheus config
│   └── rules/
│       └── vm-alerts.yml      # Alert rules
├── grafana/
│   ├── provisioning/
│   │   ├── datasources/
│   │   │   └── prometheus.yml # Prometheus datasource
│   │   └── dashboards/
│   │       └── dashboards.yml # Dashboard config
│   └── dashboards/
│       └── vm-monitoring.json # Main dashboard
└── README.md
```

## 🔧 Tùy chỉnh

### Thêm metrics mới
1. Chỉnh sửa `prometheus/prometheus.yml` để thêm job mới
2. Restart Prometheus: `docker-compose restart prometheus`

### Tùy chỉnh dashboard
1. Đăng nhập Grafana
2. Import dashboard mới hoặc chỉnh sửa dashboard hiện có
3. Export dashboard và lưu vào `grafana/dashboards/`

### Thêm alert rules
1. Chỉnh sửa `prometheus/rules/vm-alerts.yml`
2. Restart Prometheus: `docker-compose restart prometheus`

## 🚨 Troubleshooting

### Container không start
```bash
# Kiểm tra logs
docker-compose logs

# Restart tất cả services
docker-compose restart
```

### Không thấy metrics
```bash
# Kiểm tra Prometheus targets
# Truy cập http://localhost:9090/targets

# Kiểm tra Node Exporter
curl http://localhost:9100/metrics
```

### Dashboard không load
```bash
# Kiểm tra Grafana logs
docker-compose logs grafana

# Restart Grafana
docker-compose restart grafana
```

## 📈 Mở rộng

### Thêm monitoring cho nhiều server
1. Cài đặt Node Exporter trên các server khác
2. Cập nhật `prometheus.yml` với targets mới
3. Restart Prometheus

### Thêm monitoring cho database
- MySQL Exporter
- PostgreSQL Exporter  
- MongoDB Exporter

### Thêm monitoring cho web server
- Apache Exporter
- Nginx Exporter (đã có sẵn)

## 🔒 Bảo mật

- Thay đổi password Grafana mặc định
- Sử dụng reverse proxy (nginx) với SSL
- Giới hạn truy cập từ IP cụ thể
- Sử dụng firewall để bảo vệ ports

## 📞 Hỗ trợ

Nếu gặp vấn đề, vui lòng tạo issue hoặc liên hệ qua email.

---

**Lưu ý**: Đây là hệ thống monitoring cơ bản. Để sử dụng trong production, cần thêm các tính năng bảo mật và tối ưu hóa.
