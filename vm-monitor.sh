#!/bin/bash

# VM Monitoring System - Complete Management Script
# This script handles all monitoring system operations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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
    echo -e "${BLUE}  VM Monitoring System${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Function to create necessary directories
create_directories() {
    print_status "Creating necessary directories..."
    mkdir -p prometheus/rules
    mkdir -p grafana/provisioning/datasources
    mkdir -p grafana/provisioning/dashboards
    mkdir -p grafana/dashboards
    mkdir -p blackbox
}

# Function to start monitoring system
start_monitoring() {
    print_header
    print_status "Starting VM Monitoring System with Blackbox Exporter..."
    
    check_docker
    create_directories
    
    # Start services
    docker compose up -d
    
    print_status "Waiting for services to start..."
    sleep 15
    
    # Check service status
    if docker compose ps | grep -q "Up"; then
        print_status "✅ Monitoring system started successfully!"
        echo ""
        print_status "Services running:"
        docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
        echo ""
    else
        print_error "Failed to start monitoring system"
        docker compose logs
        exit 1
    fi
}

# Function to stop monitoring system
stop_monitoring() {
    print_header
    print_status "Stopping VM Monitoring System..."
    
    docker compose down
    
    print_status "✅ Monitoring system stopped successfully!"
}

# Function to restart monitoring system
restart_monitoring() {
    print_header
    print_status "Restarting VM Monitoring System..."
    
    docker compose restart
    
    print_status "✅ Monitoring system restarted successfully!"
}

# Function to show service status
show_status() {
    print_header
    print_status "Service Status:"
    echo ""
    
    docker compose ps
    
    echo ""
    print_status "Service Health Check:"
    
    # Check Prometheus
    if curl -s http://localhost:9090/-/healthy > /dev/null 2>&1; then
        print_status "✅ Prometheus: Healthy"
    else
        print_error "❌ Prometheus: Unhealthy"
    fi
    
    # Check Grafana
    if curl -s http://localhost:3000/api/health > /dev/null 2>&1; then
        print_status "✅ Grafana: Healthy"
    else
        print_error "❌ Grafana: Unhealthy"
    fi
    
    # Check Node Exporter
    if curl -s http://localhost:9100/metrics > /dev/null 2>&1; then
        print_status "✅ Node Exporter: Healthy"
    else
        print_error "❌ Node Exporter: Unhealthy"
    fi
    
    # Check cAdvisor
    if curl -s http://localhost:8080/healthz > /dev/null 2>&1; then
        print_status "✅ cAdvisor: Healthy"
    else
        print_error "❌ cAdvisor: Unhealthy"
    fi
    
    # Check Blackbox Exporter
    if curl -s http://localhost:9115 > /dev/null 2>&1; then
        print_status "✅ Blackbox Exporter: Healthy"
    else
        print_error "❌ Blackbox Exporter: Unhealthy"
    fi
}

# Function to show logs
show_logs() {
    print_header
    print_status "Showing logs for all services..."
    echo ""
    
    docker compose logs -f
}

# Function to show specific service logs
show_service_logs() {
    local service=$1
    print_header
    print_status "Showing logs for $service..."
    echo ""
    
    docker compose logs -f $service
}

# Function to update system
update_system() {
    print_header
    print_status "Updating monitoring system..."
    
    docker compose pull
    docker compose up -d
    
    print_status "✅ Monitoring system updated successfully!"
}

# Function to backup configuration
backup_config() {
    local backup_dir="backup_$(date +%Y%m%d_%H%M%S)"
    
    print_header
    print_status "Creating backup in $backup_dir..."
    
    mkdir -p $backup_dir
    cp -r prometheus $backup_dir/
    cp -r grafana $backup_dir/
    cp -r blackbox $backup_dir/
    cp docker-compose.yml $backup_dir/
    
    print_status "✅ Backup created successfully in $backup_dir/"
}

# Function to configure firewall
configure_firewall() {
    print_header
    print_status "Configuring firewall for external access..."
    
    if [ "$EUID" -ne 0 ]; then
        print_error "This operation needs to be run as root or with sudo"
        print_status "Please run: sudo $0 firewall"
        exit 1
    fi
    
    # Configure UFW if available
    if command -v ufw >/dev/null 2>&1; then
        print_status "Configuring UFW firewall..."
        
        # Enable UFW if not enabled
        ufw --force enable
        
        # Allow monitoring ports
        ufw allow 3000/tcp comment "Grafana"
        ufw allow 9090/tcp comment "Prometheus"
        ufw allow 9100/tcp comment "Node Exporter"
        ufw allow 8080/tcp comment "cAdvisor"
        ufw allow 9113/tcp comment "Nginx Exporter"
        ufw allow 9115/tcp comment "Blackbox Exporter"
        
        print_status "✅ UFW firewall configured"
    else
        print_status "Configuring iptables..."
        
        # Allow monitoring ports with iptables
        iptables -A INPUT -p tcp --dport 3000 -j ACCEPT -m comment --comment "Grafana"
        iptables -A INPUT -p tcp --dport 9090 -j ACCEPT -m comment --comment "Prometheus"
        iptables -A INPUT -p tcp --dport 9100 -j ACCEPT -m comment --comment "Node Exporter"
        iptables -A INPUT -p tcp --dport 8080 -j ACCEPT -m comment --comment "cAdvisor"
        iptables -A INPUT -p tcp --dport 9113 -j ACCEPT -m comment --comment "Nginx Exporter"
        iptables -A INPUT -p tcp --dport 9115 -j ACCEPT -m comment --comment "Blackbox Exporter"
        
        # Save iptables rules
        if command -v iptables-save >/dev/null 2>&1; then
            iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
        fi
        
        print_status "✅ iptables configured"
    fi
}

# Function to check access
check_access() {
    print_header
    print_status "Checking service accessibility..."
    echo ""
    
    local local_ip=$(hostname -I | awk '{print $1}')
    local external_ip=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || echo "unknown")
    
    echo "Local IP: $local_ip"
    echo "External IP: $external_ip"
    echo ""
    
    # Test localhost
    print_status "Testing localhost access:"
    for port in 3000 9090 9100 8080 9113 9115; do
        if timeout 3 bash -c "</dev/tcp/localhost/$port" 2>/dev/null; then
            print_status "✅ localhost:$port - OK"
        else
            print_error "❌ localhost:$port - FAILED"
        fi
    done
    echo ""
    
    # Test local IP
    print_status "Testing local IP ($local_ip) access:"
    for port in 3000 9090 9100 8080 9113 9115; do
        if timeout 3 bash -c "</dev/tcp/$local_ip/$port" 2>/dev/null; then
            print_status "✅ $local_ip:$port - OK"
        else
            print_error "❌ $local_ip:$port - FAILED"
        fi
    done
}

# Function to show access information
show_access_info() {
    print_header
    print_status "Access Information:"
    echo ""
    
    local local_ip=$(hostname -I | awk '{print $1}')
    local external_ip=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || echo "unknown")
    
    echo "Local IP: $local_ip"
    echo "External IP: $external_ip"
    echo ""
    
    print_status "Monitoring Services:"
    echo ""
    echo "  📊 Grafana Dashboard:"
    echo "     http://localhost:3000 (admin/admin123)"
    echo "     http://$local_ip:3000 (admin/admin123)"
    echo ""
    echo "  🔍 Prometheus:"
    echo "     http://localhost:9090"
    echo "     http://$local_ip:9090"
    echo ""
    echo "  📈 Node Exporter:"
    echo "     http://localhost:9100"
    echo "     http://$local_ip:9100"
    echo ""
    echo "  🐳 cAdvisor:"
    echo "     http://localhost:8080"
    echo "     http://$local_ip:8080"
    echo ""
    echo "  🌐 Nginx Exporter:"
    echo "     http://localhost:9113"
    echo "     http://$local_ip:9113"
    echo ""
    echo "  ⚫ Blackbox Exporter:"
    echo "     http://localhost:9115"
    echo "     http://$local_ip:9115"
    echo ""
    
    print_status "Dashboards:"
    echo ""
    echo "  📊 VM Monitoring Dashboard:"
    echo "     http://localhost:3000/d/vm-monitoring"
    echo "     http://$local_ip:3000/d/vm-monitoring"
    echo ""
    echo "  ⚫ Blackbox Monitoring Dashboard:"
    echo "     http://localhost:3000/d/blackbox-monitoring"
    echo "     http://$local_ip:3000/d/blackbox-monitoring"
    echo ""
    
    print_status "Prometheus Targets:"
    echo ""
    echo "  📊 All Targets:"
    echo "     http://localhost:9090/targets"
    echo "     http://$local_ip:9090/targets"
    echo ""
    echo "  ⚫ Blackbox Targets:"
    echo "     http://localhost:9090/targets?search=blackbox"
    echo "     http://$local_ip:9090/targets?search=blackbox"
}

# Function to show help
show_help() {
    print_header
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start       Start the monitoring system"
    echo "  stop        Stop the monitoring system"
    echo "  restart     Restart the monitoring system"
    echo "  status      Show service status and health"
    echo "  logs        Show logs for all services"
    echo "  logs [svc]  Show logs for specific service"
    echo "  update      Update all containers to latest version"
    echo "  backup      Backup current configuration"
    echo "  firewall    Configure firewall for external access (requires sudo)"
    echo "  access      Check service accessibility"
    echo "  info        Show access information and URLs"
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 logs grafana"
    echo "  $0 status"
    echo "  sudo $0 firewall"
    echo ""
    echo "Features:"
    echo "  ✅ VM Resource Monitoring (CPU, Memory, Disk, Network)"
    echo "  ✅ Service Uptime Monitoring (Blackbox Exporter)"
    echo "  ✅ Container Monitoring (cAdvisor)"
    echo "  ✅ Automated Alerting"
    echo "  ✅ External Access Support"
    echo "  ✅ Grafana Dashboards"
}

# Main script logic
case "${1:-help}" in
    start)
        start_monitoring
        show_access_info
        ;;
    stop)
        stop_monitoring
        ;;
    restart)
        restart_monitoring
        ;;
    status)
        show_status
        ;;
    logs)
        if [ -n "$2" ]; then
            show_service_logs $2
        else
            show_logs
        fi
        ;;
    update)
        update_system
        ;;
    backup)
        backup_config
        ;;
    firewall)
        configure_firewall
        ;;
    access)
        check_access
        ;;
    info)
        show_access_info
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
