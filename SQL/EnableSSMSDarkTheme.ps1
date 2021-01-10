# N.B. Run elevated!

$configFile = 'C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\ssms.pkgundef'
$disableDarkThemeKey = '[$RootKey$\Themes\{1ded0138-47ce-435e-84ef-9ec1f439b749}]'

# Strange powershell version of ?: operator => @(<when false>, <when true>)[<condition>]
(Get-Content $configFile -Encoding UTF8) `
    | Foreach-Object { @($_.Replace($disableDarkThemeKey, "//$disableDarkThemeKey"), $_)[$_.StartsWith("//")] } `
    | Set-Content $configFile -Encoding UTF8
