# VM Monitoring System với Grafana + Prometheus + Blackbox

Hệ thống monitoring VM hoàn chỉnh sử dụng Grafana, Prometheus và Blackbox Exporter để theo dõi tài nguyên hệ thống, lưu lượng mạng, và uptime của các dịch vụ.

## 🚀 Tính năng

- **Monitoring tài nguyên hệ thống**: CPU, Memory, Disk, Load Average
- **Monitoring lưu lượng mạng**: Network traffic, bandwidth usage
- **Service Uptime Monitoring**: Kiểm tra uptime và health của services
- **Container Monitoring**: Theo dõi Docker containers
- **Alerting**: Cảnh báo tự động khi có vấn đề xảy ra
- **Dashboard trực quan**: Giao diện Grafana dễ sử dụng
- **External Access**: Truy cập từ máy khác trong mạng

## 🛠️ Cài đặt

### 1. Clone repository
```bash
git clone <repository-url>
cd monitoring-vm
```

### 2. Cấu hình môi trường (tùy chọn)
```bash
# Copy file cấu hình mẫu
cp env.example .env

# Chỉnh sửa cấu hình nếu cần
nano .env
```

### 3. Khởi động hệ thống
```bash
# Cấp quyền thực thi cho script
chmod +x vm-monitor.sh

# Khởi động hệ thống
./vm-monitor.sh start
```

### 4. Cấu hình Firewall (nếu cần)
```bash
# Cấu hình firewall tự động
sudo ./vm-monitor.sh firewall
```

## 📊 Truy cập các dịch vụ

### Từ máy local:
- **Grafana Dashboard**: http://localhost:3000 (admin/admin123)
- **Prometheus**: http://localhost:9090
- **Node Exporter**: http://localhost:9100
- **cAdvisor**: http://localhost:8080
- **Nginx Exporter**: http://localhost:9113
- **Blackbox Exporter**: http://localhost:9115

### Từ máy khác trong mạng:
Thay `localhost` bằng IP của máy chủ:
- **Grafana Dashboard**: http://[IP-MÁY-CHỦ]:3000
- **Prometheus**: http://[IP-MÁY-CHỦ]:9090
- **Node Exporter**: http://[IP-MÁY-CHỦ]:9100
- **cAdvisor**: http://[IP-MÁY-CHỦ]:8080
- **Nginx Exporter**: http://[IP-MÁY-CHỦ]:9113
- **Blackbox Exporter**: http://[IP-MÁY-CHỦ]:9115

## 📈 Dashboards

### VM Monitoring Dashboard
- **CPU Usage**: Hiển thị % CPU đang được sử dụng
- **Memory Usage**: Hiển thị % RAM đang được sử dụng
- **Network Traffic**: Lưu lượng mạng RX/TX
- **Disk I/O**: Tốc độ đọc/ghi disk
- **System Load Average**: Load average 1m, 5m, 15m

### Blackbox Monitoring Dashboard
- **Service Uptime Status**: Trạng thái UP/DOWN của services
- **Response Time Tracking**: Thời gian phản hồi của services
- **HTTP Status Monitoring**: HTTP status codes
- **Uptime Percentage**: % uptime trong 5 phút và 1 giờ
- **HTTP Duration Breakdown**: Phân tích chi tiết thời gian request

## 🔔 Alerting

Hệ thống có các alert rules được cấu hình sẵn:

### System Alerts
- **High CPU Usage**: CPU > 80% trong 5 phút
- **High Memory Usage**: Memory > 85% trong 5 phút  
- **High Disk Usage**: Disk > 90% trong 5 phút
- **High Load Average**: Load > 4 trong 5 phút
- **Service Down**: Service không hoạt động
- **Network Interface Down**: Network interface bị down

### Blackbox Alerts
- **Service Down (Blackbox)**: Service down từ góc độ external
- **High Response Time**: Response time > 5 giây
- **HTTP Error Status**: HTTP status code lỗi (4xx, 5xx)

## 🐳 Các container

- **prometheus**: Thu thập và lưu trữ metrics
- **grafana**: Dashboard và visualization
- **node-exporter**: Thu thập system metrics
- **cadvisor**: Thu thập container metrics
- **nginx-exporter**: Thu thập nginx metrics
- **blackbox-exporter**: Kiểm tra uptime và health của services

## 🛠️ Quản lý hệ thống

Sử dụng script `vm-monitor.sh` để quản lý hệ thống:

```bash
# Khởi động hệ thống
./vm-monitor.sh start

# Dừng hệ thống
./vm-monitor.sh stop

# Khởi động lại hệ thống
./vm-monitor.sh restart

# Kiểm tra trạng thái
./vm-monitor.sh status

# Xem logs
./vm-monitor.sh logs

# Xem logs của service cụ thể
./vm-monitor.sh logs grafana

# Cập nhật hệ thống
./vm-monitor.sh update

# Backup cấu hình
./vm-monitor.sh backup

# Cấu hình firewall
sudo ./vm-monitor.sh firewall

# Kiểm tra kết nối
./vm-monitor.sh access

# Hiển thị thông tin truy cập
./vm-monitor.sh info

# Hiển thị trợ giúp
./vm-monitor.sh help
```

## 📁 Cấu trúc thư mục

```
monitoring-vm/
├── vm-monitor.sh                    # Script quản lý chính
├── docker-compose.yml               # Docker Compose configuration
├── env.example                      # File cấu hình môi trường mẫu
├── .gitignore                       # Git ignore rules
├── prometheus/
│   ├── prometheus.yml              # Prometheus config
│   └── rules/
│       └── vm-alerts.yml           # Alert rules
├── blackbox/
│   └── blackbox.yml                # Blackbox exporter config
├── grafana/
│   ├── provisioning/
│   │   ├── datasources/
│   │   │   └── prometheus.yml      # Prometheus datasource
│   │   └── dashboards/
│   │       └── dashboards.yml      # Dashboard config
│   └── dashboards/
│       ├── vm-monitoring.json      # Main VM dashboard
│       └── blackbox-monitoring.json # Blackbox monitoring dashboard
└── README.md
```

## 🔧 Tùy chỉnh

### Thêm metrics mới
1. Chỉnh sửa `prometheus/prometheus.yml` để thêm job mới
2. Restart Prometheus: `./vm-monitor.sh restart`

### Tùy chỉnh dashboard
1. Đăng nhập Grafana
2. Import dashboard mới hoặc chỉnh sửa dashboard hiện có
3. Export dashboard và lưu vào `grafana/dashboards/`

### Thêm alert rules
1. Chỉnh sửa `prometheus/rules/vm-alerts.yml`
2. Restart Prometheus: `./vm-monitor.sh restart`

### Thêm services để monitor
1. Chỉnh sửa `prometheus/prometheus.yml` để thêm targets
2. Cập nhật `blackbox/blackbox.yml` nếu cần
3. Restart hệ thống: `./vm-monitor.sh restart`

## 🚨 Troubleshooting

### Container không start
```bash
# Kiểm tra logs
./vm-monitor.sh logs

# Kiểm tra trạng thái
./vm-monitor.sh status

# Restart tất cả services
./vm-monitor.sh restart
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
./vm-monitor.sh logs grafana

# Restart Grafana
./vm-monitor.sh restart
```

### Không thể truy cập từ máy khác
```bash
# Kiểm tra kết nối
./vm-monitor.sh access

# Cấu hình firewall
sudo ./vm-monitor.sh firewall

# Kiểm tra ports
netstat -tlnp | grep -E ':(3000|9090|9100|8080|9113|9115) '
```

## 🔒 Bảo mật

- Thay đổi password Grafana mặc định trong `.env`
- Sử dụng reverse proxy (nginx) với SSL
- Giới hạn truy cập từ IP cụ thể
- Sử dụng firewall để bảo vệ ports
- Cập nhật Docker images thường xuyên