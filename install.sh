#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    return 0
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${dst#$HOME/}")"
    echo "backup: $dst -> $BACKUP_DIR/${dst#$HOME/}"
    mv "$dst" "$BACKUP_DIR/${dst#$HOME/}"
  fi
  ln -s "$src" "$dst"
  echo "linked: $dst -> $src"
}

echo "== git submodules =="
git -C "$DOTFILES" submodule update --init --recursive

echo "== oh-my-zsh =="
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
for plugin in zsh-syntax-highlighting zsh-autosuggestions; do
  dir="$ZSH_CUSTOM/plugins/$plugin"
  if [ ! -d "$dir" ]; then
    git clone --depth 1 "https://github.com/zsh-users/$plugin.git" "$dir"
  fi
done

echo "== symlinks =="
link "$DOTFILES/zsh/.zshrc"           "$HOME/.zshrc"
link "$DOTFILES/git/.gitconfig"       "$HOME/.gitconfig"
link "$DOTFILES/tmux/.tmux.conf"      "$HOME/.tmux.conf"
link "$DOTFILES/kitty/kitty.conf"     "$HOME/.config/kitty/kitty.conf"
link "$DOTFILES/kitty/kitty-themes"   "$HOME/.config/kitty/kitty-themes"
link "$DOTFILES/nvim"                 "$HOME/.config/nvim"
link "$DOTFILES/claude/settings.json" "$HOME/.claude/settings.json"
link "$DOTFILES/claude/CLAUDE.md"     "$HOME/.claude/CLAUDE.md"
link "$DOTFILES/claude/RTK.md"        "$HOME/.claude/RTK.md"
link "$DOTFILES/claude/statusline.sh" "$HOME/.claude/statusline.sh"

if [ ! -f "$HOME/.zsh_secrets" ]; then
  cp "$DOTFILES/zsh/.zsh_secrets.example" "$HOME/.zsh_secrets"
  echo "created $HOME/.zsh_secrets from template -- fill in real API keys"
fi

echo "== vscode =="
"$DOTFILES/install-vscode.sh"

echo "done. Backups (if any): $BACKUP_DIR"
