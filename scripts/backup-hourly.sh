#!/bin/bash
# Hourly backup script for clogger.log
# Backs up to /CLAUDE-LOG/BACKUP/clogger.log.TIMESTAMP

LOG_FILE="/CLAUDE-LOG/clogger.log"
BACKUP_DIR="/CLAUDE-LOG/BACKUP"
BACKUP_FILE="$BACKUP_DIR/clogger.log.$(date +%s)"

# Create backup
cp "$LOG_FILE" "$BACKUP_FILE"

# Keep only last 24 backups (one per hour)
cd "$BACKUP_DIR"
ls -t clogger.log.* 2>/dev/null | tail -n +25 | xargs rm -f 2>/dev/null

echo "Backup created: $BACKUP_FILE"
