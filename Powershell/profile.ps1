function Write-Bullet()
{
    Write-Host '* ' -ForegroundColor Yellow -NoNewline
}



##########
# Imports
###################################################################################################
function Import-With-Output ($displayName, $path)
{
    Write-Bullet
    Write-Host 'Importing ' -NoNewline
    Write-Host $displayName -ForegroundColor Green
    Import-Module $path
}

if ($PSVersionTable.PSVersion.Major -lt 6)
{
    Import-With-Output 'JumpLocation' 'C:\PowerShell\Modules\Jump-Location\Jump.Location.psd1'
}
Import-With-Output 'PowerLS' 'C:\PowerShell\Modules\PowerLS\powerls.psm1'
Import-With-Output 'Posh-Git' 'C:\PowerShell\Modules\posh-git-1.1.0\posh-git.psd1'




##########
# Aliases
###################################################################################################
Write-Bullet
Write-Host 'Defining aliases'
Set-Alias -Name ls -Value PowerLS -Option AllScope -Scope Global



############
# Functions
###################################################################################################
Write-Bullet
Write-Host 'Importing custom functions'
Import-Module C:\Powershell\profileFunctions.psm1



########
# Misc. 
###################################################################################################
$env:Path += ";C:\Program Files (x86)\Microsoft SDKs\F#\4.0\Framework\v4.0;C:\Program Files (x86)\Microsoft Visual Studio 14.0\vc\bin;C:\Program Files (x86)\Windows Kits\10\bin\x86;C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\Roslyn"
$env:LC_ALL = 'C.UTF-8'

Set-PSReadLineKeyHandler -Key 'UpArrow' -ScriptBlock {
    param($key, $arg)

    $line=$null
    $cursor=$null
    [Microsoft.PowerShell.PSConsoleReadLine]::HistorySearchBackward()
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($line.Length)
}

Set-PSReadLineKeyHandler -Key 'DownArrow' -ScriptBlock {
    param($key, $arg)

    $line=$null
    $cursor=$null
    [Microsoft.PowerShell.PSConsoleReadLine]::HistorySearchForward()
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($line.Length)
}

# Work around an RS5/PSReadline-2.0.0+beta2 bug
# Without this, shift+space won't produce a space
Set-PSReadlineKeyHandler "Shift+SpaceBar" -ScriptBlock {
    [Microsoft.Powershell.PSConsoleReadLine]::Insert(' ')
}

Set-PSReadlineOption -BellStyle None

Write-Host

$PSDefaultParameterValues['*:Encoding'] = 'UTF8'


# Posh Git settings
$GitPromptSettings.PathStatusSeparator.Text = '`n'
$GitPromptSettings.DefaultPromptWriteStatusFirst = $true
$GitPromptSettings.DefaultPromptAbbreviateGitDirectory = $true
