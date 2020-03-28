$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

Get-ChildItem "$PSScriptRoot\lib" -Recurse -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

$script:ghtoken = Get-Secret -Name GithubFullToken -AsPlainText
if ([String]::IsNullOrEmpty($script:ghtoken)) {
    if ([String]::IsNullOrEmpty($env:ghtoken)) {
        Write-Error "No Github Api Token Found! Set environment variable : 'ghtoken' or use Set-GHToken"
    } else {
        $script:ghtoken = $env:ghtoken
    }
}

$script:ghserver = 'https://api.github.com'
Write-Verbose "Github API Server: ${script:ghserver}"

$script:ghbrowser = 'C:\Program Files\Firefox Developer Edition\firefox.exe'
Write-Information "Browser In Use: ${script:ghbrowser} - Change with Set-GHBrowser"


$export = @{
    Variable = @(
        'ghtoken',
        'ghserver',
        'ghbrowser'
        )
    Function = @(
    'Find-GHGistByCondition',
    'Find-GHGistById'
    'Get-GHContentByUrl',
    'Get-GHGists',
    'Initialize-GHGistObject',
    'New-GHGist',
    'Remove-GHGist',
    'Set-GHBrowser',
    'Set-GHToken'
    )
}
Export-ModuleMember @export
