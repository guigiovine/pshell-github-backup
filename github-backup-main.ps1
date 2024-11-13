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
$failedRepos = @()
$totalFetched = 0

# Loop to get paginated repositories, respecting maxRepos limit if set
do {
    $reposUrl = "https://api.github.com/orgs/$orgName/repos?per_page=100&page=$page"
    $response = Invoke-RestMethod -Uri $reposUrl -Headers $headers

    # If maxRepos is set to 0, fetch all repos; otherwise, enforce maxRepos limit
    if ($maxRepos -eq 0) {
        $repos += $response
    } else {
        # Calculate remaining repositories needed to reach the limit
        $remaining = $maxRepos - $totalFetched
        $reposToAdd = if ($response.Count -lt $remaining) { $response } else { $response[0..($remaining - 1)] }
        $repos += $reposToAdd
        $totalFetched += $reposToAdd.Count
    }

    $page++
} while ($response.Count -gt 0 -and ($maxRepos -eq 0 -or $totalFetched -lt $maxRepos))

# Clone each repository
foreach ($repo in $repos) {
    $repoName = $repo.name
    $cloneUrl = $repo.clone_url
    $repoBackupPath = Join-Path -Path $backupDir -ChildPath "$repoName.git"

    # Check if the directory already exists
    if (Test-Path -Path $repoBackupPath) {
        Write-Host "$repoBackupPath already exists. Deleting it to refresh the backup..."
        Remove-Item -Recurse -Force $repoBackupPath
    }

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

if ($failedRepos.Count -gt 0) {
    $errorList = $failedRepos -join ", "
    Write-Host "The following repositories failed to clone: $errorList"
} else {
    Write-Host "All repositories were cloned successfully."
}