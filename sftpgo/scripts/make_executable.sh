#!/bin/bash

# Make all scripts executable
echo "Setting executable permissions for all scripts..."

chmod +x scripts/setup.sh
chmod +x scripts/manage.sh
chmod +x scripts/backup.sh
chmod +x scripts/restore.sh

echo "All scripts are now executable!"
echo ""
echo "Available commands:"
echo "  ./scripts/setup.sh     - Initial setup and start"
echo "  ./scripts/manage.sh    - Service management"
echo "  ./scripts/backup.sh    - Create backups"
echo "  ./scripts/restore.sh   - Restore from backup"
