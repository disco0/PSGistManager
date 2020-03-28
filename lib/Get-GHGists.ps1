function Get-GHGists {
<#
.SYNOPSIS
Return all gists for the authenticated user
#>
    [CmdletBinding()]
    param ()
    $ErrorActionPreference = 'Stop'
    $InformationPreference = 'Continue'

    $uri = "${script:ghserver}/gists"
    $headers = @{
        Authorization = "Bearer ${script:ghtoken}"
        Accept = 'application/vnd.github.v3+json'
    }

    $params = @{
        Uri = $uri
        Headers = $headers
        Method = 'GET'
    }

    Write-Verbose "Preparing Request..."
    Write-Verbose "$($params.Method): $($params.Uri)"
    Write-Verbose "Accept: $($params.Headers.Accept)"

    try {
        $result = Invoke-RestMethod @params

        return $result
    }
    catch {
        Write-Error "$PSItem"
    }
}
