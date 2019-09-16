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
Import-With-Output 'Posh-Git' 'C:\PowerShell\Modules\posh-git-0.7.1\posh-git.psd1'




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

Set-PSReadlineKeyHandler -Key 'UpArrow' -Function 'HistorySearchBackward'
Set-PSReadlineKeyHandler -Key 'DownArrow' -Function 'HistorySearchForward'

Set-PSReadlineOption -BellStyle None

$GitPromptSettings.BeforeText = '['


Write-Host
