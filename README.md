# clogger - Dead-Simple MCP Audit Logging

<p align="center">
  <img src="screenshots/clogger_log-live.png" alt="clogger Live View" width="800"/>
</p>

**Transparent, real-time audit logging for MCP (Model Context Protocol) operations with instant web accessibility.**

Built in 56 lines of bash. Zero dependencies beyond standard Linux tools.

## ✨ Features

- 🔍 **Transparent Logging** - Wrap any command with `clogger "command"` - zero manual logging
- 🧠 **Smart Summarization** - Heredocs and long commands automatically condensed
- 🌐 **Instant Web Sync** - View logs at `https://yourdomain.com/clogger.log` with zero lag
- ⚡ **Live Updates** - Auto-refreshing web dashboard updates every 300ms
- 💾 **Automated Backups** - Hourly snapshots with 24-hour retention
- 🎯 **Exit Code Preservation** - Non-intrusive, doesn't break error handling
- 📊 **Reverse Chronology** - Newest entries at top (via `tac`)

## 📸 Screenshots

### Raw Log View
<p align="center">
  <img src="screenshots/clogger_log.png" alt="clogger Raw Log" width="800"/>
</p>

### Live Dashboard
<p align="center">
  <img src="screenshots/clogger_log-live.png" alt="clogger Live View" width="800"/>
</p>

## 🚀 Quick Start

```bash
# Clone repository
git clone https://github.com/GlitchLinux/clogger.git
cd clogger

# Run installer (requires sudo)
sudo ./install-clogger.sh

# Configure your domain
nano /CLAUDE-LOG/sync-web.sh  # Update WEB_FILE path
nano /var/www/YOUR_DOMAIN/clogger-live.html  # Update fetch URL

# Start logging!
clogger "echo 'Hello, MCP logging!'"
```

## 📋 Prerequisites

- Linux system (tested on Debian/Ubuntu)
- Apache2 or Nginx web server
- Bash 4.0+
- Standard utilities: `tac`, `bc`, `cron`

## 🔧 Installation

### Automated Installation

```bash
sudo ./install-clogger.sh
```

This will:
1. Create `/CLAUDE-LOG/` directory structure
2. Install `clogger` to `/usr/local/bin/`
3. Install helper scripts (`sync-web.sh`, `backup-hourly.sh`)
4. Set up hourly backup cron job
5. Configure web sync

### Manual Installation

1. **Create log directory:**
```bash
sudo mkdir -p /CLAUDE-LOG/BACKUP
sudo chown $USER:$USER /CLAUDE-LOG
sudo chmod 777 /CLAUDE-LOG
```

2. **Install clogger wrapper:**
```bash
sudo cp scripts/clogger /usr/local/bin/
sudo chmod +x /usr/local/bin/clogger
```

3. **Install sync script:**
```bash
cp scripts/sync-web.sh /CLAUDE-LOG/
chmod +x /CLAUDE-LOG/sync-web.sh
```

**Edit `/CLAUDE-LOG/sync-web.sh`** to point to your web directory:
```bash
WEB_FILE="/var/www/YOUR_DOMAIN/clogger.log"
```

4. **Install backup script:**
```bash
cp scripts/backup-hourly.sh /CLAUDE-LOG/
chmod +x /CLAUDE-LOG/backup-hourly.sh
```

5. **Set up cron job:**
```bash
crontab -e
# Add this line:
0 * * * * /CLAUDE-LOG/backup-hourly.sh >> /CLAUDE-LOG/cron-backup.log 2>&1
```

6. **Deploy web dashboard:**
```bash
sudo cp scripts/clogger-live.html /var/www/YOUR_DOMAIN/
```

**Edit `/var/www/YOUR_DOMAIN/clogger-live.html`** and update the fetch URL:
```javascript
fetch('https://YOUR_DOMAIN/clogger.log')
```

7. **Set web permissions:**
```bash
sudo chown www-data:www-data /var/www/YOUR_DOMAIN/clogger*
sudo chmod 644 /var/www/YOUR_DOMAIN/clogger*
```

## 📖 Usage

### Basic Command Wrapping

```bash
# Simple command
clogger "ls -la /home"

# Pipeline
clogger "cat file.txt | grep error"

# Heredoc (auto-summarized!)
clogger "cat > script.sh <<'EOF'
#!/bin/bash
echo 'This is a script'
EOF"
```

### Log Format

```
[HH:MM:SS] [DD-MM-YYYY] [MCP] [user] [/working/directory] [command]
```

Example:
```
[20:39:18] [09-12-2025] [MCP] [claude] [/home/claude] [curl -s https://glitchserver.com/clogger.log | head -1]
```

### Smart Summarization Examples

**Heredoc creation:**
```
Input:  cat > file.py <<EOF
        [500 lines of Python code]
        EOF
Output: [20:00:00] [09-12-2025] [MCP] [claude] [/home] [Created file: file.py (500 lines)]
```

**Long commands:**
```
Input:  [300 character command]
Output: [20:00:00] [09-12-2025] [MCP] [claude] [/home] [first 150 chars... [300 chars total]]
```

**sed operations:**
```
Input:  sed -i 's/old/new/g' config.conf
Output: [20:00:00] [09-12-2025] [MCP] [claude] [/home] [Modified with sed: config.conf]
```

## 🌐 Web Access

### Raw Log View
```
https://YOUR_DOMAIN/clogger.log
```
- Plain text format
- Reversed chronology (newest first)
- Direct `curl` compatible
- Perfect for grep/parsing

### Live Dashboard
```
https://YOUR_DOMAIN/clogger-live.html
```
- Matrix-style terminal aesthetic
- Auto-refreshes every 300ms
- Color-coded syntax
- Responsive design

## 🛠️ Configuration

### Change Backup Retention

Edit `/CLAUDE-LOG/backup-hourly.sh`:
```bash
# Keep only last 24 backups (one per hour)
ls -t clogger.log.* 2>/dev/null | tail -n +25 | xargs rm -f 2>/dev/null

# Change +25 to keep more/fewer backups
# +49 = 48 hours
# +169 = 7 days
```

### Change Web Sync Frequency

By default, web sync happens instantly after each command.

To make it less frequent, edit `/usr/local/bin/clogger`:
```bash
# Current: Synchronous (instant)
/CLAUDE-LOG/sync-web.sh &>/dev/null

# Change to: Background (async)
/CLAUDE-LOG/sync-web.sh &>/dev/null &
```

Or set up periodic sync via cron:
```bash
# Sync every 5 seconds
* * * * * /CLAUDE-LOG/sync-web.sh
* * * * * sleep 5; /CLAUDE-LOG/sync-web.sh
* * * * * sleep 10; /CLAUDE-LOG/sync-web.sh
# ... etc
```

### Customize Log Location

Edit `/usr/local/bin/clogger`:
```bash
# Change this line:
echo "$TIMESTAMP [MCP] [claude] [$(pwd)] [$LOG_CMD]" >> /CLAUDE-LOG/clogger.log
```

## 📊 File Structure

```
/CLAUDE-LOG/
├── clogger.log              # Main log file
├── sync-web.sh              # Web sync script
├── backup-hourly.sh         # Backup automation
└── BACKUP/
    └── clogger.log.*        # Timestamped backups

/usr/local/bin/
└── clogger                  # Main wrapper script

/var/www/YOUR_DOMAIN/
├── clogger.log              # Public log file
└── clogger-live.html        # Live web dashboard
```

## 🎯 Performance

- **Log size at 1,300 entries:** 143KB
- **Projected size at 20,000 entries:** ~2.1MB
- **Browser load time:** <10ms for files <5MB
- **Logging overhead:** ~5-10ms per command
- **Web sync time:** ~20ms

## 🔒 Security Considerations

### 1. Sensitive Data in Logs
Commands may contain passwords, tokens, or API keys. Options:

**Option A: Restrict web access**
```apache
# Apache .htaccess
<Files "clogger.log">
    Require ip 192.168.1.0/24
    Require ip YOUR_IP
</Files>
```

**Option B: Use HTTP auth**
```bash
htpasswd -c /etc/apache2/.htpasswd admin
```

**Option C: Pattern filtering**
Add to `clogger` script:
```bash
# Redact sensitive patterns
LOG_CMD=$(echo "$LOG_CMD" | sed 's/password=[^ ]*/password=***REDACTED***/g')
```

### 2. Log Rotation
At 20,000 lines (~2MB), consider archiving:
```bash
mv /CLAUDE-LOG/clogger.log /CLAUDE-LOG/BACKUP/clogger.log.$(date +%Y%m%d)
touch /CLAUDE-LOG/clogger.log
```

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Test thoroughly
4. Submit a pull request

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Built for [Claude MCP](https://www.anthropic.com/claude) integration with transparent audit logging requirements.

## 🐛 Troubleshooting

### Commands not being logged
```bash
# Check clogger is installed
which clogger

# Check log file permissions
ls -la /CLAUDE-LOG/clogger.log

# Test manually
clogger "echo test" && tail -1 /CLAUDE-LOG/clogger.log
```

### Web sync not working
```bash
# Check sync script
/CLAUDE-LOG/sync-web.sh

# Verify web file location
ls -la /var/www/YOUR_DOMAIN/clogger.log

# Check permissions
sudo chown www-data:www-data /var/www/YOUR_DOMAIN/clogger.log
```

### Backups not running
```bash
# Check cron
crontab -l | grep backup

# Test backup script manually
/CLAUDE-LOG/backup-hourly.sh

# Check backup directory
ls -la /CLAUDE-LOG/BACKUP/
```

### Live dashboard not updating
```bash
# Check browser console for fetch errors
# Verify clogger.log is accessible:
curl https://YOUR_DOMAIN/clogger.log

# Check CORS if needed (shouldn't be an issue for same-domain)
```

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/GlitchLinux/clogger/issues)
- **Discussions:** [GitHub Discussions](https://github.com/GlitchLinux/clogger/discussions)

## 🚀 Roadmap

- [ ] Multi-user support (dynamic user tags)
- [ ] Pattern-based sensitive data redaction
- [ ] JSON output format option
- [ ] Integration with systemd journal
- [ ] Search/filter UI in live dashboard
- [ ] Configurable retention policies
- [ ] Telegram/Discord webhook notifications

---

**Made with ❤️ by [GlitchLinux](https://github.com/GlitchLinux)**

*"Because knowing what your AI did shouldn't require an enterprise logging solution."*
