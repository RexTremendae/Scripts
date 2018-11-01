[CmdletBinding()]
Param(
    [Parameter()]
    [string]$IdentityUrl = "https://identity.url",
    [Parameter()]
    [string]$ApiUrl = "http://api.url",
    [Parameter()]
    [string]$Username = "username",
    [Parameter()]
    [string]$Secret = "secret",
    [Parameter()]
    [string]$Scope = "scope",
    [Parameter()]
    [string]$Verb = "GET"
)

Function Get-Token
{
    $Credentials = @{
        client_id = $Username
        client_secret = $Secret
        scope = $Scope
        grant_type = "client_credentials"
    };

    try
    {
        $Response = Invoke-RestMethod "$IdentityUrl/connect/token" -Method Post -Body $Credentials;
        $Token = $Response.access_token;
        return $Token;
    }
    catch
    {
        Throw "Could not retrieve access token."
    }
}

Function Send-Request($Token, $Verb = "Get")
{
    $Headers = @{
        "Authorization" = "Bearer $Token"
        "Content-type" = "application/json"
    }
    Return Invoke-RestMethod -Uri $ApiUrl -Headers $Headers -Method $Verb
}

# Get token
$Token = Get-Token;
Write-Host Token:
Write-Host $Token -ForegroundColor Yellow
exit

$Response = Send-Request -Token $Token -Verb $Verb
Write-Host $Response;