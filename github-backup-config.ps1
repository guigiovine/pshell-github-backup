# github-backup-config.ps1 - Configuration Parameters

# GitHub organization and authentication
$orgName = "ORG_NAME"         # Replace with your GitHub organization name
$username = "USR_NAME"             # Your GitHub username
$token = "TOKEN"                   # Your personal GitHub access token

# Backup directory
$backupDir = "C:\backups"  # Directory to save backups

# Email notification settings
$emailTo = "to@domain.com" # Email address to receive notifications
$emailFrom = "from@domain.com" # Email sender address
$smtpServer = "smtp.server.com" # SMTP server for sending emails
