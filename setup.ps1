# Claude YouTube Insight Pipeline - Setup Script
# Windows PowerShell 용

$ErrorActionPreference = "Stop"

$ClaudeDir = "$env:USERPROFILE\.claude"
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║  Claude YouTube Insight Pipeline Setup   ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ── Step 1: Create directories ──
Write-Host "  [1/5] Creating directories..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "$ClaudeDir\commands" | Out-Null
New-Item -ItemType Directory -Force -Path "$ClaudeDir\scripts" | Out-Null
New-Item -ItemType Directory -Force -Path "$ClaudeDir\skills\youtube-insight\references" | Out-Null
New-Item -ItemType Directory -Force -Path "$ClaudeDir\skills\obsidian-writer\references" | Out-Null
New-Item -ItemType Directory -Force -Path "$ClaudeDir\settings" | Out-Null
Write-Host "        OK" -ForegroundColor Green

# ── Step 2: Copy files ──
Write-Host "  [2/5] Copying files..." -ForegroundColor Yellow
Copy-Item "$RepoDir\commands\youtube.md" "$ClaudeDir\commands\youtube.md" -Force
Copy-Item "$RepoDir\scripts\youtube_transcript.py" "$ClaudeDir\scripts\youtube_transcript.py" -Force
Copy-Item "$RepoDir\skills\youtube-insight\SKILL.md" "$ClaudeDir\skills\youtube-insight\SKILL.md" -Force
Copy-Item "$RepoDir\skills\youtube-insight\references\insight-templates.md" "$ClaudeDir\skills\youtube-insight\references\insight-templates.md" -Force
Copy-Item "$RepoDir\skills\obsidian-writer\SKILL.md" "$ClaudeDir\skills\obsidian-writer\SKILL.md" -Force
Copy-Item "$RepoDir\skills\obsidian-writer\references\vault-structure.md" "$ClaudeDir\skills\obsidian-writer\references\vault-structure.md" -Force
Copy-Item "$RepoDir\skills\obsidian-writer\references\note-examples.md" "$ClaudeDir\skills\obsidian-writer\references\note-examples.md" -Force
Write-Host "        OK (7 files)" -ForegroundColor Green

# ── Step 3: Install Python dependency ──
Write-Host "  [3/5] Installing youtube-transcript-api..." -ForegroundColor Yellow
try {
    pip install youtube-transcript-api --quiet 2>$null
    Write-Host "        OK" -ForegroundColor Green
} catch {
    Write-Host "        WARN: pip install failed. Please run manually:" -ForegroundColor Red
    Write-Host "              pip install youtube-transcript-api" -ForegroundColor Red
}

# ── Step 4: Configure Obsidian vault path ──
Write-Host "  [4/5] Configuring Obsidian vault path..." -ForegroundColor Yellow
$VaultPathFile = "$ClaudeDir\settings\youtube-vault-path.txt"

if (Test-Path $VaultPathFile) {
    $existing = Get-Content $VaultPathFile -Raw
    $existing = $existing.Trim()
    Write-Host ""
    Write-Host "        Current vault path: $existing" -ForegroundColor Gray
    $change = Read-Host "        Change? (y/N)"
    if ($change -ne "y") {
        Write-Host "        Keeping existing path." -ForegroundColor Green
        $vaultPath = $existing
    } else {
        Write-Host ""
        Write-Host "        Obsidian vault path example:" -ForegroundColor Gray
        Write-Host "          C:\Users\you\Documents\MyVault" -ForegroundColor Gray
        Write-Host "          D:\Obsidian\Notes" -ForegroundColor Gray
        Write-Host ""
        $vaultPath = Read-Host "        Enter vault path"
        $vaultPath = $vaultPath.Trim().TrimEnd('\')
        Set-Content -Path $VaultPathFile -Value $vaultPath -Encoding UTF8 -NoNewline
        Write-Host "        Saved!" -ForegroundColor Green
    }
} else {
    Write-Host ""
    Write-Host "        Obsidian vault path is required." -ForegroundColor White
    Write-Host "        This is the root folder of your Obsidian vault." -ForegroundColor Gray
    Write-Host ""
    Write-Host "        Examples:" -ForegroundColor Gray
    Write-Host "          C:\Users\you\Documents\MyVault" -ForegroundColor Gray
    Write-Host "          C:\Users\you\OneDrive\Documents\Notes" -ForegroundColor Gray
    Write-Host ""
    $vaultPath = Read-Host "        Enter vault path"
    $vaultPath = $vaultPath.Trim().TrimEnd('\')
    Set-Content -Path $VaultPathFile -Value $vaultPath -Encoding UTF8 -NoNewline
    Write-Host "        Saved: $vaultPath" -ForegroundColor Green
}

# ── Step 5: Create YouTube category folders ──
Write-Host "  [5/5] Creating YouTube category folders in vault..." -ForegroundColor Yellow
$categories = @("01_자기계발", "02_투자", "03_커리어", "04_기술", "05_비즈니스", "99_기타")
$ytBase = Join-Path $vaultPath "30_Resource\10_YouTube"

$created = 0
foreach ($cat in $categories) {
    $catPath = Join-Path $ytBase $cat
    if (-not (Test-Path $catPath)) {
        New-Item -ItemType Directory -Force -Path $catPath | Out-Null
        $created++
    }
}
if ($created -gt 0) {
    Write-Host "        Created $created folders" -ForegroundColor Green
} else {
    Write-Host "        All folders already exist" -ForegroundColor Green
}

# ── Done ──
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║            Setup Complete!               ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Vault : $vaultPath" -ForegroundColor White
Write-Host "  Notes : 30_Resource/10_YouTube/[category]/" -ForegroundColor White
Write-Host ""
Write-Host "  Usage : In Claude Code, type:" -ForegroundColor White
Write-Host "          /youtube https://www.youtube.com/watch?v=..." -ForegroundColor Cyan
Write-Host ""
