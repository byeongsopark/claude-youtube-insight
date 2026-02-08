#!/bin/bash
# Claude YouTube Insight Pipeline - Setup Script
# macOS / Linux 용

set -e

CLAUDE_DIR="$HOME/.claude"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Claude YouTube Insight Pipeline Setup ==="
echo ""

# 1. Create directories
echo "[1/4] Creating directories..."
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/scripts"
mkdir -p "$CLAUDE_DIR/skills/youtube-insight/references"
mkdir -p "$CLAUDE_DIR/skills/obsidian-writer/references"

# 2. Copy files
echo "[2/4] Copying files..."
cp "$REPO_DIR/commands/youtube.md" "$CLAUDE_DIR/commands/youtube.md"
cp "$REPO_DIR/scripts/youtube_transcript.py" "$CLAUDE_DIR/scripts/youtube_transcript.py"
cp "$REPO_DIR/skills/youtube-insight/SKILL.md" "$CLAUDE_DIR/skills/youtube-insight/SKILL.md"
cp "$REPO_DIR/skills/youtube-insight/references/insight-templates.md" "$CLAUDE_DIR/skills/youtube-insight/references/insight-templates.md"
cp "$REPO_DIR/skills/obsidian-writer/SKILL.md" "$CLAUDE_DIR/skills/obsidian-writer/SKILL.md"
cp "$REPO_DIR/skills/obsidian-writer/references/vault-structure.md" "$CLAUDE_DIR/skills/obsidian-writer/references/vault-structure.md"
cp "$REPO_DIR/skills/obsidian-writer/references/note-examples.md" "$CLAUDE_DIR/skills/obsidian-writer/references/note-examples.md"

# 3. Install Python dependency
echo "[3/4] Installing youtube-transcript-api..."
pip install youtube-transcript-api

# 4. Configure vault path
echo "[4/4] Configuring Obsidian vault path..."
mkdir -p "$CLAUDE_DIR/settings"
if [ -f "$CLAUDE_DIR/settings/youtube-vault-path.txt" ]; then
    echo "  Vault path already configured: $(cat "$CLAUDE_DIR/settings/youtube-vault-path.txt")"
else
    echo "  Enter your Obsidian vault path (e.g., /Users/you/Documents/MyVault):"
    read -r vault_path
    echo "$vault_path" > "$CLAUDE_DIR/settings/youtube-vault-path.txt"
    echo "  Saved: $vault_path"
fi

echo ""
echo "=== Setup complete! ==="
echo "Usage: In Claude Code, type /youtube <youtube-url>"
