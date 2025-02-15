uninstall_dotfiles() {
    # Remove the lines added by install.sh
    sed -i '/# BEGIN: duanyll-dotfiles/,/# END: duanyll-dotfiles/d' ~/.bashrc
    echo "Uninstalled duanyll-dotfiles from .bashrc, please restart the terminal."
}