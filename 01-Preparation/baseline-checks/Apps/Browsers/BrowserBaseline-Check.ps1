# Define output file path (ensure it's based on the original user, not admin user)
$userProfile = if ($env:USERPROFILE -match '-adm$') {
    $env:USERPROFILE -replace '-adm$', ''
} else {
    $env:USERPROFILE
}

$outputFile = "$userProfile\Desktop\browser_certificates.txt"
"" | Out-File -FilePath $outputFile  # Clear or create the file

# ASCII banner
Write-Host @"


+====================================================================================+
|                                                                                    |
|    ___       _      _         ___           _        _        _   ___  ___  ___    |
|   | __| _ _ (_) __ ( )___    / __| __  _ _ (_) _ __ | |_  ___(_) | _ )| __|| _ \   |
|   | _| | '_|| |/ _||/(_-<    \__ \/ _|| '_|| || '_ \|  _|(_-< _  | _ \| _| |  _/   |
|   |___||_|  |_|\__|  /__/    |___/\__||_|  |_|| .__/ \__|/__/(_) |___/|_|  |_|     |
|                                               |_|                                  |
|                                                                                    |
+====================================================================================+
| - Browser Fingerprint Profiler					  	     |
| - Fingerprints installed browsers by capturing their path, certificate, and hash   |
+====================================================================================+

"@

# Spinner wrapper (simulated, synchronous)
function Show-Spinner {
    param (
        [string]$SearchMessage,
        [string]$CheckMessage,
        [string]$HashingMessage,
        [string]$FinalMessage,
        [scriptblock]$Action
    )

    $spinner = @("/","-","\","|")
    $i = 0
    $phase = 0
    $clearLine = ' ' * 80

    $stopTime = (Get-Date).AddSeconds(1.2)
    while ((Get-Date) -lt $stopTime) {
        $spin = $spinner[$i % $spinner.Length]
        switch ($phase) {
            0 {
                Write-Host -NoNewline "`r$SearchMessage [$spin] "
                if ($i -ge 6) { $phase = 1 }
            }
            1 {
                Write-Host -NoNewline "`r$CheckMessage [$spin] "
                if ($i -ge 12) { $phase = 2 }
            }
            2 {
                Write-Host -NoNewline "`r$HashingMessage [$spin] "
            }
        }
        Start-Sleep -Milliseconds 100
        $i++
    }

    # Execute the cert/hash lookup silently
    $output = & $Action
    Write-Host "`r$clearLine`r$FinalMessage [*]`n"
    # Write-Host $output  # <-- suppressed
    Add-Content -Path $outputFile -Value "$output`n"
}


# Certificate check function (returns string to caller)
function Get-CertInfo {
    param (
        [string]$path,
        [string]$label
    )

    if (Test-Path $path) {
        try {
            $signature = Get-AuthenticodeSignature $path
            $subjectLine = if ($signature.SignerCertificate) {
                "Subject: $($signature.SignerCertificate.Subject)"
            } else {
                "Subject: UNSIGNED"
            }

            $hash = try {
                (Get-FileHash -Path $path -Algorithm SHA1).Hash
            } catch {
                "ERROR: Unable to compute hash"
            }

            return @"
[$label]
  Path: $path
  $subjectLine
  SHA1 Hash: $hash
"@
        } catch {
            return "[$label]`n  Path: $path`n  Error: $($_.Exception.Message)`n  Note: File may be restricted."
        }
    } else {
        return "[$label]`n  Path: $path`n  Status: NOT FOUND"
    }
}


# Path finder
function Find-BrowserPath {
    param (
        [string]$exeName
    )

    $searchRoots = @(
        "$env:ProgramFiles",
        "$env:ProgramFiles(x86)",
        "$env:LOCALAPPDATA",
        "$env:ProgramW6432",
        "$env:USERPROFILE\AppData\Local\Programs"
    )

    if ($env:USERPROFILE -match '-adm$') {
        $alt = $env:USERPROFILE -replace '-adm$', ''
        $searchRoots += "$alt\AppData\Local\Programs"
        $searchRoots += "$alt\AppData\Local\Microsoft\WindowsApps"
    }

    foreach ($root in $searchRoots) {
        try {
            $result = Get-ChildItem -Path $root -Recurse -Filter $exeName -ErrorAction SilentlyContinue -Force -File -Depth 4 | Select-Object -First 1
            if ($result) {
                return $result.FullName
            }
        } catch {
            continue
        }
    }

    return $null
}

# Brave
$bravePath = Find-BrowserPath -exeName "brave.exe"
# if ($bravePath) {
#     Write-Host "`nBrave Browser located at: $bravePath`n"
# }

Show-Spinner -SearchMessage "Searching for Brave Browser" `
             -CheckMessage "Found path for Brave. Checking Certificate & Hash" `
             -FinalMessage "Brave Browser Certificate Found & SHA1 Made" `
             -Action {
                 Get-CertInfo -path $bravePath -label "Brave Browser"
             }

# DuckDuckGo
$duckPath = Find-BrowserPath -exeName "duckduckgo.exe"
# if ($duckPath) {
#     Write-Host "`nDuckDuckGo Browser located at: $duckPath`n"
# }
Show-Spinner -SearchMessage "Searching for DuckDuckGo Browser" `
             -CheckMessage "Found path for DuckDuckGo. Checking Certificate & Hash" `
             -FinalMessage "DuckDuckGo Browser Certificate Found & SHA1 Made" `
             -Action {
                 Get-CertInfo -path $duckPath -label "DuckDuckGo Browser"
             }

# Opera
$operaPath = Find-BrowserPath -exeName "opera.exe"
# if ($operaPath) {
#     Write-Host "`nOpera Browser located at: $operaPath`n"
# }
Show-Spinner -SearchMessage "Searching for Opera Browser" `
             -CheckMessage "Found path for Opera. Checking certificate" `
             -FinalMessage "Opera Browser Certificate Found & SHA1 Made" `
             -Action {
                 Get-CertInfo -path $operaPath -label "Opera Browser"
             }

# Footer
Write-Host "`nCertificate information saved to: $outputFile"
