[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string] $MergeBranchName,
    [Parameter()]
    [string] $TargetBranchName="develop"
)

function PrintWithHeader($headerText, $color, $descriptionLines)
{
    $line = "".PadLeft($headerText.length + 6, "=")

    Write-Host
    Write-Host $line -ForegroundColor $color
    Write-Host "   " -NoNewline
    Write-Host $headerText -NoNewline
    Write-Host "   "
    Write-Host $line -ForegroundColor $color
    Write-Host

    $anyOutput = $false
    foreach ($line in $descriptionLines)
    {
        Write-Host $line
        $anyOutput = $true
    }

    if ($anyOutput -eq $true)
    {
        Write-Host
    }
}

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
        PrintWithHeader "An error occurred" Red
        exit
    }

    return $result
}

function ExecuteAndReturnErrorStatus($command)
{
    $errorOccurred = $false

    try
    {
        Invoke-Expression $command
        if ($LASTEXITCODE -ne 0)
        {
            $errorOccurred = $true
        }
    }
    catch
    {
        $errorOccurred = $true
    }

    return $errorOccurred
}

function CheckForLocalChanges()
{
    $result = ExecuteAndExitOnError "git status -sb --porcelain=v1"

    if ($result.count -ge 2)
    {
        PrintWithHeader "Uncommited local changes found" Red
        Write-Host "Cannot merge branch with uncommited changes. Do one of the following:"
        Write-Host
        Write-Host "1. Commit changes to a new branch:"
        Write-Host "  " -NoNewline
        Write-Host 'git checkout -b newbranch' -ForegroundColor Yellow
        Write-Host "  " -NoNewline
        Write-Host "git add --all" -ForegroundColor Yellow
        Write-Host "  " -NoNewline
        Write-Host 'git commit -m "commit message"' -ForegroundColor Yellow
        Write-Host
        Write-Host "2. Keep changes for later:"
        Write-Host "  " -NoNewline
        Write-Host "git stash -u " -ForegroundColor Yellow
        Write-Host "  (use " -NoNewline
        Write-Host "git stash pop" -ForegroundColor Yellow -NoNewline
        Write-Host " to get the changes back later)"
        Write-Host
        Write-Host "3. Discard all changes:"
        Write-Host "  " -NoNewline
        Write-Host "git reset --hard" -ForegroundColor Yellow
        Write-Host "  " -NoNewline
        Write-Host "git clean -fd" -ForegroundColor Yellow
        Write-Host

        exit
    }
}

function HasDiverged()
{
    # Make sure the result is a string array, regardless if the raw result is one or multiple lines
    $result = @(ExecuteAndExitOnError "git status -sb --porcelain=v1" -split '[\r\n]+')
    $result[0] -match '.*\[(ahead\s(?<ahead>\d+))?(,\s)?(behind\s(?<behind>\d+))?\].*' > $null

    $ahead = 0
    $behind = 0

    if ($null -ne $matches)
    {
        $aheadMatch = $matches['ahead']
        $behindMatch = $matches['behind']

        if ($null -ne $aheadMatch) { $ahead = $matches['ahead'] }
        if ($null -ne $behindMatch) { $behind = $matches['behind'] }
    }

    if ($ahead -ne 0) { return $true }

    return $false
}

function PrintDivergedMessage($divergedBranchName)
{
    PrintWithHeader "You are not in sync with your origin." Red

    Write-Host "The branch " -NoNewline
    Write-Host $divergedBranchName -ForegroundColor Yellow -NoNewline
    Write-Host " has diverged from origin."
    Write-Host "Please make sure you are not ahead or behind origin before doing a merge."
    Write-Host
    Write-Host "If you want to discard all your changes that caused the divergence, do the following:"
    Write-Host "git reset origin/$divergedBranchName --hard" -ForegroundColor Yellow
    Write-Host "git clean -fd" -ForegroundColor Yellow
    Write-Host
}

function RebaseInProgress()
{
    $result = ExecuteAndExitOnError "git diff --name-only --diff-filter=U"

    if ($result.count -ge 1) { return $true }

    return $false
}

function PrintResolveRebaseMessage($header, $rebasingBranch)
{
    PrintWithHeader $header Red
    Write-Host "The rebase needs to be completed or aborted before continuing:"
    Write-Host
    Write-Host "1. To continue, fix any merge conflicts (these steps might need to be executed several times):"
    Write-Host "git mergetool" -ForegroundColor Yellow
    Write-Host "git rebase --continue" -ForegroundColor Yellow
    if ($null -ne $rebasingBranch)
    {
        Write-Host
        Write-Host "When rebase is finished and everything looks good (" -NoNewline
        Write-Host "make sure to review the changes" -ForegroundColor Red -NoNewline
        Write-Host "), update the rebased branch:"
        Write-Host "git push --force-with-lease origin $rebasingBranch" -ForegroundColor Yellow
    }
    Write-Host
    Write-Host "2. If you want to abort the rebase and start over, use"
    Write-Host "git rebase --abort" -ForegroundColor Yellow
    Write-Host
    Write-Host "After taking any of these action, you can run the script again."
    Write-Host
}

function PrintSuccessMessage()
{
    PrintWithHeader "Success!" Green
    Write-Host "All went well. "
    Write-Host "Make sure to look through all the merges and make sure everything looks alright before pushing!" -ForegroundColor Red
    Write-Host
    Write-Host "Everything looks good? Great! In order to make VSTS understand that the merge is complete, do the following: "
    Write-Host "git checkout $MergeBranchName" -ForegroundColor Yellow
    Write-Host "git push --force-with-lease origin $MergeBranchName" -ForegroundColor Yellow
    Write-Host
    Write-Host "Then push the branch to which you did the merge:"
    Write-Host "git checkout $TargetBranchName" -ForegroundColor Yellow
    Write-Host "git push origin $TargetBranchName" -ForegroundColor Yellow
    Write-Host
}



##############################
###   Script entry point   ###
##############################

if (RebaseInProgress)
{
    PrintResolveRebaseMessage "A rebase is in progress"
    exit
}
CheckForLocalChanges

#######################
# Update all branches

PrintWithHeader "Making sure all involved branches are up-to-date" Yellow

# Update target (e.g. develop)
ExecuteAndExitOnError "git checkout $TargetBranchName"
ExecuteAndExitOnError "git fetch"

if (HasDiverged)
{
    PrintDivergedMessage $TargetBranchName
    exit
}

ExecuteAndExitOnError "git merge FETCH_HEAD"

# Update the branch to be merged
ExecuteAndExitOnError "git checkout $MergeBranchName"
ExecuteAndExitOnError "git fetch"

if (HasDiverged)
{
    PrintDivergedMessage $MergeBranchName
    exit
}

ExecuteAndExitOnError "git merge FETCH_HEAD"

############################################
# Rebase branch onto target (e.g. develop)

PrintWithHeader "Rebasing $MergeBranchName onto $TargetBranchName" Yellow
$errorOccurred = ExecuteAndReturnErrorStatus "git rebase $TargetBranchName"

if (RebaseInProgress)
{
    # Merge conflict when rebasing
    PrintResolveRebaseMessage "Merge conflict occurred" $MergeBranchName
    exit
}
elseif ($errorOccurred -eq $true)
{
    # Other error when rebasing
    PrintWithHeader "An error occurred" Red `
        ("An unknown error has occurred. This problem needs to be manually reviewed and fixed",
        "before continuing merging $MergeBranchName into to $TargetBranchName.")
    exit
}

###########################################
# Merge branch into target (e.g. develop)

PrintWithHeader "Merging $MergeBranchName into $TargetBranchName" Yellow
ExecuteAndExitOnError "git checkout $TargetBranchName"
ExecuteAndExitOnError "git merge $MergeBranchName --no-ff"

############
# Success!

PrintSuccessMessage

