function SplitUnrealPluginTree {
    param($pluginDirName, $branchName)
    
    $pluginDirectory = "Plugins\$pluginDirName" -replace '\\', '/'
    Write-Host $pluginDirectory

    git subtree split --prefix=$pluginDirectory --branch "$branchName"
    git push origin $branchName
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


$configFile

$projectDirectory = $(git rev-parse --show-toplevel)
Set-Location $projectDirectory
# Read the content of the JSON file
$jsonContent = Get-Content -Raw -Path "SubtreeConfig.json"

# Convert the JSON content to a PowerShell object
$configuration = ConvertFrom-Json -InputObject $jsonContent

# Access the array of server IP addresses
$pluginSubtreeList = $configuration.PluginSubtree

# Output the server IP addresses
foreach ($plugin in $pluginSubtreeList) {

    Write-Host "Plugin: $plugin"
    $pluginDirectory = "$PSScriptRoot\Plugins\$plugin"
    $pluginBranchName = "Plugins/$plugin"

    $upluginFiles = Get-ChildItem -Path $pluginDirectory -Filter "*.uplugin" -File

    foreach ($file in $upluginFiles) {

        Write-Host "Found .uplugin file: $($file.FullName)"

        $upluginVersion = GetUPluginVersion "$($file.FullName)"
        Write-Host "Current UPlugin Version : $upluginVersion"
        $pluginVersionTag = "$pluginBranchName-v$upluginVersion"

        SplitUnrealPluginTree $plugin $pluginBranchName

        # switch branch to enable describe tag parsing
        git checkout $pluginBranchName

        # get latest plugin version tag
        $latestVersionTag = $(git describe --tags --abbrev=0 --match "$pluginBranchName-v[0-9]*")
        Write-Host "Latest Version Tag : $latestVersionTag"
        $pattern = '/v(\d+\.\d+(\.\d+)?)'
        $lastVersionSemVer = ""
        if($latestVersionTag -and (Test-Path variable:\latestVersionTag)){
            Write-Host "parsing tag Version"
            $lastVersionSemVer = [regex]::Match($latestVersionTag, $pattern).Groups[1].Value
            Write-Host "parsing tag Version $lastVersionSemVer"
        }
        
        # compare version, skip tagging if version not changed
        if($lastVersionSemVer -and (Test-Path variable:\lastVersionSemVer) ){
            Write-Host "Latest Version SemVer : $lastVersionSemVer"
            $semVerComparison = $(Compare-SemVer $pluginVersionTag $lastVersionSemVer)
        }
        else {
            $semVerComparison = 1
        }

        if ($semVerComparison -gt 0) {

            Write-Host "creating tag $pluginVersionTag"
            git tag $pluginVersionTag $pluginBranchName
            git push origin $pluginVersionTag
        }

        # switch back to previous branch
        git checkout -
    }
}
