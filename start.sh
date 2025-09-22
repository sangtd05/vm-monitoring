#!/bin/bash

# Quick Start Script for VM Monitoring System

echo "🚀 Starting VM Monitoring System..."
echo ""

# Make monitor.sh executable
chmod +x monitor.sh

# Start the monitoring system
./monitor.sh start

echo ""
echo "🎉 Setup completed! You can now access:"
echo "   📊 Grafana: http://localhost:3000 (admin/admin123)"
echo "   🔍 Prometheus: http://localhost:9090"
echo ""
echo "💡 Use './monitor.sh help' for more commands"
