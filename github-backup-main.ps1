# github-backup-main.ps1 - Main Backup Script

. .\github-backup-config.ps1

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
        Remove-Item -Recurse -Force $repoBackupPath -ErrorAction SilentlyContinue
    }
}

if ($failedRepos.Count -gt 0) {
    $errorList = $failedRepos -join ", "
    Write-Host "The following repositories failed to clone: $errorList"
} else {
    Write-Host "All repositories were cloned successfully."
}

$taskScriptPath = Join-Path -Path $PSScriptRoot -ChildPath "github-backup-main.ps1"
$task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($null -eq $task) {
    Write-Host "Task '$taskName' does not exist. Creating it now..."
    
    $trigger = New-ScheduledTaskTrigger -Daily -At $taskTriggerTime
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$taskScriptPath`""
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

    Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -Description $taskDescription -Principal $principal
    
    Write-Host "Scheduled task '$taskName' created successfully and set to run daily at $taskTriggerTime."
} else {
    Write-Host "Scheduled task '$taskName' already exists. No need to create it again."
}