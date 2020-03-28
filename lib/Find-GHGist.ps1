function Find-GHGist {
<#
.SYNOPSIS
Find a gist by searching for matching strings in its filename / description.
Alternatively, look up single gist with its known Id
#>
    [CmdletBinding()]
    param (
        # Search Param
        [Parameter(Mandatory=$true,ParameterSetName='BySearchString')]
        [string]
        $SearchString,

        # Gist Id - $Gist.Id
        [Parameter(Mandatory=$True,ParameterSetName='ById')]
        [string]
        $GistId
    )
    $ErrorActionPreference = 'Stop'
    $WarningPreference = 'Continue'
    $InformationPreference = 'Continue'

    try {
        $gists = Get-GHGists

        if (-not [String]::IsNullOrEmpty($SearchString)) {
            Write-Verbose "Attempting to locate gist by search string: ${SearchString}"
            $query = $gists | Where-Object {
                $_.Description -match $SearchString -or
                ($_.Files | Get-Member -Type NoteProperty | Select-Object -ExpandProperty Name) -match $SearchString
            }
        } else {
            Write-Verbose "Attempting to locate gist by Id: ${GistId}"
            $query = $gists | Where-Object {
                $_.Id -eq $GistId
            }
        }

        if ($null -ne $query) {
            $resultSet = [System.Collections.ArrayList]@()
            foreach ($e in $query) {
                $filename = $e.Files | Get-Member -Type NoteProperty | Select-Object -ExpandProperty Name
                $rawUrl = $e.Files.$filename.raw_url
                $language = $e.Files.$filename.language

                $content = Get-GHContentByUrl -Url $rawUrl

                $gistObj = [Gist]::new(
                    [string]$e.Id,
                    $filename,
                    $language,
                    $content,
                    $e.html_url,
                    $rawUrl,
                    $e.public,
                    $e.created_at,
                    $e.updated_at
                )

                $resultSet.Add($gistObj) | Out-Null
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