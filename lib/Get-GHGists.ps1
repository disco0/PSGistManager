function Get-GHGists {
<#
.SYNOPSIS
Return all gists for the authenticated user
.OUTPUTS
A collection of Gist objects
#>
    [CmdletBinding()]
    param ()
    $ErrorActionPreference = 'Stop'
    $WarningPreference = 'Continue'
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

    }
    catch {
        Write-Error "${PSItem.Exception.Message}"
    }

    $resultSet = [System.Collections.ArrayList] @()
    foreach ($r in $result) {
        $gist = $null
        try
        {
            $gist = Initialize-GHGistObject -resultData $r -Debug
        }
        catch
        {
            Write-Warning "${PSItem.Exception.Message}"
        }

        if ($null -ne $gist) {
            $resultSet.Add($gist) | Out-Null
        }
        else {
            Write-Warning "Gist is empty!"
            $r
        }
    }

    return $resultSet
}
