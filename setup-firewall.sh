#!/bin/bash

# Script to configure firewall for external access

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
    echo -e "${BLUE}  Firewall Configuration Script${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script needs to be run as root or with sudo"
        print_status "Please run: sudo $0"
        exit 1
    fi
}

# Function to get server IP
get_server_ip() {
    # Try to get external IP
    EXTERNAL_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo "unknown")
    
    # Get local IP
    LOCAL_IP=$(hostname -I | awk '{print $1}')
    
    echo "External IP: $EXTERNAL_IP"
    echo "Local IP: $LOCAL_IP"
}

# Function to configure UFW firewall
configure_ufw() {
    print_status "Configuring UFW firewall..."
    
    # Enable UFW if not already enabled
    ufw --force enable
    
    # Allow SSH
    ufw allow ssh
    
    # Allow monitoring ports
    ufw allow 3000/tcp comment "Grafana"
    ufw allow 9090/tcp comment "Prometheus"
    ufw allow 9100/tcp comment "Node Exporter"
    ufw allow 8080/tcp comment "cAdvisor"
    ufw allow 9113/tcp comment "Nginx Exporter"
    
    # Show status
    ufw status verbose
    
    print_status "✅ UFW firewall configured successfully"
}

# Function to configure iptables
configure_iptables() {
    print_status "Configuring iptables rules..."
    
    # Allow monitoring ports
    iptables -A INPUT -p tcp --dport 3000 -j ACCEPT -m comment --comment "Grafana"
    iptables -A INPUT -p tcp --dport 9090 -j ACCEPT -m comment --comment "Prometheus"
    iptables -A INPUT -p tcp --dport 9100 -j ACCEPT -m comment --comment "Node Exporter"
    iptables -A INPUT -p tcp --dport 8080 -j ACCEPT -m comment --comment "cAdvisor"
    iptables -A INPUT -p tcp --dport 9113 -j ACCEPT -m comment --comment "Nginx Exporter"
    
    # Save iptables rules (Ubuntu/Debian)
    if command -v iptables-save >/dev/null 2>&1; then
        iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
    fi
    
    print_status "✅ iptables rules configured successfully"
}

# Function to check if ports are listening
check_ports() {
    print_status "Checking if ports are listening..."
    
    local ports=(3000 9090 9100 8080 9113)
    local services=("Grafana" "Prometheus" "Node Exporter" "cAdvisor" "Nginx Exporter")
    
    for i in "${!ports[@]}"; do
        local port=${ports[$i]}
        local service=${services[$i]}
        
        if netstat -tlnp | grep ":$port " >/dev/null 2>&1; then
            print_status "✅ $service is listening on port $port"
        else
            print_warning "❌ $service is not listening on port $port"
        fi
    done
}

# Function to show access information
show_access_info() {
    print_header
    print_status "Access Information:"
    echo ""
    
    get_server_ip
    echo ""
    
    print_status "You can now access the monitoring system from other machines:"
    echo ""
    echo "  📊 Grafana Dashboard:"
    echo "     http://$LOCAL_IP:3000 (admin/admin123)"
    if [ "$EXTERNAL_IP" != "unknown" ]; then
        echo "     http://$EXTERNAL_IP:3000 (admin/admin123)"
    fi
    echo ""
    echo "  🔍 Prometheus:"
    echo "     http://$LOCAL_IP:9090"
    if [ "$EXTERNAL_IP" != "unknown" ]; then
        echo "     http://$EXTERNAL_IP:9090"
    fi
    echo ""
    echo "  📈 Node Exporter:"
    echo "     http://$LOCAL_IP:9100"
    if [ "$EXTERNAL_IP" != "unknown" ]; then
        echo "     http://$EXTERNAL_IP:9100"
    fi
    echo ""
    echo "  🐳 cAdvisor:"
    echo "     http://$LOCAL_IP:8080"
    if [ "$EXTERNAL_IP" != "unknown" ]; then
        echo "     http://$EXTERNAL_IP:8080"
    fi
    echo ""
    echo "  🌐 Nginx Exporter:"
    echo "     http://$LOCAL_IP:9113"
    if [ "$EXTERNAL_IP" != "unknown" ]; then
        echo "     http://$EXTERNAL_IP:9113"
    fi
}

# Function to test external access
test_external_access() {
    print_status "Testing external access..."
    
    local ports=(3000 9090 9100 8080 9113)
    local services=("Grafana" "Prometheus" "Node Exporter" "cAdvisor" "Nginx Exporter")
    
    for i in "${!ports[@]}"; do
        local port=${ports[$i]}
        local service=${services[$i]}
        
        if timeout 5 bash -c "</dev/tcp/localhost/$port" 2>/dev/null; then
            print_status "✅ $service is accessible on port $port"
        else
            print_warning "❌ $service is not accessible on port $port"
        fi
    done
}

# Main execution
main() {
    print_header
    
    # Check if running as root
    check_root
    
    # Check current status
    check_ports
    
    echo ""
    print_warning "This script will configure firewall to allow external access to:"
    echo "  - Grafana (port 3000)"
    echo "  - Prometheus (port 9090)"
    echo "  - Node Exporter (port 9100)"
    echo "  - cAdvisor (port 8080)"
    echo "  - Nginx Exporter (port 9113)"
    echo ""
    
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Operation cancelled"
        exit 0
    fi
    
    # Configure firewall
    if command -v ufw >/dev/null 2>&1; then
        configure_ufw
    else
        configure_iptables
    fi
    
    # Test access
    test_external_access
    
    # Show access information
    show_access_info
    
    print_status "🎉 Firewall configuration completed!"
    print_warning "Make sure your Docker containers are running with:"
    echo "  docker compose up -d"
}

# Run main function
main "$@"
