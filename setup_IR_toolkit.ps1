# Define the base directory (Assuming script is run inside incident-response-toolkit)
$baseDir = Get-Location

# Define the folder structure (up to 2 levels deep)
$folders = @(
    "01-Preparation",
    "01-Preparation\baseline-checks",
    "01-Preparation\hardening-guides",
    "01-Preparation\playbooks",
    "01-Preparation\training-exercises",
    
    "02-Detection",
    "02-Detection\signature-based",
    "02-Detection\behavioral-detection",
    "02-Detection\malware-analysis",
    "02-Detection\SIEM-detection-queries",
    "02-Detection\IoC-scanning",
    "02-Detection\threat-intelligence",

    "03-Scoping",
    "03-Scoping\endpoint-analysis",
    "03-Scoping\network-analysis",
    "03-Scoping\SIEM-hunting",
    "03-Scoping\firewall-logs-analysis",
    "03-Scoping\attack-path-mapping",
    "03-Scoping\IoC-investigation",

    "04-Containment",
    "04-Containment\host-isolation",
    "04-Containment\network-segmentation",
    "04-Containment\forensic-artifacts",
    "04-Containment\triage-scripts",

    "05-Eradication",
    "05-Eradication\malware-removal",
    "05-Eradication\persistence-removal",
    "05-Eradication\privilege-audit",
    "05-Eradication\forensic-validation",

    "06-Recovery",
    "06-Recovery\system-rebuild",
    "06-Recovery\data-restoration",
    "06-Recovery\business-continuity",
    "06-Recovery\post-recovery-validation",

    "07-Remediation",
    "07-Remediation\patch-management",
    "07-Remediation\security-hardening",
    "07-Remediation\policy-revisions",
    "07-Remediation\security-awareness-training",
    "07-Remediation\security-automation",

    "08-Post-Incident-Actions",
    "08-Post-Incident-Actions\root-cause-analysis",
    "08-Post-Incident-Actions\documentation",
    "08-Post-Incident-Actions\lessons-learned",
    "08-Post-Incident-Actions\compliance-reports",

    "Threat-Intelligence",
    "Documentation"
)

# Create the folders and add .gitkeep files for empty directories
foreach ($folder in $folders) {
    $fullPath = Join-Path -Path $baseDir -ChildPath $folder
    if (!(Test-Path -Path $fullPath)) {
        New-Item -Path $fullPath -ItemType Directory -Force | Out-Null
        Write-Output "Created: $folder"
    } else {
        Write-Output "Already exists: $folder"
    }

    # Add a .gitkeep file to track empty directories in Git
    $gitkeepFile = Join-Path -Path $fullPath -ChildPath ".gitkeep"
    if (!(Test-Path -Path $gitkeepFile)) {
        New-Item -Path $gitkeepFile -ItemType File -Force | Out-Null
        Write-Output "Added .gitkeep to: $folder"
    }
}

# Create essential repository files
$repoFiles = @(
    "README.md",
    "LICENSE",
    "CONTRIBUTING.md",
    ".gitignore"
)

foreach ($file in $repoFiles) {
    $filePath = Join-Path -Path $baseDir -ChildPath $file
    if (!(Test-Path -Path $filePath)) {
        New-Item -Path $filePath -ItemType File -Force | Out-Null
        Write-Output "Created file: $file"
    }
}

# Add .gitignore content
$gitignorePath = Join-Path -Path $baseDir -ChildPath ".gitignore"
$gitignoreContent = @"
# Ignore system files
.DS_Store
Thumbs.db

# Ignore compiled files
*.pyc
*.pyo
*.exe
*.out

# Ignore logs and temp files
logs/
*.log
*.tmp

# Ignore IDE and editor files
.vscode/
.idea/
*.swp
"@
Set-Content -Path $gitignorePath -Value $gitignoreContent

# Initialize Git repository if not already initialized
if (!(Test-Path -Path (Join-Path -Path $baseDir -ChildPath ".git"))) {
    git init | Out-Null
    Write-Output "Initialized Git repository"
}

# Add files to Git and commit
git add .
git commit -m "Initial commit - Incident Response Toolkit structure" | Out-Null
Write-Output "Committed initial structure to Git repository"

Write-Output "Incident Response Toolkit setup is complete!"
