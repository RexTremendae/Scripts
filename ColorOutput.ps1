# Write color output to the console, but also redirects the output to file if required
function Write-ColorOutput($data, $color) {
    $colorBackup = $host.ui.RawUI.ForegroundColor
    if ($null -ne $color) { $host.ui.RawUI.ForegroundColor = $color }
    Write-Output $data
    $host.ui.RawUI.ForegroundColor = $colorBackup
}
