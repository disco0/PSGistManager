function Remove-GHGist {
<#
.SYNOPSIS
Delete a single Gist
#>
    [CmdletBinding()]
    param (
        # Gist Id
        [Parameter(Mandatory=$true)]
        [string]
        $Id
    )
    $ErrorActionPreference = 'Stop'
    $InformationPreference = 'Continue'

    $params = @{
        Uri = "${script:ghserver}/gists/${id}"
        Method = 'DELETE'
        Headers = @{
            Authorization = "Bearer ${script:ghtoken}"
            Accept = 'application/vnd.github.v3+json'
        }
    }

    Write-Verbose "Preparing to delete Gist ${id} ..."
    try {
        $result = Invoke-RestMethod @params

        Write-Information "Deleted Gist ${GistId}"
        return $result
    }
    catch {
        Write-Error "$PSitem"
    }
}
