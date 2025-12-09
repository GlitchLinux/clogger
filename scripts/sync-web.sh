#!/bin/bash
# Sync clogger.log to web, reversed for top-down readability

LOG_FILE="/CLAUDE-LOG/clogger.log"
WEB_FILE="/var/www/glitchserver.com/clogger.log"

# Copy and reverse log (newest entries at top)
tac "$LOG_FILE" > "$WEB_FILE"

# Ensure web permissions
chmod 644 "$WEB_FILE"

echo "Web file synced: $(wc -l < $WEB_FILE) lines"
