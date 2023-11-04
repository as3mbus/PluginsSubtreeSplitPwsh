param (
    [Parameter(Position=0, Mandatory=$true)]
    [string]$dirName,

    [Parameter(Position=1, Mandatory=$false)]
    [string]$repoUrl
)

function SplitUnrealPluginTree {
    param($pluginDirName)
    
    $pluginDirectory = "Plugins\$pluginDirName" -replace '\\', '/'
    Write-Host $pluginDirectory

    # Write-Host "git subtree split --prefix=$pluginDirectory --branch" "$pluginDirName"
    git subtree split --prefix=$pluginDirectory --branch $pluginDirName

}

function GetUPluginVersion {
    param($upluginFilePath)
    $upluginContent = Get-Content -Raw -Path $upluginFilePath
    # Convert the JSON content to a PowerShell object
    $jsonObject = $upluginContent | ConvertFrom-Json

    # Access the "FriendlyName" value
    $pluginVersion = $jsonObject.VersionName
    return $pluginVersion
}

function Compare-SemVer {
    param ($version1, $version2)

    $version1Array = $version1 -split '\.'
    $version2Array = $version2 -split '\.'

    for ($i = 0; $i -lt 3; $i++) {
        $part1 = [int]$version1Array[$i]
        $part2 = [int]$version2Array[$i]

        if ($part1 -gt $part2) {
            return 1
        }
        elseif ($part1 -lt $part2) {
            return -1
        }
    }

    return 0
}


$plugin = $dirName
Write-Host "Plugin: $plugin"
$pluginDirectory = "$PSScriptRoot\Plugins\$plugin"

$upluginFiles = Get-ChildItem -Path $pluginDirectory -Filter "*.uplugin" -File

foreach ($file in $upluginFiles) {

    Write-Host "Found .uplugin file: $($file.FullName)"

    $upluginVersion = GetUPluginVersion "$($file.FullName)"
    Write-Host "Current UPlugin Version : $upluginVersion"
    $pluginVersionTag = "v$upluginVersion"

    SplitUnrealPluginTree $plugin

    Write-Host "adding remote"
    git remote add $plugin $repoUrl
    Write-Host "tagging commit"
    git tag $pluginVersionTag $plugin
    Write-Host "pushing branch"
    git push -f $plugin "$($plugin):master"
    Write-Host "pushing tag"
    git push $plugin $pluginVersionTag
    Write-Host "deleting branch"
    git branch -D $plugin
    Write-Host "deleting tag"
    git tag -d $pluginVersionTag
    Write-Host "removing plugin"
    git remote remove $plugin

    Write-Host "remove plugin directory"
    git rm -r $pluginDirectory
    git commit -m "Plugin Submodule Converter: remove $pluginDirectory to be replaced with submodule"

    Write-Host "add submodule"
    git submodule add $repoUrl "Plugins\$plugin"
    git commit -m "Plugin Submodule Converter: add $pluginDirName as submodule"
    git push origin
}
