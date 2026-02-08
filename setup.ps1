# Claude YouTube Insight Pipeline - Setup Script
# Windows PowerShell 용

$ErrorActionPreference = "Stop"

$ClaudeDir = "$env:USERPROFILE\.claude"
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== Claude YouTube Insight Pipeline Setup ===" -ForegroundColor Cyan
Write-Host ""

# 1. Create directories
Write-Host "[1/4] Creating directories..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "$ClaudeDir\commands" | Out-Null
New-Item -ItemType Directory -Force -Path "$ClaudeDir\scripts" | Out-Null
New-Item -ItemType Directory -Force -Path "$ClaudeDir\skills\youtube-insight\references" | Out-Null
New-Item -ItemType Directory -Force -Path "$ClaudeDir\skills\obsidian-writer\references" | Out-Null

# 2. Copy files
Write-Host "[2/4] Copying files..." -ForegroundColor Yellow
Copy-Item "$RepoDir\commands\youtube.md" "$ClaudeDir\commands\youtube.md" -Force
Copy-Item "$RepoDir\scripts\youtube_transcript.py" "$ClaudeDir\scripts\youtube_transcript.py" -Force
Copy-Item "$RepoDir\skills\youtube-insight\SKILL.md" "$ClaudeDir\skills\youtube-insight\SKILL.md" -Force
Copy-Item "$RepoDir\skills\youtube-insight\references\insight-templates.md" "$ClaudeDir\skills\youtube-insight\references\insight-templates.md" -Force
Copy-Item "$RepoDir\skills\obsidian-writer\SKILL.md" "$ClaudeDir\skills\obsidian-writer\SKILL.md" -Force
Copy-Item "$RepoDir\skills\obsidian-writer\references\vault-structure.md" "$ClaudeDir\skills\obsidian-writer\references\vault-structure.md" -Force
Copy-Item "$RepoDir\skills\obsidian-writer\references\note-examples.md" "$ClaudeDir\skills\obsidian-writer\references\note-examples.md" -Force

# 3. Install Python dependency
Write-Host "[3/4] Installing youtube-transcript-api..." -ForegroundColor Yellow
pip install youtube-transcript-api

# 4. Configure vault path
Write-Host "[4/4] Configuring Obsidian vault path..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "$ClaudeDir\settings" | Out-Null
$VaultPathFile = "$ClaudeDir\settings\youtube-vault-path.txt"
if (Test-Path $VaultPathFile) {
    $existing = Get-Content $VaultPathFile
    Write-Host "  Vault path already configured: $existing"
} else {
    $vaultPath = Read-Host "  Enter your Obsidian vault path (e.g., C:\Users\you\Documents\MyVault)"
    Set-Content -Path $VaultPathFile -Value $vaultPath -Encoding UTF8
    Write-Host "  Saved: $vaultPath"
}

Write-Host ""
Write-Host "=== Setup complete! ===" -ForegroundColor Green
Write-Host "Usage: In Claude Code, type /youtube <youtube-url>"
