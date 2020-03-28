Get-ChildItem "$PSScriptRoot\lib" -Recurse -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

$script:ghtoken = Get-Secret -Name GithubFullToken -AsPlainText
if ([String]::IsNullOrEmpty($script:ghtoken)) {
    if ([String]::IsNullOrEmpty($env:ghtoken)) {
        Write-Error "No Github Api Token Found! Set environment variable : 'ghtoken'"
    } else {
        $script:ghtoken = $env:ghtoken
    }
}

$script:ghserver = 'https://api.github.com'


$export = @{
    Variable = @(
        'ghtoken',
        'ghserver'
        )
    Function = @(
        'Get-GHGists',
        'New-GHGist',
        'Set-GHToken',
        'Find-GHGist',
        'Remove-GHGist'
        )
}
Export-ModuleMember @export
