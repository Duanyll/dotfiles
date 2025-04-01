SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Usage: install_tool <tool_name> <tool_url>
# Download the tool executable and put it in ~/.local/bin
install_tool() {
    local tool_name=$1
    local tool_url=$2
    local tool_path="$HOME/.local/bin/$tool_name"

    echo "Installing $tool_name..."
    curl -L $tool_url -o $tool_path
    chmod +x $tool_path
    echo "$tool_name installed at $tool_path"
}

# Usage: install_all_tools
install_all_tools() {
    # If ~/.local/bin does not exist, create it
    if [ ! -d "$HOME/.local/bin" ]; then
        mkdir -p "$HOME/.local/bin"
    fi

    # If ~/.local/bin is not in PATH, add it
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        export PATH="$HOME/.local/bin:$PATH"
        # Usually, ~/.bashrc will add ~/.local/bin to PATH if it already exists, no need to change it
        # echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi

    # Install tools
    install_tool jq https://cdn.duanyll.com/third-party/jq/jq-1.7.1-linux-amd64
    install_tool starship https://cdn.duanyll.com/third-party/starship/starship-1.22.1-linux-musl-amd64
    install_tool aria2c https://cdn.duanyll.com/third-party/aria2c/aria2c-1.36.0-linux-amd64

    # Try to install starship completions
    if ! grep -q "starship" ~/.bashrc; then
        echo 'eval "$(starship init bash)"' >> ~/.bashrc
        echo "Enabled starship completions in ~/.bashrc, run link_synced_files to sync its config"
    fi
}