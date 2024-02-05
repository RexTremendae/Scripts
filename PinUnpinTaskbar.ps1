# https://community.spiceworks.com/topic/2331970-pinning-apps-to-taskbar-with-powershell
 
function PinApp
{
    param([string]$appname)
    try {
        ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | `
            ?{$_.Name.replace('&','') -match 'Pin to Taskbar'} | `
            %{$_.DoIt()}
        Write-Host $appname -NoNewline -ForegroundColor Cyan
        Write-Host " pinned to Taskbar"
    } catch {
        Write-Error "Error pinning app! (App-name correct?)"
    }
}
 
function UnpinApp
{
    param([string]$appname)
    try {
        ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | `
            ?{$_.Name.replace('&','') -match 'Unpin from Taskbar'} | `
            %{$_.DoIt()}
        Write-Host $appname -NoNewline -ForegroundColor Cyan
        Write-Host " unpinned from Taskbar"
    } catch {
        Write-Error "Error unpinning app! (App-name correct?)"
    }
}
 
$appname = "Google Chrome"
 
PinApp $appname
UnpinApp $appname
