function Set-GHBrowser {
<#
.SYNOPSIS
Set the executable path for the browser with which you wish to open github.com gist pages
#>
    [CmdletBinding()]
    param (
        # Path to browser executable
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [string]
        $ExePath
    )
    $ErrorActionPreference = 'Stop'
    $InformationPreference = 'Continue'

    $script:browserExe = $Exepath

    Write-Information "Browser In use: $($script:ghbrowser)"
}
