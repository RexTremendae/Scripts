Function \ { Set-Location \ }
Function .. { Set-Location .. }
Function ... { ..; .. }
Function .... { ..; ..; .. }
Function ..... { ..; ..; ..; .. }
Function Reset-Explorer { Stop-Process (Get-Process -Name explorer).Id }