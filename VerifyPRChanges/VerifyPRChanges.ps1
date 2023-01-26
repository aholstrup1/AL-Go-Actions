Param(
    [Parameter(HelpMessage = "The GitHub actor running the action", Mandatory = $true)]
    [string] $baseSHA,
    [Parameter(HelpMessage = "The GitHub actor running the action", Mandatory = $true)]
    [string] $headSHA,
    [Parameter(HelpMessage = "The GitHub actor running the action", Mandatory = $true)]
    [string] $repository
)

$ErrorActionPreference = "STOP"
Set-StrictMode -version 2.0
if ($repository -ne $ENV:GITHUB_REPOSITORY) {
    $headers = @{             
        "Authorization" = 'token ${{ secrets.GITHUB_TOKEN }}'
        "Accept" = "application/vnd.github.baptiste-preview+json"
    }
    $url = "$($ENV:GITHUB_API_URL)/repos/$($ENV:GITHUB_REPOSITORY)/compare/$baseSHA...$headSHA"
    $response = Invoke-WebRequest -UseBasicParsing -Headers $headers -Uri $url | ConvertFrom-Js
    Write-Host "Files Changed:"
    $response.files | ForEach-Object {
      $filename = $_.filename
      Write-Host "- $filename $_.status"
      $extension = [System.IO.Path]::GetExtension($filename)
      $name = [System.IO.Path]::GetFileName($filename)
      if ($extension -eq '.ps1' -or $extension -eq '.yaml' -or $extension -eq '.yml' -or $name -eq "CODEOWNERS") {
        throw "Pull Request containing changes to scripts, workflows or CODEOWNERS are not allowed from forks."
      }
    }
}