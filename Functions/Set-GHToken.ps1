function Set-GHToken {
    param ([string]$token)
    Add-Secret -Name GithubFullToken -Secret $token
}
