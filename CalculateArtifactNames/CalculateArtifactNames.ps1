Param(
    [Parameter(HelpMessage = "settings", Mandatory = $true)]
    [string] $settings,
    [Parameter(HelpMessage = "project", Mandatory = $true)]
    [string] $project,
    [Parameter(HelpMessage = "buildmode", Mandatory = $true)]
    [string] $buildMode,
    [Parameter(HelpMessage = "refname", Mandatory = $true)]
    [string] $refName
)

Write-Host "##[group]Calculate Artifact Names"
Write-Host "Settings: $settings"
Write-Host "Project: $project"
Write-Host "BuildMode: $buildMode"
Write-Host "RefName: $refName"


$ErrorActionPreference = "STOP"
Set-StrictMode -version 2.0

$settings = $settings | ConvertFrom-Json

if ($project -eq ".") { 
  $project = $settings.repoName 
}

if ($buildMode -eq 'Default') { 
  $buildMode = '' 
}

'Apps','Dependencies','TestApps','TestResults','BcptTestResults','BuildOutput','ContainerEventLog' | ForEach-Object {
  $name = "$($_)ArtifactsName"
  $value = "$($project.Replace('\','_').Replace('/','_'))-$($ref)-$buildMode$_-$($settings.repoVersion).$($settings.appBuild).$($settings.appRevision)"
  Add-Content -Path $env:GITHUB_OUTPUT -Value "$name=$value"
  Add-Content -Path $env:GITHUB_ENV -Value "$name=$value"
}
Add-Content -Path $env:GITHUB_OUTPUT -Value "BuildMode=$buildMode"
Add-Content -Path $env:GITHUB_ENV -Value "BuildMode=$buildMode"
