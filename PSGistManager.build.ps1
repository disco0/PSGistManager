param (
    $Configuration = 'Development'
)

$BuildRoot = Resolve-Path $pwd.path
$Module = Split-Path $BuildRoot -Leaf
$RequiredModules = @('Pester', 'PSScriptAnalyzer')


Task Clean {
    if (Test-Path "$BuildRoot\Artifacts") {
        Get-ChildItem "$BuildRoot\Artifacts" -Recurse -Filter *.zip | Foreach-Object {
            Remove-Item $_.FullName -Force
        }
    } else {
        New-Item "$BuildRoot\Artifacts" -ItemType Directory -Force
    }
}

Task InstallDependencies {
    foreach ($m in $RequiredModules) {
        # If module is imported say that and do nothing
        if (Get-Module | Where-Object {$_.Name -eq $m}) {
            write-host "Module $m is already imported."
        } else {
            # If module is not imported, but available on disk then import
            if (Get-Module -ListAvailable | Where-Object {$_.Name -eq $m}) {
                Import-Module $m -Verbose
            } else {
                # If module is not imported, not available on disk, but is in online gallery then install and import
                if (Find-Module -Name $m | Where-Object {$_.Name -eq $m}) {
                    Install-Module -Name $m -Force -Verbose -Scope CurrentUser
                    Import-Module $m -Verbose
                } else {
                    # If module is not imported, not available and not in online gallery then abort
                    write-host "Module $m not imported, not available and not in online gallery, exiting."
                    EXIT 1
                }
            }
        }
    }
}



task Analyze {
    $scriptAnalyzerParams = @{
        Path = "$BuildRoot\lib"
        Severity = @('Error', 'Warning')
        Recurse = $true
        Verbose = $false
        ExcludeRule = 'PSUseDeclaredVarsMoreThanAssignments'
    }

    $saResults = Invoke-ScriptAnalyzer @scriptAnalyzerParams

    if ($saResults) {
        $saResults | Format-Table
        throw "One or more PSScriptAnalyzer errors/warnings where found."
    }
}

task Test {
    $invokePesterParams = @{
        Strict = $true
        PassThru = $true
        Verbose = $false
        EnableExit = $false
    }

    # Publish Test Results as NUnitXml
    $testResults = Invoke-Pester @invokePesterParams;

    $numberFails = $testResults.FailedCount
    assert($numberFails -eq 0) ('Failed "{0}" unit tests.' -f $numberFails)
}


Task Build {
    $ManifestPath = "$BuildRoot\$Module.psd1"
    $funcs = [System.Collections.ArrayList]::new()
    Get-ChildItem -Path "$BuildRoot\lib" -Filter *.ps1 | ForEach-Object {
        $funcs.Add($_.BaseName)
    }

    if (Test-Path $ManifestPath) {
        $version = Test-ModuleManifest "$ManifestPath" | Select-Object -ExpandProperty Version
        $guid = (Test-ModuleManifest "$ManifestPath" | Select-Object -ExpandProperty Guid).Guid
    } else {
        $version = '0.0.1'
        $guid = New-Guid
    }

    $manifest = @{
        Path = $manifestPath
        RootModule = "$Module.psm1"
        ModuleVersion = $version
        Author = 'Nick Ferguson <ncf423@gmail.com'
        Company = 'none'
        GUID = $guid
        Copyright = "$((Get-Date).year) Nick Ferguson"
        Description = 'Manager Github Gists from PowerShell CLI'
        PowerShellVersion = '5.1'
        FunctionsToExport = $funcs
    }
    if (Test-Path $ManifestPath) {
        Update-ModuleManifest  @manifest
    } else {
        New-ModuleManifest @manifest
    }
}


Task IncrementVersion {

    $ManifestPath = "$BuildRoot\$Module.psd1"
    $ModuleVersion = Test-ModuleManifest "$ManifestPath" | Select-Object -ExpandProperty Version

    $Build = $ModuleVersion.Build
    $Minor = $ModuleVersion.Minor
    $Major = $ModuleVersion.Major

    $Build++
    if ($env:BumpMinorVersion) { $Minor++ }

    $NewVersion = [System.Version]$("{0}.{1}.{2}" -f $Major, $Minor, $Build)
    Update-ModuleManifest -Path "$ManifestPath" -ModuleVersion $NewVersion
    $env:Build = $Build
}

task Archive {
    $Artifacts = "$BuildRoot\Artifacts"
    Compress-Archive  -LiteralPath "$BuildRoot\$Module.psd1" -DestinationPath "$Artifacts\$Module.zip"
    Compress-Archive -Path "$BuildRoot\$Module.psm1" -Update -DestinationPath "$Artifacts\$Module.zip"
    Compress-Archive -Path "$BuildRoot\lib" -Update -Destinationpath "$Artifacts\$Module.zip"
    Compress-Archive -Path "$BuildRoot\LICENSE" -Update -Destinationpath "$Artifacts\$Module.zip"
}


task PublishModule -If ($Configuration -eq 'Production') {
    Try {
        # Build a splat containing the required details and make sure to Stop for errors which will trigger the catch
        $params = @{
            Path        = ('{0}\Output\PSJwt' -f $PSScriptRoot )
            NuGetApiKey = $env:psgallerykey
            ErrorAction = 'Stop'
        }
        Publish-Module @params
        Write-Output -InputObject ('PSJwt PowerShell Module version published to the PowerShell Gallery')
    }
    Catch {
        throw $_
    }
}
