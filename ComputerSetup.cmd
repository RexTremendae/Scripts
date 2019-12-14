@echo off

:: Install Chocolatey
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

:: Misc. utilities
cinst git -y
cinst visualstudiocode -y
cinst notepadplusplus -y
cinst 7zip -y
cinst vlc -y
cinst winscp -y
cinst linqpad -y
cinst slack -y
cinst paint.net -y
cinst spotify -y
