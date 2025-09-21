# Get the location of the script (compatible with both bash and zsh)
if [[ -n "${BASH_SOURCE[0]}" ]]; then
    SCRIPT_PATH="${BASH_SOURCE[0]}"
elif [[ -n "${(%):-%x}" ]]; then
    SCRIPT_PATH="${(%):-%x}"
else
    SCRIPT_PATH="$0"
fi
INSTALL_DIR="$( cd "$( dirname "$SCRIPT_PATH" )" && pwd )"

# Detect shell and set appropriate config file and source
if [[ "$SHELL" == *"zsh"* ]]; then
    CONFIG_FILE="$HOME/.zshrc"
    SOURCE_FILE="$INSTALL_DIR/zsh/index.sh"
else
    CONFIG_FILE="$HOME/.bashrc"
    SOURCE_FILE="$INSTALL_DIR/bash/index.sh"
fi

# Check config file already has the installation (marked by # BEGIN: duanyll-dotfiles)
if grep -q "# BEGIN: duanyll-dotfiles" "$CONFIG_FILE"; then
    echo "Already installed. Exiting..."
    exit 0
fi

# Add the following lines to config file
echo "" >> "$CONFIG_FILE"
echo "# BEGIN: duanyll-dotfiles" >> "$CONFIG_FILE"
echo "source $SOURCE_FILE" >> "$CONFIG_FILE"
echo "# END: duanyll-dotfiles" >> "$CONFIG_FILE"
echo "" >> "$CONFIG_FILE"

echo "Installation complete! Please restart your terminal or run 'source $CONFIG_FILE' to apply changes."