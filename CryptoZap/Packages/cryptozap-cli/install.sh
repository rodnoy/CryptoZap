#!/bin/bash

set -e

# Defining the architecture
INSTALL_DIR="/usr/local/bin"
if [[ "$(uname -m)" == "arm64" ]]; then
  if [[ -d "/opt/homebrew/bin" ]]; then
    INSTALL_DIR="/opt/homebrew/bin"
  fi
fi

echo "🧹 Cleaning previous build..."
swift package clean

echo "📦 Building cryptozap-cli..."
swift build -c release --product cryptozap-cli

BINARY_PATH=".build/release/cryptozap-cli"

if [[ ! -f "$BINARY_PATH" ]]; then
  echo "❌ Build failed: $BINARY_PATH not found"
  exit 1
fi

echo "📂 Installing to $INSTALL_DIR..."
cp "$BINARY_PATH" "$INSTALL_DIR/cryptozap-cli"
chmod +x "$INSTALL_DIR/cryptozap-cli"

echo "✅ Installed: $(which cryptozap-cli)"
cryptozap-cli --version

# Optional: install shell autocompletion
USER_SHELL=$(basename "$SHELL")
echo "🔧 Installing autocompletion for $USER_SHELL..."

COMPLETION_BASE="${INSTALL_DIR}/_cryptozap_autocomplete"
mkdir -p "$COMPLETION_BASE"

case "$USER_SHELL" in
  zsh)
    cryptozap-cli --generate-completion-script zsh > "$COMPLETION_BASE/_cryptozap-cli"
    if ! grep -q "_cryptozap_autocomplete" ~/.zshrc; then
      echo "# Added by CryptoZap CLI" >> ~/.zshrc
      echo "fpath+=($COMPLETION_BASE)" >> ~/.zshrc
      echo "autoload -U compinit && compinit" >> ~/.zshrc
      echo "🔁 Autocompletion path added to ~/.zshrc"
    fi
    # Fix insecure permissions warning from zsh compinit
    if command -v compaudit >/dev/null 2>&1; then
      compaudit | while read -r dir; do
        echo "🔐 Fixing insecure permissions for: $dir"
        chmod g-w,o-w "$dir"
      done
      echo "💡 If you still see zsh 'insecure directory' warning, run:"
      echo "   chmod go-w /opt/homebrew/bin"
    else
      echo "⚠️ compaudit not found. Skipping permission fix. You can run it manually from zsh:"
      echo "   compaudit | xargs chmod g-w,o-w"
    fi
    ;;
  bash)
    cryptozap-cli --generate-completion-script bash > "$COMPLETION_BASE/cryptozap-cli.bash"
    COMPLETION_PATH="$HOME/.bash_completion"
    touch "$COMPLETION_PATH"
    if ! grep -q "$COMPLETION_BASE/cryptozap-cli.bash" "$COMPLETION_PATH"; then
      echo "# Added by CryptoZap CLI" >> "$COMPLETION_PATH"
      echo "source $COMPLETION_BASE/cryptozap-cli.bash" >> "$COMPLETION_PATH"
      echo "🔁 Autocompletion path added to ~/.bash_completion"
    fi
    ;;
  fish)
    FISH_COMPLETION_DIR="$HOME/.config/fish/completions"
    mkdir -p "$FISH_COMPLETION_DIR"
    cryptozap-cli --generate-completion-script fish > "$FISH_COMPLETION_DIR/cryptozap-cli.fish"
    echo "# Added by CryptoZap CLI" >> "$FISH_COMPLETION_DIR/cryptozap-cli.fish"
    echo "🔁 Autocompletion installed for fish"
    ;;
  *)
    echo "⚠️ Shell $USER_SHELL is not supported for autocompletion setup."
    ;;
esac

# Install man page
echo "📖 Installing man page..."
MAN_PAGE_SOURCE="./cryptozap-cli.1"
MAN_TARGET_DIR="/usr/local/share/man/man1"
if [[ -f "$MAN_PAGE_SOURCE" ]]; then
  sudo mkdir -p "$MAN_TARGET_DIR"
  sudo cp "$MAN_PAGE_SOURCE" "$MAN_TARGET_DIR/"
  sudo gzip -f "$MAN_TARGET_DIR/cryptozap-cli.1"
  echo "✅ Man page installed. You can test it with: man cryptozap-cli"
else
  echo "⚠️ Man page not found at $MAN_PAGE_SOURCE. Skipping."
fi
