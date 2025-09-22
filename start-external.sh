#!/bin/bash

# Complete startup script with external access configuration

echo "🚀 Starting VM Monitoring System with External Access..."
echo ""

# Make scripts executable
chmod +x setup-firewall.sh check-access.sh

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Start the monitoring system
echo "Starting Docker containers..."
if docker compose up -d; then
    echo "✅ Docker containers started successfully!"
    echo ""
    
    # Wait for services to be ready
    echo "Waiting for services to be ready..."
    sleep 10
    
    # Check access
    echo "Checking service accessibility..."
    ./check-access.sh
    
    echo ""
    echo "🎉 Setup completed!"
    echo ""
    echo "📋 Next steps:"
    echo "1. If you cannot access from other machines, run:"
    echo "   sudo ./setup-firewall.sh"
    echo ""
    echo "2. To check access status anytime, run:"
    echo "   ./check-access.sh"
    echo ""
    echo "3. To stop the system, run:"
    echo "   docker compose down"
    
else
    echo "❌ Failed to start Docker containers"
    echo "Please check the logs: docker compose logs"
    exit 1
fi
