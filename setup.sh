#!/bin/bash
# Claude YouTube Insight Pipeline - Setup Script
# macOS / Linux 용

set -e

CLAUDE_DIR="$HOME/.claude"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "  ╔══════════════════════════════════════════╗"
echo "  ║  Claude YouTube Insight Pipeline Setup   ║"
echo "  ╚══════════════════════════════════════════╝"
echo ""

# ── Step 1: Create directories ──
echo "  [1/5] Creating directories..."
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/scripts"
mkdir -p "$CLAUDE_DIR/skills/youtube-insight/references"
mkdir -p "$CLAUDE_DIR/skills/obsidian-writer/references"
mkdir -p "$CLAUDE_DIR/settings"
echo "        OK"

# ── Step 2: Copy files ──
echo "  [2/5] Copying files..."
cp "$REPO_DIR/commands/youtube.md" "$CLAUDE_DIR/commands/youtube.md"
cp "$REPO_DIR/scripts/youtube_transcript.py" "$CLAUDE_DIR/scripts/youtube_transcript.py"
cp "$REPO_DIR/skills/youtube-insight/SKILL.md" "$CLAUDE_DIR/skills/youtube-insight/SKILL.md"
cp "$REPO_DIR/skills/youtube-insight/references/insight-templates.md" "$CLAUDE_DIR/skills/youtube-insight/references/insight-templates.md"
cp "$REPO_DIR/skills/obsidian-writer/SKILL.md" "$CLAUDE_DIR/skills/obsidian-writer/SKILL.md"
cp "$REPO_DIR/skills/obsidian-writer/references/vault-structure.md" "$CLAUDE_DIR/skills/obsidian-writer/references/vault-structure.md"
cp "$REPO_DIR/skills/obsidian-writer/references/note-examples.md" "$CLAUDE_DIR/skills/obsidian-writer/references/note-examples.md"
echo "        OK (7 files)"

# ── Step 3: Install Python dependency ──
echo "  [3/5] Installing youtube-transcript-api..."
if pip install youtube-transcript-api --quiet 2>/dev/null; then
    echo "        OK"
else
    echo "        WARN: pip install failed. Please run manually:"
    echo "              pip install youtube-transcript-api"
fi

# ── Step 4: Configure Obsidian vault path ──
echo "  [4/5] Configuring Obsidian vault path..."
VAULT_PATH_FILE="$CLAUDE_DIR/settings/youtube-vault-path.txt"

if [ -f "$VAULT_PATH_FILE" ]; then
    existing=$(cat "$VAULT_PATH_FILE")
    echo ""
    echo "        Current vault path: $existing"
    read -p "        Change? (y/N) " change
    if [ "$change" = "y" ]; then
        echo ""
        echo "        Obsidian vault path examples:"
        echo "          /Users/you/Documents/MyVault"
        echo "          /home/you/Obsidian/Notes"
        echo ""
        read -p "        Enter vault path: " vault_path
        vault_path="${vault_path%/}"
        echo -n "$vault_path" > "$VAULT_PATH_FILE"
        echo "        Saved!"
    else
        echo "        Keeping existing path."
        vault_path="$existing"
    fi
else
    echo ""
    echo "        Obsidian vault path is required."
    echo "        This is the root folder of your Obsidian vault."
    echo ""
    echo "        Examples:"
    echo "          /Users/you/Documents/MyVault"
    echo "          /home/you/Obsidian/Notes"
    echo ""
    read -p "        Enter vault path: " vault_path
    vault_path="${vault_path%/}"
    echo -n "$vault_path" > "$VAULT_PATH_FILE"
    echo "        Saved: $vault_path"
fi

# ── Step 5: Create YouTube category folders ──
echo "  [5/5] Creating YouTube category folders in vault..."
yt_base="$vault_path/30_Resource/10_YouTube"
created=0
for cat in "01_자기계발" "02_투자" "03_커리어" "04_기술" "05_비즈니스" "99_기타"; do
    if [ ! -d "$yt_base/$cat" ]; then
        mkdir -p "$yt_base/$cat"
        created=$((created + 1))
    fi
done

if [ $created -gt 0 ]; then
    echo "        Created $created folders"
else
    echo "        All folders already exist"
fi

# ── Done ──
echo ""
echo "  ╔══════════════════════════════════════════╗"
echo "  ║            Setup Complete!               ║"
echo "  ╚══════════════════════════════════════════╝"
echo ""
echo "  Vault : $vault_path"
echo "  Notes : 30_Resource/10_YouTube/[category]/"
echo ""
echo "  Usage : In Claude Code, type:"
echo "          /youtube https://www.youtube.com/watch?v=..."
echo ""
