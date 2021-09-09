[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [Int] $Port
)

# If a localhost SSL sight is not reachable with IIS, this might fix the problem:
& 'C:\Program Files (x86)\IIS Express\IisExpressAdminCmd.exe' SetupSslUrl -url:https://localhost:$Port/ -UseSelfSigned
