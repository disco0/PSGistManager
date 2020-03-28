function New-GHGist {
<#
.SYNOPSIS
Add a new Gist
#>
    [CmdletBinding()]
    param (
        # Description
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        $Description,

        # File name
        [Parameter(Mandatory=$true)]
        [string]
        $Filename,

        # Gist Content
        [Parameter(Mandatory=$true,ParameterSetName='ContentFromString')]
        [string]
        $Content,

        # Gist Content from file
        [Parameter(Mandatory=$true,ParameterSetName='ContentFromFile')]
        [string]
        $ContentPath,

        [switch]
        $Public = $false
    )
    $ErrorActionPreference = 'Stop'
    $InformationPreference = 'Continue'

    if (Test-Path $ContentSrc) {
        $Content = Get-Content $ContentSrc
    }

    $obj = [pscustomobject] @{
        description = $Description
        public = $false
        files = @{
            $Filename = @{
                content = $Content
            }
        }
    }
    if ($Public) {
        $obj.public = $true
    }
    Write-Verbose "New Gist: ${Description}"
    Write-Verbose "Filename: ${Filename}"
    Write-Verbose "Public: ${Public}"
    Write-Verbose "Content: ${Content}"

    $params = @{
        Method = 'POST'
        Uri = "${script:ghserver}/gists"
        Body = $obj | ConvertTo-Json -Depth 9
        Headers = @{
            Authorization = "Bearer ${script:ghtoken}"
            Accept = 'application/vnd.github.v3+json'
        }
    }

    Write-Verbose "Preparing Request..."
    Write-Verbose "Payload: `r`n $($params.Body)"
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
