#!/usr/bin/env bash
# Standalone VSCode setup: settings, keybindings, snippets, extensions.
# Run on its own (no other dotfiles touched) or via install.sh.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)/vscode"

case "$(uname -s)" in
  Darwin) VSCODE_USER="$HOME/Library/Application Support/Code/User" ;;
  Linux)  VSCODE_USER="$HOME/.config/Code/User" ;;
  *) echo "unsupported OS for VSCode paths: $(uname -s)" >&2; exit 1 ;;
esac

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    return 0
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${dst#$VSCODE_USER/}")"
    echo "backup: $dst -> $BACKUP_DIR/${dst#$VSCODE_USER/}"
    mv "$dst" "$BACKUP_DIR/${dst#$VSCODE_USER/}"
  fi
  ln -s "$src" "$dst"
  echo "linked: $dst -> $src"
}

echo "== vscode settings =="
link "$DOTFILES/vscode/settings.json"    "$VSCODE_USER/settings.json"
link "$DOTFILES/vscode/keybindings.json" "$VSCODE_USER/keybindings.json"
link "$DOTFILES/vscode/snippets"         "$VSCODE_USER/snippets"

echo "== vscode extensions =="
if command -v code >/dev/null 2>&1; then
  while IFS= read -r ext; do
    [ -z "$ext" ] && continue
    code --install-extension "$ext" --force
  done < "$DOTFILES/vscode/extensions.txt"
else
  echo "'code' CLI not found in PATH, skipping extension install" >&2
  echo "(VSCode > Cmd+Shift+P > 'Shell Command: Install code command in PATH')" >&2
fi

echo "done. Backups (if any): $BACKUP_DIR"
