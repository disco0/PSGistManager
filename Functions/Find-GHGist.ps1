function Find-GHGist {
<#
.SYNOPSIS
Find a gist
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
                $_.Description -match $SearchString
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
                $filename = $e.Files | gm -Type NoteProperty | select -ExpandProperty Name
                $rawUrl = $e.Files.$filename.raw_url
                $tmpOut = Join-Path $env:TEMP $filename

                $iwrParams = @{
                    Uri = $rawUrl
                    Headers = @{Authorization = "Bearer ${script:ghtoken}"}
                    Outfile = $tmpOut
                    Method = 'GET'
                }

                if (Test-Path $tmpOut) {
                    Remove-Item -Path $tmpOut -Force | Out-Null
                }

                try {
                    Invoke-WebRequest  @iwrParams | Out-Null
                }
                catch {
                    Write-Warning "$PSItem"
                }

                $content = Get-Content $tmpOut
                $obj = [pscustomobject] @{
                    Name = $filename
                    Content = $content
                }

                $resultSet.Add($obj);
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
