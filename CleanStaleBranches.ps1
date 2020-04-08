[CmdletBinding()]
Param(
    [switch]
    $DryRun
)

function ExecuteAndExitOnError($command)
{
    $errorOccurred = $false

    try
    {
        $result = Invoke-Expression $command
        if ($LASTEXITCODE -ne 0)
        {
            $errorOccurred = $true
        }
    }
    catch
    {
        $errorOccurred = $true
    }

    if ($errorOccurred)
    {
        Write-Host
        Write-Host "An error occurred, aborting" -ForegroundColor Red
        Write-Host
        exit
    }

    return $result
}


$branchColor = "Yellow"
$actionColor = "Red"
$noActionColor = "Cyan"


######################
#  Main entry point  #
######################

Write-Host

# Some odd behavior in PS:
# - *>&1 means capture all streams, including error (otherwise we wouldn't be able to parse it).
#   The first case below (fatal: not a git repo) needs the error stream to be caputred.
# - @() forces the result to be an array, otherwise $null is returned if 0 elements, a string if exactly one or an array if the result is more than one.
# - If result is a captured error, the type will be System.Management.Automation.ErrorRecord. ToString() will make sure we handle that as a string as well.
$gitStatus = @(git status -sb --porcelain=v1 *>&1)

if ($gitStatus.count -eq 1 -and $gitStatus[0].ToString().StartsWith("fatal: not a git repository"))
{
    Write-Host "Not a git repository!" -ForegroundColor Red
    Write-Host "This script needs to be run from the root of the repository you want to clean."
    Write-Host
    exit
}

if ($gitStatus.count -ge 2) {
    Write-Host "Local changes detected!" -ForegroundColor Red
    Write-Host "Please make sure there are no local changes before running this script."
    Write-Host
    exit
}

$startingBranch = ExecuteAndExitOnError "git rev-parse --abbrev-ref HEAD"

Write-Host "Fetching remote data..."
ExecuteAndExitOnError "git fetch --prune"
Write-Host

ExecuteAndExitOnError "git branch" |
  # Substring(2) removes prefixes '* ' or '  ' for each branch in the listing
  ForEach-Object { $_.Substring(2) } |
  Where-Object { $_ -ne "master" } |
  ForEach-Object {
    Write-Host "$_ " -ForegroundColor $branchColor
    ExecuteAndExitOnError "git checkout $_ --quiet"

    $result = ExecuteAndExitOnError "git status -sb --porcelain=v1"
    if ($result.Contains("$_...origin/$_")) {
        if ($result.EndsWith("[gone]")) {
            Write-Host "Remote is gone - " -NoNewline
            Write-Host "delete" -ForegroundColor $actionColor
            if ($_ -eq $startingBranch) { $startingBranch = "master" }

            if (-not $DryRun) {
                ExecuteAndExitOnError "git checkout master --quiet"
                ExecuteAndExitOnError "git branch -D $_"
            }
        } else {
            Write-Host "Has remote - " -NoNewline
            Write-Host "do nothing" -ForegroundColor $noActionColor
        }
    } else {
        Write-Host "Local only branch - " -NoNewline
        Write-Host "do nothing" -ForegroundColor $noActionColor
    }

    Write-Host
  }

ExecuteAndExitOnError "git checkout $startingBranch --quiet"
