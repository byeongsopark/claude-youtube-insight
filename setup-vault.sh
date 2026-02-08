#!/bin/bash
# Obsidian 볼트에 YouTube 카테고리 폴더 생성
# 볼트 경로를 인자로 전달: ./setup-vault.sh /path/to/vault

VAULT_PATH="${1:-$(cat "$HOME/.claude/settings/youtube-vault-path.txt" 2>/dev/null)}"

if [ -z "$VAULT_PATH" ]; then
    echo "Usage: ./setup-vault.sh <vault-path>"
    echo "Or set vault path first via setup.sh"
    exit 1
fi

echo "Creating YouTube folders in: $VAULT_PATH"

mkdir -p "$VAULT_PATH/30_Resource/10_YouTube/01_자기계발"
mkdir -p "$VAULT_PATH/30_Resource/10_YouTube/02_투자"
mkdir -p "$VAULT_PATH/30_Resource/10_YouTube/03_커리어"
mkdir -p "$VAULT_PATH/30_Resource/10_YouTube/04_기술"
mkdir -p "$VAULT_PATH/30_Resource/10_YouTube/05_비즈니스"
mkdir -p "$VAULT_PATH/30_Resource/10_YouTube/99_기타"

echo "Done! YouTube category folders created."
