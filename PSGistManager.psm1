Get-ChildItem "$PSScriptRoot\Functions" -Recurse -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

$script:ghtoken = Get-Secret -Name GithubFullToken -AsPlainText
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
