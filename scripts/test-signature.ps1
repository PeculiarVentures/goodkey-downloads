Write-Host "Starting signature test process..."
Write-Host "Working directory: $((Get-Location).Path)"

function Test-SignatureProcess {
    param(
        [string]$testContent = "Write-Host 'Hello, Signature Test - $(Get-Date -Format ""yyyy-MM-dd HH:mm:ss"")'"
    )

    Write-Host "`n=== SIGNATURE TEST PHASE ===" -ForegroundColor Cyan

    # Create test file
    $testFile = Join-Path (Get-Location) "test-script.ps1"
    $testContent | Out-File -FilePath $testFile -Force -Encoding UTF8
    Write-Host "Created test file: $testFile"

    # Open certificate store and get code signing certificates
    Write-Host "`nOpening certificate store..."
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("My", "CurrentUser")
    $store.Open("ReadWrite")
    $allCerts = @($store.Certificates)
    $certArray = @($allCerts | Where-Object { $_.EnhancedKeyUsageList.ObjectId -contains "1.3.6.1.5.5.7.3.3" })
    Write-Host "Found $($certArray.Count) code signing certificates"

    if ($certArray.Count -eq 0) {
        Write-Host "No code signing certificates found." -ForegroundColor Yellow
        $store.Close()
        return $false
    }

    # Display certificates
    for ($i = 0; $i -lt $certArray.Count; $i++) {
        $cert = $certArray[$i]
        Write-Host "[$i] $($cert.Subject) [CodeSigning]"
    }
    $store.Close()

    # Prompt user for certificate selection
    do {
        $selection = Read-Host "Enter certificate number to sign the test file"
    } until ($selection -match '^\d+$' -and [int]$selection -lt $certArray.Count)
    $cert = $certArray[[int]$selection]
    Write-Host "Selected certificate: $($cert.Subject)"

    # Determine available hash algorithms
    $hashAlgorithms = @("SHA1", "SHA256", "SHA384", "SHA512")
    Write-Host "`nAvailable hash algorithms:"
    for ($i = 0; $i -lt $hashAlgorithms.Count; $i++) {
        Write-Host "[$i] $($hashAlgorithms[$i])" $(if ($hashAlgorithms[$i] -eq "SHA256") { " (default)" })
    }
    $hashSelection = Read-Host "`nSelect hash algorithm number or press Enter for SHA256"
    if ([string]::IsNullOrEmpty($hashSelection)) {
        $selectedHash = "SHA256"
    }
    elseif ($hashSelection -match '^\d+$' -and [int]$hashSelection -lt $hashAlgorithms.Count) {
        $selectedHash = $hashAlgorithms[[int]$hashSelection]
    }
    else {
        Write-Host "Invalid selection, using SHA256"
        $selectedHash = "SHA256"
    }
    Write-Host "Using algorithm: $selectedHash"

    # Sign the test file
    Write-Host "`nSigning the test file..."
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $signature = Set-AuthenticodeSignature -FilePath $testFile -Certificate $cert -HashAlgorithm $selectedHash
    $stopwatch.Stop()
    $elapsedMs = $stopwatch.ElapsedMilliseconds

    if ($signature.Status -eq "Valid") {
        Write-Host "File signed successfully using $selectedHash in $elapsedMs ms" -ForegroundColor Green
    }
    else {
        Write-Host "Signing failed: $($signature.StatusMessage)" -ForegroundColor Red
        return $false
    }

    # Verify signature
    Write-Host "`nVerifying signature..."
    $verifiedSignature = Get-AuthenticodeSignature -FilePath $testFile
    Write-Host "Signature Status: $($verifiedSignature.Status)"
    Write-Host "Signer: $($verifiedSignature.SignerCertificate.Subject)"
    Write-Host "Timestamp: $($verifiedSignature.TimeStamperCertificate)"

    if ($verifiedSignature.Status -eq "Valid") {
        Write-Host "Signature verification PASSED" -ForegroundColor Green
    }
    else {
        Write-Host "Signature verification FAILED: $($verifiedSignature.StatusMessage)" -ForegroundColor Red
    }

    # Cleanup
    Write-Host "`nCleaning up test file..."
    Remove-Item $testFile -Force
    Write-Host "Test completed"
    return $verifiedSignature.Status -eq "Valid"
}

# Run the test process
Test-SignatureProcess
