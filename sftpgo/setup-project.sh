#!/bin/bash

# SFTPGo Project Setup - Make Everything Executable
# Run this script after cloning the repository

echo "🔧 Setting up SFTPGo Docker deployment..."
echo ""

# Make all scripts executable
echo "📝 Making scripts executable..."
chmod +x scripts/setup.sh
chmod +x scripts/manage.sh 
chmod +x scripts/backup.sh
chmod +x scripts/restore.sh
chmod +x scripts/make_executable.sh

echo "✅ All scripts are now executable!"
echo ""

echo "🚀 Ready to deploy! Next steps:"
echo ""
echo "1. Review configuration:"
echo "   - Edit .env file for custom settings"
echo "   - Review config/sftpgo.json for advanced options"
echo ""
echo "2. Start the deployment:"
echo "   ./scripts/setup.sh"
echo ""
echo "3. Access services:"
echo "   - Web Admin: http://localhost:8080"
echo "   - SFTP: localhost:2022"
echo ""
echo "4. Default credentials:"
echo "   - Username: admin"
echo "   - Password: admin123"
echo "   ⚠️  Change password immediately!"
echo ""
echo "📖 Documentation:"
echo "   - Complete guide: README.md"
echo "   - Quick start: QUICKSTART.md"
echo "   - Contributing: CONTRIBUTING.md"
echo ""
echo "🛠 Management commands:"
echo "   - ./scripts/manage.sh status    # Check status"
echo "   - ./scripts/manage.sh logs      # View logs"
echo "   - ./scripts/backup.sh           # Create backup"
echo "   - ./scripts/restore.sh <file>   # Restore backup"
echo ""
echo "Happy file transferring! 🎉"
