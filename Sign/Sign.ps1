param(
    [Parameter(HelpMessage = "Azure Key Vault URI.", Mandatory = $true)]
    [string]$AzureKeyVaultURI,
    [Parameter(HelpMessage = "Azure Key Vault Client ID.", Mandatory = $true)]
    [string]$AzureKeyVaultClientID,
    [Parameter(HelpMessage = "Azure Key Vault Client Secret.", Mandatory = $true)]
    [string]$AzureKeyVaultClientSecret,
    [Parameter(HelpMessage = "Azure Key Vault Tenant ID.", Mandatory = $true)]
    [string]$AzureKeyVaultTenantID,
    [Parameter(HelpMessage = "Azure Key Vault Certificate Name.", Mandatory = $true)]
    [string]$AzureKeyVaultCertificateName,
    [Parameter(HelpMessage = "Path to the folder containing the files to sign.", Mandatory = $true)]
    [String]$PathToFiles,
    [Parameter(HelpMessage = "File extensions to sign.", Mandatory = $false)]
    [String[]]$FileExtensionsToSign = @(".app"),
    [Parameter(HelpMessage = "Timestamp service.", Mandatory = $false)]
    [string]$TimestampService = "http://timestamp.digicert.com",
    [Parameter(HelpMessage = "Timestamp digest algorithm.", Mandatory = $false)]
    [string]$TimestampDigest = "sha256",
    [Parameter(HelpMessage = "File digest algorithm.", Mandatory = $false)]
    [string]$FileDigest = "sha256"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0
$telemetryScope = $null
$bcContainerHelperPath = $null

# IMPORTANT: No code that can fail should be outside the try/catch

try {
    . (Join-Path -Path $PSScriptRoot -ChildPath "..\AL-Go-Helper.ps1" -Resolve)

    $BcContainerHelperPath = DownloadAndImportBcContainerHelper -baseFolder $ENV:GITHUB_WORKSPACE 

    Register-NavSip

    $Files = Get-FilesWithExtensions -PathToFiles $PathToFiles -Extensions $FileExtensionsToSign
    Write-Host "Signing files:"
    $Files | ForEach-Object { 
        Write-Host "- $_" 
    }

    AzureSignTool sign --file-digest $FileDigest `
        --azure-key-vault-url $AzureKeyVaultURI `
        --azure-key-vault-client-id $AzureKeyVaultClientID `
        --azure-key-vault-tenant-id $AzureKeyVaultTenantID `
        --azure-key-vault-client-secret $AzureKeyVaultClientSecret `
        --azure-key-vault-certificate $AzureKeyVaultCertificateName `
        --timestamp-rfc3161 "$TimestampService" `
        --timestamp-digest $TimestampDigest `
        --verbose `
        $Files
}
catch {
    OutputError -message "AnalyzeTests action failed.$([environment]::Newline)Error: $($_.Exception.Message)$([environment]::Newline)Stacktrace: $($_.scriptStackTrace)"
    TrackException -telemetryScope $telemetryScope -errorRecord $_
}
finally {
    CleanupAfterBcContainerHelper -bcContainerHelperPath $bcContainerHelperPath
}
