function Initialize-GHGistObject {
<#
.SYNOPSIS
Uses the github API response to create a Gist object
.INPUTS
Raw data response from Github gist API
.OUTPUTS
A Gist object ready for user interaction
.NOTES
This is a public function, but most users should not have cause to use this cmdlet very often
#>
    param ($resultData)
    $ErrorActionPreference = 'Stop'
    $DebugPreference = 'Continue'

    $filename = $resultData.Files | Get-Member -Type NoteProperty | Select-Object -ExpandProperty Name
    $language = $resultData.Files.$filename.language

    if ([String]::IsNullOrEmpty($resultData.Files.$Filename.raw_url)) {
        $gistUrl = $resultData.url
        Write-Debug "Using 'url' property: $gistUrl"
    } else {
        $gistUrl = $resultData.Files.$filename.raw_url
        Write-Debug "Using 'raw_url' property: $gistUrl"
    }

    $content = $null
    try
    {
        $content = Get-GHContentByUrl -Url $gistUrl
    }
    catch
    {
        Write-Error "${PSItem.Exception.Message}"
    }

    if ([String]::IsNullOrEmpty($content)) {
        Write-Error "Content is empty from url: $gistUrl"
    }

    $gistObj = [Gist]::new(
        [string]$e.Id,
        $filename,
        $language,
        $content,
        $resultData.html_url,
        $rawUrl,
        $resultData.public,
        $resultData.created_at,
        $resultData.updated_at
    )

    return $gistObj
}
