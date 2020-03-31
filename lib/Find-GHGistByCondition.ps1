function Find-GHGistByCondition {
<#
.SYNOPSIS
Find a gist by searching for matching strings in its filename / description.
Alternatively, look up single gist with its known Id
.OUTPUTS
Gist object
#>
    [CmdletBinding()]
    param (
        # Search Param
        [Parameter(Mandatory=$true,Position=0,ParameterSetName='BySearchString')]
        [string]
        $SearchString
    )
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
        $gists = Invoke-RestMethod @params

    }
    catch {
        Write-Error "${PSItem.Exception.Message}"
    }

    try {
        Write-Verbose "Attempting to locate gist by search string: ${SearchString}"
        $query = $gists | Where-Object {
            $_.Description -match $SearchString -or
            ($_.Files | Get-Member -Type NoteProperty | Select-Object -ExpandProperty Name) -match $SearchString
        }

        if ($null -ne $query) {
            $resultSet = [System.Collections.ArrayList]@()
            foreach ($e in $query) {
                try
                {
                    $gistObj = Initialize-GHGistObject -resultData $e
                    $resultSet.Add($gistObj) | Out-Null
                }
                catch
                {
                    Write-Error "${PSItem.Exception.Message}"
                }
            }

            return $resultSet
        }
        else {
            Write-Information "No Matches found for: ${SearchString}"
        }

        return $query
    }
    catch {
        Write-Error "$PSItem"
    }
}
