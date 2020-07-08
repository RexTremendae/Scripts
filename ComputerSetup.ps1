$apps =
"microsoft-windows-terminal",
"firefox",
"git",
"visualstudiocode",
"notepadplusplus",
"7zip",
"vlc",
"winscp",
"linqpad",
"slack",
"paint.net",
"spotify"


function FirstToUpper ($text)
{
    "$($text.Substring(0, 1).ToUpper())" + "$($text.Substring(1))"
}

function Write-Title($text)
{
    $line = "===="
    for ($i = 0; $i -lt $text.Length; $i++) {
        $line += "="
    }

    Write-Host
    Write-Host $line -ForegroundColor White
    Write-Host "  $text" -ForegroundColor Cyan
    Write-Host $line -ForegroundColor White
    Write-Host
}

Write-Title "Installing Chocolatey"
Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
$env:Path += "%ALLUSERSPROFILE%\chocolatey\bin"

$count = 1
$total = $apps.Length

$apps | ForEach-Object {
    Write-Title "Installing $(FirstToUpper $_) ($count/$total)"
    cinst $_ -y
    $count = $count + 1
}
