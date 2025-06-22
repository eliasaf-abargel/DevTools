#!/bin/bash

# SFTPGo Management Script
# Provides common management operations for the SFTPGo stack

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Change to project directory
cd "$(dirname "$0")/.."

show_status() {
    echo "=== Container Status ==="
    docker-compose ps
    echo ""
    
    echo "=== Service Health ==="
    if curl -s -f http://localhost:8080/healthz > /dev/null 2>&1; then
        print_success "Web interface is healthy"
    else
        print_error "Web interface is not responding"
    fi
    
    if ss -tln 2>/dev/null | grep -q ":2022" || netstat -tln 2>/dev/null | grep -q ":2022"; then
        print_success "SFTP service is listening"
    else
        print_error "SFTP service is not listening"
    fi
    
    echo ""
    echo "=== Recent Logs (last 10 lines) ==="
    docker-compose logs --tail=10
}

show_logs() {
    if [ "$2" = "follow" ] || [ "$2" = "-f" ]; then
        docker-compose logs -f
    else
        docker-compose logs --tail=50
    fi
}

restart_services() {
    print_info "Restarting SFTPGo services..."
    docker-compose restart
    sleep 10
    print_success "Services restarted"
}

update_services() {
    print_info "Updating SFTPGo to latest version..."
    
    # Create backup before update
    ./scripts/backup.sh
    
    # Stop services
    docker-compose down
    
    # Pull latest images
    docker-compose pull
    
    # Start services
    docker-compose up -d
    
    # Wait for services to be ready
    sleep 15
    
    print_success "Update completed"
}

test_sftp() {
    print_info "Testing SFTP connectivity..."
    
    # Test if SFTP port is accessible
    if command -v nc &> /dev/null; then
        if nc -z localhost 2022; then
            print_success "SFTP port 2022 is accessible"
        else
            print_error "SFTP port 2022 is not accessible"
        fi
    else
        print_info "netcat not available, skipping port test"
    fi
    
    # Test SFTP protocol (requires sshpass for automation)
    if command -v sftp &> /dev/null; then
        print_info "SFTP client is available for manual testing"
        echo "Test command: sftp -P 2022 username@localhost"
    else
        print_info "SFTP client not available"
    fi
}

clean_logs() {
    print_info "Cleaning old log files..."
    
    # Clean Docker logs
    docker-compose down
    docker system prune -f --volumes
    
    # Clean application logs older than 30 days
    find logs/ -name "*.log*" -mtime +30 -delete 2>/dev/null || true
    
    docker-compose up -d
    print_success "Log cleanup completed"
}

show_help() {
    echo "SFTPGo Management Script"
    echo "========================"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  status          Show service status and health"
    echo "  logs [follow]   Show logs (use 'follow' for real-time)"
    echo "  restart         Restart all services"
    echo "  update          Update to latest SFTPGo version"
    echo "  test-sftp       Test SFTP connectivity"
    echo "  clean-logs      Clean old log files"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 status"
    echo "  $0 logs follow"
    echo "  $0 restart"
    echo "  $0 update"
    echo ""
}

# Main command processing
case "$1" in
    status)
        show_status
        ;;
    logs)
        show_logs "$@"
        ;;
    restart)
        restart_services
        ;;
    update)
        update_services
        ;;
    test-sftp)
        test_sftp
        ;;
    clean-logs)
        clean_logs
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
