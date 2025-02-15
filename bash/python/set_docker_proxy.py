import os
import sys
import json
import io

def set_docker_proxy(proxy):
    config_path = os.path.expanduser('~/.docker/config.json')
    if not os.path.exists(config_path):
        config = {}
    else:
        with io.open(config_path, 'r', encoding='utf-8') as f:
            config = json.load(f)
    config.setdefault('proxies', {}).setdefault('default', {})
    if proxy is None:
        for key in ['httpProxy', 'httpsProxy', 'allProxy']:
            config['proxies']['default'].pop(key, None)
    else:
        for key in ['httpProxy', 'httpsProxy', 'allProxy']:
            config['proxies']['default'][key] = proxy
    with io.open(config_path, 'w', encoding='utf-8') as f:
        json.dump(config, f, indent=4, ensure_ascii=False)

if __name__ == '__main__':
    proxy = sys.argv[1] if len(sys.argv) > 1 else None
    set_docker_proxy(proxy)