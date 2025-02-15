sync_windows_ssh() {
    # If not running on WSL, return
    if [ ! -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
        printf "Not running on WSL\n"
        return
    fi
    local windows_user=$(/mnt/c/Windows/System32/whoami.exe | sed 's/\\/\//g' | awk -F/ '{print $NF}' | tr -d '\r')
    local windows_ssh_dir="/mnt/c/Users/$windows_user/.ssh"
    local wsl_ssh_dir="$HOME/.ssh"
    # If Windows SSH directory does not exist, return
    if [ ! -d "$windows_ssh_dir" ]; then
        printf "Windows SSH directory does not exist\n"
        return
    fi
    # If WSL SSH directory does not exist, create it
    if [ ! -d "$wsl_ssh_dir" ]; then
        mkdir -p "$wsl_ssh_dir"
        chmod 700 "$wsl_ssh_dir"
    fi
    # Copy ~/.ssh/config
    if [ -f "$windows_ssh_dir/config" ]; then
        cp "$windows_ssh_dir/config" "$wsl_ssh_dir/config"
        # Set permissions
        chmod 600 "$wsl_ssh_dir/config"
    fi
    # Copy ~/.ssh/know_hosts
    if [ -f "$windows_ssh_dir/known_hosts" ]; then
        cp "$windows_ssh_dir/known_hosts" "$wsl_ssh_dir/known_hosts"
        # Set permissions
        chmod 644 "$wsl_ssh_dir/known_hosts"
    fi
    # Copy private keys (file content start with -----BEGIN)
    for file in $(find -L "$windows_ssh_dir" -maxdepth 1 -type f -exec grep -q -e "-----BEGIN" {} \; -print); do
        cp "$file" "$wsl_ssh_dir"
        # Set permissions
        chmod 600 "$wsl_ssh_dir/$(basename $file)"
    done
}

# Usage: send_docker_image <tag> <host>
# Export the Docker image with the given tag locally and send it to the remote host, then import it
send_docker_image() {
    local tag=$1
    local host=$2
    local image_id=$(docker images -q $tag)
    local image_file="/tmp/image.tar"
    # Export the image
    docker save -o $image_file $tag
    # Send the image to the remote host
    scp -C $image_file $host:$image_file
    # Import the image on the remote host
    ssh $host "docker load -i $image_file && rm $image_file"
    # Clean up
    rm $image_file
}

# Usage: send_docker_volume <volume> <host>
# Export the Docker volume with the given name locally and send it to the remote host, then import it
send_docker_volume() {
    local volume=$1
    local host=$2
    local volume_file="/tmp/volume.tar"
    # Export the volume
    docker run --rm -v $volume:/volume -v $volume_file:/volume.tar alpine tar cf /volume.tar -C /volume .
    # Send the volume to the remote host
    scp $volume_file $host:$volume_file
    # Import the volume on the remote host
    ssh $host "docker run --rm -v $volume:/volume -v $volume_file:/volume.tar alpine sh -c 'cd /volume && tar xf /volume.tar'"
    # Clean up
    rm $volume_file
    ssh $host "rm $volume_file"
}