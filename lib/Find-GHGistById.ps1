function Find-GHGistById {
<#
.SYNOPSIS
Use the gist id to locate and fetch a single gist.
Optionally fetch a specific revision
.OUTPUTS
Gist object
.EXAMPLE
$gist = Find-GHGistById -Id '400b1fb65c1190aaf812f156340b47b5'
#>
    [CmdletBinding()]
    param (
        # Gist ID
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        $Id,

        # Get specific revision
        [Parameter(Mandatory=$false)]
        [string]
        $Revision
    )
    $ErrorActionPreference = 'Stop'
    $InformationPreference = 'Continue'

    $uri = $script:ghserver + "/gists/${Id}"

    if (-not [String]::IsNullOrEmpty($Revision)) {
        $uri = $uri + "/$Revision"
    }

    Write-Verbose "Preparing to call: $Uri"

    $params = @{
        Authorization = "Bearer ${script:ghtoken}"
        Accept = 'application/vnd.github.v3+json'
        Method = 'GET'
        Uri = $uri
    }

    try
    {
        $result = Invoke-RestMethod @params
    }
    catch
    {
        $msg = [string]::Empty
        if ($result.StatusCode -ne 200) {
            $msg = "Status Code: ${result.StatusCode} - ${result.StatusDescription}"
        }
        $msg = $msg + $PSItem.Exception.Message
        Write-Error "$msg"
    }

    try
    {
        $gist = Initialize-GHGistObject -resultData $result
        return $gist
    }
    catch
    {
        Write-Error "${PSItem.Exception.Message}"
    }
}
