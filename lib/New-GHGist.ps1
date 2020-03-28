function New-GHGist {
<#
.SYNOPSIS
Add a new Gist
.EXAMPLE
New-GHGist -Description "VSCode settings file" -ContentPath .\settings.json -Public
.EXAMPLE
New-GHGist -Description "Vimrc" -Content $vimrcData -Filename '.vimrc'
.NOTES
Use -Verbose to view parameter values in console
#>
    [CmdletBinding()]
    param (
        # Description of this gist
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        $Description,

        # File name
        [Parameter(Mandatory=$true,ParameterSetName='ContentFromString')]
        [string]
        $Filename,

        # Get the gist content from a string object
        [Parameter(Mandatory=$true,ParameterSetName='ContentFromString')]
        [string]
        $Content,

        # Load the gist content from a file. Existing filename will be used
        [Parameter(Mandatory=$true,ParameterSetName='ContentFromFile')]
        [string]
        $ContentPath,

        # Use this switch to enable public visibility
        [switch]
        $Public = $false
    )
    $ErrorActionPreference = 'Stop'
    $InformationPreference = 'Continue'

    if (Test-Path $ContentSrc) {
        $Content = Get-Content $ContentSrc
        $Filename = Split-Path $ContentPath -Leaf
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
