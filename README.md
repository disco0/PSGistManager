# PSGistManager
#### Manage Github Gists from Powershell CLI
***
## Features
* Search with pattern matching against file names and descriptions
* Fetch a gist by its Id
* Copy gist content to clipboard
* Create a new gist
* Delete a gist

## Installation
    Import-Module .\PSGistManager.psd1

## Examples
#### Get All Gists
    $gists = Get-GHGists

#### Search for a filename
    $gist = Find-GHGistsByCondition -SearchParam "settings.json"

#### Search for a gist by Id
     $gist = Find-GHGistById -Id '400b1fb65c1190aaf812f156340b47b5'

### Gist Object

#### Copy to clipboard
    $gist.ToClipboard()

#### Open gist on github.com
    $gist.OpenGithubPage()

#### Display Filename
    $gist.GetFilename()

#### Display Language
    $gist.GetLanguage()

#### Check permission level
    $gist.IsPublic()

#### Display change times
    $gist.GetCreatedTime()
    $gist.GetUpdatedTime()

#### Download gist to file in CWD
    $gist.DownloadFile()
