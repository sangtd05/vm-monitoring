#!/bin/bash

# Script to check external access to monitoring services

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Access Check Script${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to get server IP
get_server_ip() {
    # Get local IP
    LOCAL_IP=$(hostname -I | awk '{print $1}')
    
    # Try to get external IP
    EXTERNAL_IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || curl -s --connect-timeout 5 ipinfo.io/ip 2>/dev/null || echo "unknown")
    
    echo "Local IP: $LOCAL_IP"
    echo "External IP: $EXTERNAL_IP"
}

# Function to check port accessibility
check_port() {
    local host=$1
    local port=$2
    local service=$3
    
    if timeout 5 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
        print_status "✅ $service is accessible at $host:$port"
        return 0
    else
        print_error "❌ $service is NOT accessible at $host:$port"
        return 1
    fi
}

# Function to check HTTP response
check_http() {
    local url=$1
    local service=$2
    
    if curl -s --connect-timeout 5 --max-time 10 "$url" >/dev/null 2>&1; then
        print_status "✅ $service HTTP response OK: $url"
        return 0
    else
        print_error "❌ $service HTTP response FAILED: $url"
        return 1
    fi
}

# Function to check Docker containers
check_containers() {
    print_status "Checking Docker containers status..."
    echo ""
    
    local containers=("prometheus" "grafana" "node-exporter" "cadvisor" "nginx-exporter")
    
    for container in "${containers[@]}"; do
        if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q "$container"; then
            local status=$(docker ps --format "table {{.Names}}\t{{.Status}}" | grep "$container" | awk '{print $2, $3, $4, $5}')
            print_status "✅ $container: $status"
        else
            print_error "❌ $container: Not running"
        fi
    done
}

# Function to check listening ports
check_listening_ports() {
    print_status "Checking listening ports..."
    echo ""
    
    local ports=(3000 9090 9100 8080 9113)
    local services=("Grafana" "Prometheus" "Node Exporter" "cAdvisor" "Nginx Exporter")
    
    for i in "${!ports[@]}"; do
        local port=${ports[$i]}
        local service=${services[$i]}
        
        if netstat -tlnp 2>/dev/null | grep ":$port " >/dev/null; then
            print_status "✅ $service is listening on port $port"
        else
            print_error "❌ $service is NOT listening on port $port"
        fi
    done
}

# Function to check external access
check_external_access() {
    print_status "Checking external access..."
    echo ""
    
    get_server_ip
    echo ""
    
    if [ "$EXTERNAL_IP" = "unknown" ]; then
        print_warning "Cannot determine external IP. Testing local access only."
        LOCAL_IP=$(hostname -I | awk '{print $1}')
    fi
    
    # Check local access
    print_status "Testing local access (localhost)..."
    check_port "localhost" 3000 "Grafana"
    check_port "localhost" 9090 "Prometheus"
    check_port "localhost" 9100 "Node Exporter"
    check_port "localhost" 8080 "cAdvisor"
    check_port "localhost" 9113 "Nginx Exporter"
    
    echo ""
    
    # Check local network access
    print_status "Testing local network access ($LOCAL_IP)..."
    check_port "$LOCAL_IP" 3000 "Grafana"
    check_port "$LOCAL_IP" 9090 "Prometheus"
    check_port "$LOCAL_IP" 9100 "Node Exporter"
    check_port "$LOCAL_IP" 8080 "cAdvisor"
    check_port "$LOCAL_IP" 9113 "Nginx Exporter"
    
    echo ""
    
    # Check HTTP responses
    print_status "Testing HTTP responses..."
    check_http "http://localhost:3000" "Grafana"
    check_http "http://localhost:9090" "Prometheus"
    check_http "http://localhost:9100/metrics" "Node Exporter"
    check_http "http://localhost:8080" "cAdvisor"
    check_http "http://localhost:9113/metrics" "Nginx Exporter"
}

# Function to show access URLs
show_access_urls() {
    print_status "Access URLs:"
    echo ""
    
    get_server_ip
    echo ""
    
    echo "From local machine:"
    echo "  📊 Grafana: http://localhost:3000 (admin/admin123)"
    echo "  🔍 Prometheus: http://localhost:9090"
    echo "  📈 Node Exporter: http://localhost:9100"
    echo "  🐳 cAdvisor: http://localhost:8080"
    echo "  🌐 Nginx Exporter: http://localhost:9113"
    echo ""
    
    echo "From other machines on the same network:"
    echo "  📊 Grafana: http://$LOCAL_IP:3000 (admin/admin123)"
    echo "  🔍 Prometheus: http://$LOCAL_IP:9090"
    echo "  📈 Node Exporter: http://$LOCAL_IP:9100"
    echo "  🐳 cAdvisor: http://$LOCAL_IP:8080"
    echo "  🌐 Nginx Exporter: http://$LOCAL_IP:9113"
    echo ""
    
    if [ "$EXTERNAL_IP" != "unknown" ]; then
        echo "From internet (if firewall allows):"
        echo "  📊 Grafana: http://$EXTERNAL_IP:3000 (admin/admin123)"
        echo "  🔍 Prometheus: http://$EXTERNAL_IP:9090"
        echo "  📈 Node Exporter: http://$EXTERNAL_IP:9100"
        echo "  🐳 cAdvisor: http://$EXTERNAL_IP:8080"
        echo "  🌐 Nginx Exporter: http://$EXTERNAL_IP:9113"
    fi
}

# Function to show troubleshooting tips
show_troubleshooting() {
    print_header
    print_status "Troubleshooting Tips:"
    echo ""
    echo "If you cannot access from other machines:"
    echo ""
    echo "1. Check if Docker containers are running:"
    echo "   docker compose ps"
    echo ""
    echo "2. Check if ports are listening:"
    echo "   netstat -tlnp | grep -E ':(3000|9090|9100|8080|9113) '"
    echo ""
    echo "3. Check firewall settings:"
    echo "   sudo ufw status"
    echo "   sudo iptables -L"
    echo ""
    echo "4. Configure firewall:"
    echo "   sudo ./setup-firewall.sh"
    echo ""
    echo "5. Restart Docker containers:"
    echo "   docker compose down && docker compose up -d"
    echo ""
    echo "6. Check Docker logs:"
    echo "   docker compose logs"
}

# Main execution
main() {
    print_header
    
    # Check Docker containers
    check_containers
    echo ""
    
    # Check listening ports
    check_listening_ports
    echo ""
    
    # Check external access
    check_external_access
    echo ""
    
    # Show access URLs
    show_access_urls
    echo ""
    
    # Show troubleshooting tips
    show_troubleshooting
}

# Run main function
main "$@"
