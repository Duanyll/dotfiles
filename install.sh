# Get the location of the script
INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check .bashrc already has the installation (marked by # BEGIN: duanyll-dotfiles)
if grep -q "# BEGIN: duanyll-dotfiles" ~/.bashrc; then
    echo "Already installed. Exiting..."
    exit 0
fi

# Add the following lines to .bashrc
echo "" >> ~/.bashrc
echo "# BEGIN: duanyll-dotfiles" >> ~/.bashrc
echo "source $INSTALL_DIR/bash/index.sh" >> ~/.bashrc
echo "# END: duanyll-dotfiles" >> ~/.bashrc
echo "" >> ~/.bashrc