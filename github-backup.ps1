$orgName = "organization"                                  
$username = "username"                            
$token = "token"                                  
$maxRepos = 0 # Set to 0 to fetch all repositories
$backupDir = ".\github-backup\$orgName"
$logFilePath = ".\pshell-github-backup.log"

function Write-Log {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    $logMessage | Out-File -FilePath $logFilePath -Append -Encoding utf8
    Write-Host $logMessage
}

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

do {
    $reposUrl = "https://api.github.com/orgs/$orgName/repos?per_page=100&page=$page"
    $response = Invoke-RestMethod -Uri $reposUrl -Headers $headers

    if ($maxRepos -eq 0) {
        $repos += $response
    } else {
        $remaining = $maxRepos - $totalFetched
        $reposToAdd = if ($response.Count -lt $remaining) { $response } else { $response[0..($remaining - 1)] }
        $repos += $reposToAdd
        $totalFetched += $reposToAdd.Count
    }

    $page++
} while ($response.Count -gt 0 -and ($maxRepos -eq 0 -or $totalFetched -lt $maxRepos))

foreach ($repo in $repos) {
    $repoName = $repo.name
    $cloneUrl = $repo.clone_url
    $repoBackupPath = Join-Path -Path $backupDir -ChildPath "$repoName.git"

    if (Test-Path -Path $repoBackupPath) {
        Write-Log "$repoBackupPath already exists. Deleting it to refresh the backup..."
        Remove-Item -Recurse -Force $repoBackupPath
    }

    Write-Log "Cloning $repoName from $cloneUrl"
    try {
        git clone --mirror --verbose --progress $cloneUrl $repoBackupPath
        Write-Log "$repoName cloned successfully."
    }
    catch {
        Write-Log "Error cloning $repoName."
        $failedRepos += $repoName
        Remove-Item -Recurse -Force $repoBackupPath -ErrorAction SilentlyContinue
    }
}

if ($failedRepos.Count -gt 0) {
    $errorList = $failedRepos -join ", "
    Write-Log "The following repositories failed to clone: $errorList"
} else {
    Write-Log "All repositories were cloned successfully."
}