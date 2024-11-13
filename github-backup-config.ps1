# github-backup-config.ps1 - Configuration Parameters

# GitHub organization and authentication
$orgName = "organization"         # Replace with your GitHub organization name
$username = "username"             # Your GitHub username
$token = "token"                   # Your personal GitHub access token
$maxRepos = 0  # Set to 0 to fetch all repositories

# Backup directory
$backupDir = ".\github-backup\$orgName"  # Directory to save backups