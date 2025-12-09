#!/bin/bash
# clogger installation script
# Installs MCP audit logging system

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BOLD}╔════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║   clogger - MCP Audit Logging Setup   ║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
   echo -e "${RED}❌ Please do not run as root. Use: ./install-clogger.sh${NC}"
   exit 1
fi

# Check prerequisites
echo -e "${BOLD}Checking prerequisites...${NC}"

if ! command -v tac &> /dev/null; then
    echo -e "${RED}❌ 'tac' command not found${NC}"
    exit 1
fi

if ! command -v bc &> /dev/null; then
    echo -e "${YELLOW}⚠️  'bc' not found. Installing...${NC}"
    sudo apt-get install -y bc
fi

echo -e "${GREEN}✓ Prerequisites OK${NC}\n"

# Prompt for web directory
echo -e "${BOLD}Configuration:${NC}"
read -p "Enter your web directory (e.g., /var/www/yourdomain.com): " WEB_DIR

if [ ! -d "$WEB_DIR" ]; then
    echo -e "${RED}❌ Directory $WEB_DIR does not exist${NC}"
    read -p "Create it? (y/n): " CREATE_DIR
    if [ "$CREATE_DIR" = "y" ]; then
        sudo mkdir -p "$WEB_DIR"
        echo -e "${GREEN}✓ Created $WEB_DIR${NC}"
    else
        exit 1
    fi
fi

read -p "Enter your domain (e.g., yourdomain.com): " DOMAIN

echo ""
echo -e "${BOLD}Installing clogger components...${NC}\n"

# Step 1: Create log directory
echo -e "${YELLOW}[1/7]${NC} Creating /CLAUDE-LOG directory..."
sudo mkdir -p /CLAUDE-LOG/BACKUP
sudo chown $USER:$USER /CLAUDE-LOG
sudo chmod 777 /CLAUDE-LOG
sudo chmod 777 /CLAUDE-LOG/BACKUP
echo -e "${GREEN}✓ Directory created${NC}\n"

# Step 2: Install clogger wrapper
echo -e "${YELLOW}[2/7]${NC} Installing clogger to /usr/local/bin..."
sudo cp scripts/clogger /usr/local/bin/
sudo chmod +x /usr/local/bin/clogger
echo -e "${GREEN}✓ clogger installed${NC}\n"

# Step 3: Install sync script
echo -e "${YELLOW}[3/7]${NC} Installing web sync script..."
cp scripts/sync-web.sh /CLAUDE-LOG/
chmod +x /CLAUDE-LOG/sync-web.sh

# Update sync script with user's web directory
sed -i "s|/var/www/glitchserver.com|$WEB_DIR|g" /CLAUDE-LOG/sync-web.sh
echo -e "${GREEN}✓ Web sync configured for $WEB_DIR${NC}\n"

# Step 4: Install backup script
echo -e "${YELLOW}[4/7]${NC} Installing backup script..."
cp scripts/backup-hourly.sh /CLAUDE-LOG/
chmod +x /CLAUDE-LOG/backup-hourly.sh
echo -e "${GREEN}✓ Backup script installed${NC}\n"

# Step 5: Set up cron job
echo -e "${YELLOW}[5/7]${NC} Setting up hourly backup cron job..."
(crontab -l 2>/dev/null | grep -v backup-hourly; echo "0 * * * * /CLAUDE-LOG/backup-hourly.sh >> /CLAUDE-LOG/cron-backup.log 2>&1") | crontab -
echo -e "${GREEN}✓ Cron job added${NC}\n"

# Step 6: Deploy web files
echo -e "${YELLOW}[6/7]${NC} Deploying web dashboard..."
sudo cp scripts/clogger-live.html "$WEB_DIR/"

# Update domain in HTML file
sudo sed -i "s|https://glitchserver.com|https://$DOMAIN|g" "$WEB_DIR/clogger-live.html"

# Create initial empty log file
sudo touch "$WEB_DIR/clogger.log"
sudo chown www-data:www-data "$WEB_DIR/clogger"*
sudo chmod 644 "$WEB_DIR/clogger"*
echo -e "${GREEN}✓ Web dashboard deployed${NC}\n"

# Step 7: Initialize log file
echo -e "${YELLOW}[7/7]${NC} Initializing log file..."
touch /CLAUDE-LOG/clogger.log
chmod 666 /CLAUDE-LOG/clogger.log
echo -e "${GREEN}✓ Log file initialized${NC}\n"

# Test installation
echo -e "${BOLD}Testing installation...${NC}"
if clogger "echo 'Installation test'" &>/dev/null; then
    echo -e "${GREEN}✓ clogger command works${NC}"
else
    echo -e "${RED}❌ clogger command failed${NC}"
    exit 1
fi

if [ -f /CLAUDE-LOG/clogger.log ]; then
    echo -e "${GREEN}✓ Log file created${NC}"
else
    echo -e "${RED}❌ Log file not created${NC}"
    exit 1
fi

echo ""
echo -e "${BOLD}${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║     Installation Complete! 🎉         ║${NC}"
echo -e "${BOLD}${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo ""
echo -e "1. Test logging:"
echo -e "   ${YELLOW}clogger \"ls -la /home\"${NC}"
echo ""
echo -e "2. View logs:"
echo -e "   ${YELLOW}tail -f /CLAUDE-LOG/clogger.log${NC}"
echo ""
echo -e "3. Access web dashboard:"
echo -e "   ${YELLOW}https://$DOMAIN/clogger-live.html${NC}"
echo ""
echo -e "4. View raw logs:"
echo -e "   ${YELLOW}https://$DOMAIN/clogger.log${NC}"
echo ""
echo -e "${BOLD}Important:${NC}"
echo -e "- All MCP commands should be wrapped with: ${YELLOW}clogger \"command\"${NC}"
echo -e "- Logs are backed up hourly to: ${YELLOW}/CLAUDE-LOG/BACKUP/${NC}"
echo -e "- Web view updates in real-time"
echo ""
echo -e "${BOLD}Troubleshooting:${NC}"
echo -e "- If web access fails, check Apache/Nginx configuration"
echo -e "- If backups fail, check crontab: ${YELLOW}crontab -l${NC}"
echo -e "- For issues, see: ${YELLOW}https://github.com/GlitchLinux/clogger${NC}"
echo ""
