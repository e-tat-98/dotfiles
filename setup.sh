#!/usr/bin/env bash

set -e

DOTFILES_DIR="$HOME/dotfiles"
ZSHRC=$DOTFILES_DIR/.zshrc
OS="$(uname -s)"

echo "🚀 dotfiles setup start"

# ==============================
# Make zsh the default shell
# ==============================
CURRENT_SHELL="$(basename "$SHELL")"
ZSH_PATH="$(which zsh || true)"

if [[ -n "$ZSH_PATH" && "$CURRENT_SHELL" != "zsh" ]]; then
  echo "🔧 Changing default shell to zsh..."
  # WSL / Linux / macOS 共通
  chsh -s "$ZSH_PATH" && echo "✅ Default shell changed to zsh. Please log out and log in again."
else
  echo "✅ zsh is already the default shell or not installed"
fi

# ==============================
# .zshrc symlink
# ==============================
ZSHRC_TARGET="$HOME/.zshrc"
ZSHRC_SOURCE="$DOTFILES_DIR/.zshrc"

if [[ -e "$ZSHRC_TARGET" || -L "$ZSHRC_TARGET" ]]; then
  echo "⚠️  ~/.zshrc already exists, backing up"
  mv "$ZSHRC_TARGET" "$ZSHRC_TARGET.backup.$(date +%s)"
fi

echo "🔗 Linking ~/.zshrc -> $ZSHRC_SOURCE"
ln -s "$ZSHRC_SOURCE" "$ZSHRC_TARGET"

# ==============================
# Volta
# ==============================
if ! command -v volta >/dev/null 2>&1; then
  echo "📦 Installing Volta..."
  curl https://get.volta.sh | bash
else
  echo "✅ Volta already installed"
fi

if ! grep -q 'VOLTA_HOME="$HOME/.volta"' "$ZSHRC"; then
  cat << 'EOF' >> "$ZSHRC"

# ==============================
# Path
# ==============================
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
EOF
fi

# ==============================
# Git commit template
# ==============================
git config --global commit.template "$DOTFILES_DIR/.gitmessage.txt"
echo "✅ Git commit template set to $DOTFILES_DIR/.gitmessage.txt"

# ==============================
# macOS
# ==============================
if [[ "$OS" == "Darwin" ]]; then
  echo "🍎 macOS detected"

  if ! command -v brew >/dev/null 2>&1; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ -d /opt/homebrew/bin ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  else
    echo "✅ Homebrew already installed"
  fi

  echo "📦 Installing packages via Brewfile..."
  brew bundle --file="$DOTFILES_DIR/Brewfile"

# ==============================
# Linux / WSL
# ==============================
elif [[ "$OS" == "Linux" ]]; then
  echo "🐧 Linux / WSL detected"

  sudo apt update

  echo "📦 Installing packages..."
  sudo apt install -y \
    peco \
    jq \
    gh \
    zsh

else
  echo "❌ Unsupported OS: $OS"
  exit 1
fi

echo "🎉 dotfiles setup complete!"
