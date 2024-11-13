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

## Setup

1. **Clone this repository:**
    ```bash
    git clone https://github.com/guigiovine/github-org-backup-script.git
    ```

2. **Configure the necessary variables:**

   - Open the `github-backup-config.ps1` file and replace the following variables:
     - `$orgName`: The name of your GitHub organization.
     - `$username`: Your GitHub username.
     - `$token`: Your GitHub personal access token.
     - `$backupDir`: Local directory where the repositories will be stored.
     - `$maxRepos`: Set to 0 to fetch all repositories.


3. **Run the script:**

   To start the backup, run the `github-backup-main.ps1` file in PowerShell:
   ```powershell
   .\github-backup-main.ps1
