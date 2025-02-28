SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# CONFIG_DIR: ../config
CONFIG_DIR="$SCRIPT_DIR/../config"

try_make_link() {
    local src=$(realpath $1)
    local dest=$2
    if [ -e $dest ]; then
        printf "File $dest already exists. Do you want to overwrite it? (y/n) "
        read -r response
        if [ "$response" != "y" ]; then
            return
        fi
    fi
    ln -sf $src $dest 
}

link_synced_files() {
    mkdir -p ~/.config
    # ~/.config/starship.toml -> ../config/starship.toml
    try_make_link $CONFIG_DIR/starship.toml ~/.config/starship.toml
}