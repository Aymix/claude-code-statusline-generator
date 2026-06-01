#!/usr/bin/env bash
# Installs the Claude Code status line: copies the script into ~/.claude and
# registers it in ~/.claude/settings.json without disturbing other settings.
set -e

SRC="$(cd "$(dirname "$0")" && pwd)/statusline-command.sh"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
DEST="$CLAUDE_DIR/statusline-command.sh"
SETTINGS="$CLAUDE_DIR/settings.json"

mkdir -p "$CLAUDE_DIR"
cp "$SRC" "$DEST"
chmod +x "$DEST"
echo "Installed script -> $DEST"

STATUSLINE='{"type":"command","command":"bash '"$DEST"'"}'

if ! command -v jq >/dev/null 2>&1; then
    echo
    echo "jq not found, so settings.json was not edited automatically."
    echo "Add this to $SETTINGS yourself:"
    echo "  \"statusLine\": $STATUSLINE"
    exit 0
fi

if [ -f "$SETTINGS" ]; then
    cp "$SETTINGS" "$SETTINGS.bak"
    jq --argjson sl "$STATUSLINE" '.statusLine = $sl' "$SETTINGS" > "$SETTINGS.tmp" \
        && mv "$SETTINGS.tmp" "$SETTINGS"
    echo "Updated $SETTINGS (backup at $SETTINGS.bak)"
else
    jq -n --argjson sl "$STATUSLINE" '{statusLine: $sl}' > "$SETTINGS"
    echo "Created $SETTINGS"
fi

echo
echo "Done. Restart Claude Code (or ask it to reload the status line)."
