Clear-Host
# Paths
$RootPublicKeyPath = "C:\Ravi\Learnings\AzureWithNaga2025\Code\Point-2-Site\Certs\AzureP2SRootCert.cer"
$ClientPfxPath = "C:\Ravi\Learnings\AzureWithNaga2025\Code\Point-2-Site\Certs\AzureP2SClientCert.pfx"
$ClientPfxPassword = "YourStrongP@ssword"
$RootPemPath = "C:\Ravi\Learnings\AzureWithNaga2025\Code\Point-2-Site\Certs\AzureP2SRootCert.pem"

# Create exportable Root Certificate
$rootParams = @{
    Type = 'Custom'
    Subject = 'CN=AzureP2SRootCert'
    KeySpec = 'Signature'
    KeyExportPolicy = 'Exportable'
    KeyUsage = 'CertSign'
    KeyUsageProperty = 'Sign'
    KeyLength = 2048
    HashAlgorithm = 'sha256'
    NotAfter = (Get-Date).AddMonths(24)
    CertStoreLocation = 'Cert:\CurrentUser\My'
    Provider = 'Microsoft Enhanced RSA and AES Cryptographic Provider'
}
$rootCert = New-SelfSignedCertificate @rootParams
Write-Output "Root certificate created: $($rootCert.Thumbprint)"

# Export Root public key as DER encoded .cer file
Export-Certificate -Cert $rootCert -FilePath $RootPublicKeyPath
Write-Output "Root certificate public key exported to $RootPublicKeyPath"

# Export Root public key as Base64 PEM encoded file
$certBytes = [System.IO.File]::ReadAllBytes($RootPublicKeyPath)
$base64Cert = [Convert]::ToBase64String($certBytes, 'InsertLineBreaks')
$pem = "-----BEGIN CERTIFICATE-----`n$base64Cert`n-----END CERTIFICATE-----"
$pem | Out-File -FilePath $RootPemPath -Encoding ascii
Write-Output "Root certificate exported in Base64 PEM format at $RootPemPath"

# Create exportable Client Certificate signed by Root
$clientParams = @{
    Type = 'Custom'
    Subject = 'CN=AzureP2SClientCert'
    DnsName = 'P2SClientCert'
    KeySpec = 'Signature'
    KeyExportPolicy = 'Exportable'
    KeyLength = 2048
    HashAlgorithm = 'sha256'
    NotAfter = (Get-Date).AddMonths(18)
    CertStoreLocation = 'Cert:\CurrentUser\My'
    Signer = $rootCert
    Provider = 'Microsoft Enhanced RSA and AES Cryptographic Provider'
    TextExtension = @('2.5.29.37={text}1.3.6.1.5.5.7.3.2') # Client Authentication
}
$clientCert = New-SelfSignedCertificate @clientParams
Write-Output "Client certificate created: $($clientCert.Thumbprint)"

# Export Client certificate (PFX with private key)
$securePwd = ConvertTo-SecureString -String $ClientPfxPassword -Force -AsPlainText
Export-PfxCertificate -Cert $clientCert -FilePath $ClientPfxPath -Password $securePwd
Write-Output "Client certificate exported (PFX with private key) to $ClientPfxPath"

# Cleanup: Remove certificates from CurrentUser\My store
Remove-Item -Path "Cert:\CurrentUser\My\$($rootCert.Thumbprint)" -Force
Remove-Item -Path "Cert:\CurrentUser\My\$($clientCert.Thumbprint)" -Force
Write-Output "Root and client certificates removed from local certificate store."
