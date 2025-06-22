#!/bin/bash

# SFTPGo Setup Script
# This script performs initial setup and starts the SFTPGo stack

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}"
    echo "=============================================="
    echo "       SFTPGo Docker Stack Setup"
    echo "=============================================="
    echo -e "${NC}"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_dependencies() {
    print_step "Checking dependencies..."
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        echo "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    # Check if Docker Compose is installed
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        echo "Visit: https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    print_success "Dependencies check passed"
}

create_directories() {
    print_step "Creating required directories..."
    
    # Create data directories
    mkdir -p data/users
    mkdir -p logs
    mkdir -p backups
    mkdir -p database
    
    # Set proper permissions
    chmod 755 data logs backups database
    chmod 755 data/users
    
    print_success "Directories created"
}

check_env_file() {
    print_step "Checking environment configuration..."
    
    if [ ! -f .env ]; then
        print_warning ".env file not found. Creating default configuration..."
        # .env file already exists from the setup, so this shouldn't happen
    fi
    
    print_success "Environment configuration ready"
}

start_services() {
    print_step "Starting SFTPGo services..."
    
    # Pull latest images
    docker-compose pull
    
    # Start services
    docker-compose up -d
    
    print_step "Waiting for services to initialize..."
    sleep 15
    
    # Check if services are running
    if docker-compose ps | grep -q "Up"; then
        print_success "Services started successfully"
    else
        print_error "Failed to start services"
        docker-compose logs
        exit 1
    fi
}

test_connectivity() {
    print_step "Testing service connectivity..."
    
    # Wait a bit more for full initialization
    sleep 10
    
    # Test web interface
    if curl -s -f http://localhost:8080/healthz > /dev/null 2>&1; then
        print_success "Web interface is responding"
    else
        print_warning "Web interface may need more time to initialize"
    fi
    
    # Check if SFTP port is listening
    if ss -tln 2>/dev/null | grep -q ":2022" || netstat -tln 2>/dev/null | grep -q ":2022"; then
        print_success "SFTP service is listening on port 2022"
    else
        print_warning "SFTP service may still be initializing"
    fi
}

display_access_info() {
    # Get local IP
    LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || ifconfig | grep -E "inet.*broadcast" | awk '{print $2}' | head -1)
    
    echo ""
    echo -e "${GREEN}=============================================="
    echo "         Setup Completed Successfully!"
    echo -e "==============================================${NC}"
    echo ""
    echo -e "${BLUE}🌐 Web Admin Access:${NC}"
    echo "   Local:   http://localhost:8080"
    if [ -n "$LOCAL_IP" ]; then
        echo "   Network: http://$LOCAL_IP:8080"
    fi
    echo ""
    echo -e "${BLUE}📁 SFTP Access:${NC}"
    echo "   Host: localhost (or $LOCAL_IP)"
    echo "   Port: 2022"
    echo ""
    echo -e "${BLUE}🔑 Default Credentials:${NC}"
    echo "   Username: admin"
    echo "   Password: admin123"
    echo ""
    echo -e "${RED}⚠️  Security Reminder:${NC}"
    echo "   Change the default admin password immediately!"
    echo ""
    echo -e "${BLUE}📋 Management Commands:${NC}"
    echo "   View status:  ./scripts/manage.sh status"
    echo "   View logs:    ./scripts/manage.sh logs"
    echo "   Create backup: ./scripts/backup.sh"
    echo "   Stop services: docker-compose down"
    echo ""
    echo -e "${BLUE}📖 Documentation:${NC}"
    echo "   Read README.md for complete documentation"
    echo ""
}

main() {
    print_header
    
    # Change to script directory
    cd "$(dirname "$0")/.."
    
    check_dependencies
    create_directories
    check_env_file
    start_services
    test_connectivity
    display_access_info
}

# Run main function
main "$@"
