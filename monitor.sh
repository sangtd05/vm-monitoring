#!/bin/bash

# VM Monitoring System Management Script

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

# Function to start monitoring system
start_monitoring() {
    print_header
    print_status "Starting VM Monitoring System..."
    
    check_docker
    
    # Create necessary directories
    mkdir -p prometheus/rules
    mkdir -p grafana/provisioning/datasources
    mkdir -p grafana/provisioning/dashboards
    mkdir -p grafana/dashboards
    
    # Start services
    docker-compose up -d
    
    print_status "Waiting for services to start..."
    sleep 10
    
    # Check service status
    if docker-compose ps | grep -q "Up"; then
        print_status "✅ Monitoring system started successfully!"
        echo ""
        print_status "Access URLs:"
        echo "  📊 Grafana Dashboard: http://localhost:3000 (admin/admin123)"
        echo "  🔍 Prometheus: http://localhost:9090"
        echo "  📈 Node Exporter: http://localhost:9100"
        echo "  🐳 cAdvisor: http://localhost:8080"
        echo ""
        print_status "Use './monitor.sh status' to check service status"
    else
        print_error "Failed to start monitoring system"
        docker-compose logs
        exit 1
    fi
}

# Function to stop monitoring system
stop_monitoring() {
    print_header
    print_status "Stopping VM Monitoring System..."
    
    docker-compose down
    
    print_status "✅ Monitoring system stopped successfully!"
}

# Function to restart monitoring system
restart_monitoring() {
    print_header
    print_status "Restarting VM Monitoring System..."
    
    docker-compose restart
    
    print_status "✅ Monitoring system restarted successfully!"
}

# Function to show service status
show_status() {
    print_header
    print_status "Service Status:"
    echo ""
    
    docker-compose ps
    
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
}

# Function to show logs
show_logs() {
    print_header
    print_status "Showing logs for all services..."
    echo ""
    
    docker-compose logs -f
}

# Function to show specific service logs
show_service_logs() {
    local service=$1
    print_header
    print_status "Showing logs for $service..."
    echo ""
    
    docker-compose logs -f $service
}

# Function to update system
update_system() {
    print_header
    print_status "Updating monitoring system..."
    
    docker-compose pull
    docker-compose up -d
    
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
    cp docker-compose.yml $backup_dir/
    
    print_status "✅ Backup created successfully in $backup_dir/"
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
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 logs grafana"
    echo "  $0 status"
}

# Main script logic
case "${1:-help}" in
    start)
        start_monitoring
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
