Function \ { Set-Location \ }
Function .. { Set-Location .. }
Function ... { ..; .. }
Function .... { ..; ..; .. }
Function ..... { ..; ..; ..; .. }
Function Clear-NugetCache { c:\dev\nuget.exe locals all -clear }
Function Reset-Explorer { Stop-Process (Get-Process -Name explorer).Id }
