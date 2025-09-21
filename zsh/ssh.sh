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