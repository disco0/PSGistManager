class Gist
{
    [string]$Id
    [string]$Name
    [string]$Language
    [string]$Content
    [string]$Url
    [string]$RawUrl
    [bool]$Public
    [DateTime]$CreatedAt
    [DateTime]$UpdatedAt

    Gist(
        [string] $Id,
        [string]$Name,
        [string]$Language,
        [string]$Content,
        [string]$Url,
        [string]$RawUrl,
        [bool]$Public,
        [DateTime]$CreatedAt,
        [DateTime]$UpdatedAt
        )
        {
            $this.Id = $Id
            $this.Name = $Name
            $this.Language = $Language
            $this.Content = $Content
            $this.Url = $Url
            $this.RawUrl = $RawUrl
            $this.Public = $Public
            $this.CreatedAt = $CreatedAt
            $this.UpdatedAt = $UpdatedAt
        }

    ToClipboard()
    {
        Set-Clipboard -Value $this.Content
    }

    [string] GetId()
    {
        return $this.Id
    }

    [string] GetContent()
    {
        return $this.Content
    }

    [string] GetFilename()
    {
        return $this.Name
    }

    [string] GetLanguage()
    {
        return $this.Language
    }

    [bool] IsPublic()
    {
        return $this.Public
    }

    [DateTime] GetCreatedTime()
    {
        return $this.CreatedAt
    }

    [DateTime] GetUpdatedTime()
    {
        return $this.UpdatedAt
    }

    [string] DownloadFile()
    {
        $outpath = Join-Path $pwd.path $this.Name
        $params = @{
            Uri = $this.RawUrl
            Headers = @{Authorization = "Bearer ${script:ghtoken}"}
            Outfile = $outpath
            Method = 'GET'
        }

        try {
            Invoke-WebRequest @params
        }
        catch {
            Write-Error "$PSItem"
        }

        if ((Test-Path $Outpath) -eq $false) {
            Write-Error "$outpath does not exist!"
        }

        return $outpath
    }

    OpenGithubPage()
    {
        Start-Process $script:ghbrowser "$($this.Url)"
    }

}
