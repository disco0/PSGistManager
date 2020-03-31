function Get-GHContentByUrl {
<#
.SYNOPSIS
Download the raw contents of a gist using its (raw) URL
.INPUTS
'raw_url' property from a Github gist api response
.OUTPUTS
'content' property containing the actual gist contents
.NOTES
This is a public function, but most users should not have to use it very often
#>
    [CmdletBinding()]
    param (
        # URL to raw file
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        $url
    )
    $ErrorActionPreference = 'Stop'

    $params = @{
        Uri = $url
        Method = 'GET'
        Headers = @{Authorization = "Bearer ${script:ghtoken}"}
    }

    $content = $null
    try
    {
        $result = Invoke-WebRequest @params
        $content = $result.content
    }
    catch
    {
        $msg = $null
        if ($result.StatusCode -ne 200) {
            $msg = "StatusCode: ${result.StatusCode} - ${result.StatusDescription} `r`n $PSItem.Exception.Message"
        } else {
            $msg = $PSItem.Exception.Message
        }
        Write-Error "$msg"
    }

    if ([String]::IsNullOrEmpty($content)) {
        $log = Join-Path $PSScriptRoot "failedrequest_$(Get-Date).log"
        $result | out-file $log -Encoding Ascii -Force
        Write-Error "Content returned from web request is empty! Saved request output to ${log}"
    }

    return $content
}
