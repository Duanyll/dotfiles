# Usage: set_proxy_env http://proxy.example.com:8080
set_proxy_env() {
    export http_proxy=$1
    export https_proxy=$1
    export all_proxy=$1
    export HTTP_PROXY=$1
    export HTTPS_PROXY=$1
    export ALL_PROXY=$1
}

# Usage: unset_proxy_env
unset_proxy_env() {
    unset http_proxy
    unset https_proxy
    unset all_proxy
    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset ALL_PROXY
}

# Usage: set_docker_proxy http://proxy.example.com:8080
# This will configure the Docker client to use an external proxy server
set_docker_proxy() {
    run_python set_docker_proxy.py $1
}

# Usage: set_docker_proxy_on_host 7890
# This will detect the host IP address and configure the Docker client to use a HTTP proxy server on docker host at given port
set_docker_proxy_on_host() {
    local nic_name=$(ip route get 1 | awk '{print $5; exit}')
    local host_ip=$(ip -4 addr show $nic_name | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    run_python set_docker_proxy.py http://$host_ip:$1
}

# Usage: unset_docker_proxy
# Remove the proxy configuration from the Docker client
unset_docker_proxy() {
    run_python set_docker_proxy.py
}