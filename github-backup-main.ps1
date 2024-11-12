# github-backup-main.ps1 - Main Backup Script

# Import configuration parameters
. .\github-backup-config.ps1

# Ensure backup directory exists
if (!(Test-Path -Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir
}

$headers = @{
    Authorization = "token $token"
}

$page = 1
$repos = @()
$failedRepos = @()  # List for failed repositories

# Loop to get all paginated repositories
do {
    $reposUrl = "https://api.github.com/orgs/$orgName/repos?per_page=100&page=$page"
    $response = Invoke-RestMethod -Uri $reposUrl -Headers $headers

    # Append repositories to the list
    $repos += $response
    $page++
} while ($response.Count -gt 0)

# Clone each repository
foreach ($repo in $repos) {
    $repoName = $repo.name
    $cloneUrl = $repo.clone_url
    $repoBackupPath = Join-Path -Path $backupDir -ChildPath "$repoName.git"

    Write-Host "Cloning $repoName..."

    try {
        git clone --mirror $cloneUrl $repoBackupPath
        Write-Host "$repoName cloned successfully."
    }
    catch {
        Write-Host "Error cloning $repoName."
        $failedRepos += $repoName
        Remove-Item -Recurse -Force $repoBackupPath -ErrorAction SilentlyContinue  # Clean up failed clone
    }
}

# Send email notification if there were any failures
if ($failedRepos.Count -gt 0) {
    $errorList = $failedRepos -join ", "
    $subject = "GitHub Repository Backup Errors"
    $body = "The following repositories failed to clone: $errorList"

    # Send email
    Send-MailMessage -From $emailFrom -To $emailTo -Subject $subject -Body $body -SmtpServer $smtpServer
    Write-Host "Error notification sent to $emailTo."
} else {
    Write-Host "All repositories cloned successfully."
}
