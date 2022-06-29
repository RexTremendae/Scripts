function Main()
{
  Push-Location $PSScriptRoot
  if ($(Get-ModifiedFiles).Count -ne 0)
  {
    Write-Error "Some checked-in files were modified. This script needs to run in a clean repository."
    Pop-Location
    exit 1
  }

  if ($(Get-UntrackedFiles).Count -ne 0)
  {
    Write-Error "Untracked files detected. This script needs to run in a clean repository."
    Pop-Location
    exit 1
  }

  dotnet ef migrations add ValidationMigration

  $untrackedFileNameArray = Get-UntrackedFiles
  $modifiedFileNameArray = Get-ModifiedFiles
  if ($modifiedFileNameArray.Count -ne 0) # If any migrations were created, the snapshot file is modified
  {
    foreach ($filename in $modifiedFileNameArray)
    {
      Write-Error "'$filename' was modified during the add migration operation."
      Write-Host "Checking out '$filename'..."
      git checkout $filename
    }
    foreach ($filename in $untrackedFileNameArray)
    {
      Remove-Item $filename -Verbose
    }
    Pop-Location
    exit 1
  }

  # Check any untracked files that does not end with '.Designer.cs' - should only be a migration
  foreach ($filename in $untrackedFileNameArray | Where-Object { $_ -Notmatch '.*.\.Designer\.cs' })
  {
    # This is just a precaution - if a migration was detected, the snapshot modification should have been caught above and we never get to here
    if (-Not (Validate-MigrationIsEmpty $filename))
    {
      Write-Error "Migration file '$filename' contains changes."
      foreach ($filename in $untrackedFileNameArray)
      {
        Remove-Item $filename -Verbose
      }
      Pop-Location
      exit 1
    }
  }

  # Clean up generated migrations
  foreach ($filename in $untrackedFileNameArray)
  {
    Remove-Item $filename -Verbose
  }

  Write-Host "Checked in migrations are ok - no changes found."
  Pop-Location
}

function Get-ModifiedFiles()
{
  $modifiedFiles = $(git status --porcelain | Where-Object { $_ -Match ' M .*' })
  return $modifiedFiles -Replace ' M (.*)', '$1'
}

function Get-UntrackedFiles()
{
  $modifiedFiles = $(git status --porcelain | Where-Object { $_ -Match '\?\? .*' })
  return $modifiedFiles -Replace '\?\? (.*)', '$1'
}

function Validate-MigrationIsEmpty($migrationFilename)
{
  $migrationFileRawContent = Get-Content -Path $migrationFilename -Encoding UTF8
  $migrationFileContent = $migrationFileRawContent -Replace '^(\s*)(.*)(\s*)$', '$2'
  $migrationFileContent = $migrationFileContent | Where-Object { $_ -ne '' }

  # > 0 means the script is currently processing the Up() migration code block
  $upMethodDepth = -1

  # > 0 means the script is currently processing the Down() migration code block
  $downMethodDepth = -1

  $upMethodIsEmpty = $true
  $downMethodIsEmpty = $true

  foreach ($line in $migrationFileContent)
  {
    if ($line -eq "protected override void Up(MigrationBuilder migrationBuilder)")
    {
      Write-Debug "Found " -NoNewline
      Write-Debug $line -ForegroundColor Yellow

      $upMethodDepth = 0
      $downMethodDepth = -1
    }
    elseif ($line -eq "protected override void Down(MigrationBuilder migrationBuilder)")
    {
      Write-Debug "Found " -NoNewline
      Write-Debug $line -ForegroundColor Yellow

      $downMethodDepth = 0
      $upMethodDepth = -1
    }
    elseif ($line -eq "{")
    {
      if ($upMethodDepth -ge 0) { $upMethodDepth += 1 }
      elseif ($downMethodDepth -ge 0) { $downMethodDepth += 1 }
      Write-Debug "Up: $upMethodDepth  Down: $downMethodDepth"
    }
    elseif ($line -eq "}")
    {
      if ($upMethodDepth -ge 0) { $upMethodDepth -= 1 }
      elseif ($downMethodDepth -ge 0) { $downMethodDepth -= 1 }
      Write-Debug "Up: $upMethodDepth  Down: $downMethodDepth"
    }
    elseif ($line -ne "")
    {
      Write-Debug "Line: [" -NoNewline
      Write-Debug $line -NoNewline -ForegroundColor Cyan
      Write-Debug "]"

      if ($upMethodDepth -ge 0) { $upMethodIsEmpty = $false }
      if ($downMethodDepth -ge 0) { $downMethodIsEmpty = $false }
    }
  }

  if (-not $upMethodIsEmpty) { Write-Debug "Up method not empty!" -ForegroundColor Red }
  if (-not $downMethodIsEmpty) { Write-Debug "Down method not empty!" -ForegroundColor Red }

  return $upMethodIsEmpty -and $downMethodIsEmpty
}

Main