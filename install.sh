#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing dotfiles from $DOTFILES_DIR"

# --- Homebrew ---
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --- GNU Stow ---
if ! command -v stow &>/dev/null; then
  echo "==> Installing GNU Stow..."
  brew install stow
fi

# --- Create ~/.config if it doesn't exist ---
mkdir -p "$HOME/.config"

# --- Stow packages ---
echo "==> Stowing home/ -> ~/"
stow -v -d "$DOTFILES_DIR" -t "$HOME" home

echo "==> Stowing config/ -> ~/.config/"
stow -v -d "$DOTFILES_DIR" -t "$HOME/.config" config

# --- Tmux Plugin Manager ---
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  echo "==> Installing Tmux Plugin Manager..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# --- Oh My Zsh ---
OMZ_DIR="$HOME/.oh-my-zsh"
if [ ! -d "$OMZ_DIR" ]; then
  echo "==> Installing Oh My Zsh..."
  RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# --- Powerlevel10k ---
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo "==> Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# --- OpenCode plugins ---
if [ -f "$HOME/.config/opencode/package.json" ]; then
  echo "==> Installing OpenCode plugins..."
  (cd "$HOME/.config/opencode" && npm install)
fi

echo ""
echo "==> Done! Restart your shell or run: source ~/.zshenv && source ~/.config/zsh/.zshrc"
echo "==> For tmux plugins, open tmux and press prefix + I to install plugins."
