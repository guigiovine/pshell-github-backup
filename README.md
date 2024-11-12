# PowerShell GitHub Backup Script

This project is a PowerShell script that backs up all repositories from a GitHub organization to a local directory, allowing you to maintain a complete backup in case of disaster or data loss on GitHub.

## Features

- Full backup of all repositories (including branches, tags, and references).
- Pagination support for organizations with a large number of repositories.
- Error handling: detects cloning failures and removes partially cloned repositories.
- Email notification if one or more repositories fail to clone.

## Requirements

- [PowerShell](https://docs.microsoft.com/en-us/powershell/)
- [Git](https://git-scm.com/) installed and accessible from PowerShell.
- GitHub personal access token with read access to the organization's repositories.
- SMTP server to send email notifications.

## Setup

1. **Clone this repository:**
    ```bash
    git clone https://github.com/yourusername/github-org-backup-script.git
    ```

2. **Configure the necessary variables:**

   - Open the `backup_github_repos.ps1` file and replace the following variables:
     - `$orgName`: The name of your GitHub organization.
     - `$username`: Your GitHub username.
     - `$token`: Your GitHub personal access token.
     - `$backupDir`: Local directory where the repositories will be stored.
     - `$emailTo`: Email address to receive notifications.
     - `$emailFrom`: Sender's email address.
     - `$smtpServer`: SMTP server for email sending.

3. **Run the script:**

   To start the backup, run the `backup_github_repos.ps1` file in PowerShell:
   ```powershell
   .\backup_github_repos.ps1
