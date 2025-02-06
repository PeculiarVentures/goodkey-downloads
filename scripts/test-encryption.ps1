Write-Host "Starting encryption/decryption test process..."
Write-Host "Working directory: $((Get-Location).Path)"

function Test-EncryptionProcess {
    param(
        [string]$testMessage = "Test encryption message - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    )

    Write-Host "`n=== ENCRYPTION PHASE ===" -ForegroundColor Cyan
    Write-Host "Test message: $testMessage"

    # Get certificates
    Write-Host "`nOpening certificate store..."
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("My", "CurrentUser")
    $store.Open("ReadWrite")

    $allCerts = @($store.Certificates)
    Write-Host "Found $($allCerts.Count) total certificates"
    $certArray = @($allCerts | Where-Object { $_.EnhancedKeyUsageList.ObjectId -contains "1.3.6.1.4.1.311.80.1" })
    Write-Host "Found $($certArray.Count) encryption certificates"

    if ($certArray.Count -eq 0) {
        Write-Host "No document encryption certificates found." -ForegroundColor Yellow
        $certArray = $allCerts
        Write-Host "`nShowing all certificates:"
    }

    # Display certificates
    for ($i = 0; $i -lt $certArray.Count; $i++) {
        $cert = $certArray[$i]
        $usage = if ($cert.EnhancedKeyUsageList.ObjectId -contains "1.3.6.1.4.1.311.80.1") { " [DocEncryption]" } else { "" }
        Write-Host "[$i] $($cert.Subject)$usage"
    }

    # Get certificate selection
    do {
        $selection = Read-Host "Enter certificate number"
    } until ($selection -match '^\d+$' -and [int]$selection -lt $certArray.Count)

    $cert = $certArray[[int]$selection]
    $store.Close()

    # Encrypt
    $outputFile = Join-Path (Get-Location) "test-encrypted.cms"
    Write-Host "`nEncrypting message using certificate: $($cert.Subject)"

    try {
        Protect-CmsMessage -To $cert -Content $testMessage -OutFile $outputFile
        Write-Host "Encryption successful: $outputFile" -ForegroundColor Green

        # Immediate decryption test
        Write-Host "`n=== DECRYPTION PHASE ===" -ForegroundColor Cyan
        Write-Host "Attempting to decrypt message..."

        $decryptedText = Unprotect-CmsMessage -Path $outputFile

        Write-Host "`nDecryption Results:" -ForegroundColor Green
        Write-Host "Original message: $testMessage"
        Write-Host "Decrypted message: $decryptedText"

        if ($testMessage -eq $decryptedText) {
            Write-Host "`nTEST PASSED: Messages match perfectly!" -ForegroundColor Green
        } else {
            Write-Host "`nTEST FAILED: Messages do not match!" -ForegroundColor Red
        }

        # Cleanup
        Write-Host "`nCleaning up test file..."
        Remove-Item $outputFile -Force
        Write-Host "Test completed successfully"
    }
    catch {
        Write-Host "`nError during test:" -ForegroundColor Red
        Write-Host $_.Exception.Message
        if (Test-Path $outputFile) {
            Remove-Item $outputFile -Force
        }
        return $false
    }
}

# Run the test
Test-EncryptionProcess
