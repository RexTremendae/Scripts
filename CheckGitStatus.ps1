function RecursiveStatusCheck($path)
{
    Set-Location $path

    if (Test-Path ".git") {
        Write-Host $path -ForegroundColor White
        $status = git status --short

        if ($null -eq $status) { Write-Host "  No changes" -ForegroundColor Green }
        else
        {
            $status -Split "`n`r" | ForEach-Object {
                $head = ($_.Trim() -Split " " | Select-Object -First 1)
                $tail = ($_.Substring($head.Length+1))

                Write-Host "  $head " -ForegroundColor Red -NoNewline
                Write-Host $tail
            }
        }
        return
    }

    Get-ChildItem -Directory | ForEach-Object {
        RecursiveStatusCheck $_.FullName
    }    
}


Push-Location


RecursiveStatusCheck .


Pop-Location
