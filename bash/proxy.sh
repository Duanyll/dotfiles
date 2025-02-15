# Usage: set_proxy_env http://proxy.example.com:8080
set_proxy_env() {
    local proxy=$1
    # If the proxy is a number, assume it is a port number on localhost
    if [[ $proxy =~ ^[0-9]+$ ]]; then
        proxy="http://localhost:$proxy"
    fi
    export http_proxy=$proxy
    export https_proxy=$proxy
    export all_proxy=$proxy
    export HTTP_PROXY=$proxy
    export HTTPS_PROXY=$proxy
    export ALL_PROXY=$proxy
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
    local proxy=$1
    if [[ $proxy =~ ^[0-9]+$ ]]; then
        local nic_name=$(ip route get 1 | awk '{print $5; exit}')
        local host_ip=$(ip -4 addr show $nic_name | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
        proxy="http://$host_ip:$proxy"
    fi
    run_python set_docker_proxy.py $proxy
}

# Usage: unset_docker_proxy
# Remove the proxy configuration from the Docker client
unset_docker_proxy() {
    run_python set_docker_proxy.py
}