To start a powershell session with a custom profile, use this command line:
powershell -noprofile -noexit -command "invoke-expression '. ''C:\My profile location\profile.ps1''' "

--- OR ---

Just replace the file %userprofile%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 with a new file with the following contents:
& C:\powershell\Profile.ps1
