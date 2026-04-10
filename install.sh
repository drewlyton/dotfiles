#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname)"

echo "==> Installing dotfiles from $DOTFILES_DIR ($OS)"

# --- Homebrew ---
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Set up brew shellenv (different paths on macOS vs Linux)
if [[ "$OS" == "Darwin" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# --- Brew packages ---
echo "==> Installing brew packages..."
brew install \
  stow \
  tmux \
  neovim \
  fzf \
  zoxide \
  ripgrep \
  rbenv \
  gnupg \
  gh \
  cmake \
  elixir

# --- macOS ---
if [[ "$OS" == "Darwin" ]]; then
  echo "==> Installing macOS apps..."
  brew install --cask \
    ghostty \
    nikitabobko/tap/aerospace

  # Xcode Command Line Tools (provides clang/cc)
  if ! xcode-select -p &>/dev/null; then
    echo "==> Installing Xcode Command Line Tools..."
    xcode-select --install
  fi
fi

# --- Linux apt packages ---
if [[ "$OS" == "Linux" ]]; then
  echo "==> Installing apt packages..."
  sudo apt update && sudo apt install -y zsh build-essential
fi

# --- Set zsh as default shell ---
if [[ "$(basename "$SHELL")" != "zsh" ]]; then
  echo "==> Setting zsh as default shell..."
  chsh -s "$(which zsh)"
fi

# --- Create ~/.config if it doesn't exist ---
mkdir -p "$HOME/.config"

# --- Stow packages ---
echo "==> Stowing home/ -> ~/"
stow -v -d "$DOTFILES_DIR" -t "$HOME" home

echo "==> Stowing config/ -> ~/.config/"
stow -v -d "$DOTFILES_DIR" -t "$HOME/.config" config

# --- Oh My Zsh ---
OMZ_DIR="$HOME/.oh-my-zsh"
if [ ! -d "$OMZ_DIR" ]; then
  echo "==> Installing Oh My Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# --- Powerlevel10k ---
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo "==> Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# --- Tmux Plugin Manager ---
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  echo "==> Installing Tmux Plugin Manager..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# --- nvm ---
NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  echo "==> Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# Source nvm so it's available in this session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# --- Node (via nvm) ---
if ! command -v node &>/dev/null; then
  echo "==> Installing Node via nvm..."
  nvm install --lts
fi

# --- bun ---
if ! command -v bun &>/dev/null; then
  echo "==> Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
fi

# Source bun so it's available in this session
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# --- corepack (enables pnpm/yarn via Node) ---
echo "==> Enabling corepack..."
corepack enable

# --- OpenCode plugins ---
if [ -f "$HOME/.config/opencode/package.json" ]; then
  echo "==> Installing OpenCode plugins..."
  (cd "$HOME/.config/opencode" && npm install)
fi

echo ""
echo "==> Done! Restart your shell or run: source ~/.zshenv && source ~/.config/zsh/.zshrc"
echo "==> For tmux plugins, open tmux and press prefix + I to install plugins."
echo "==> Don't forget to: cp ~/.config/zsh/.secrets.example ~/.config/zsh/.secrets"
