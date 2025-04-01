download_civitai() {
    local model_version_id="$1"
    local api_url="https://civitai.com/api/v1/model-versions/${model_version_id}"
    
    # 检查CIVITAI_TOKEN环境变量
    if [ -z "$CIVITAI_TOKEN" ]; then
        read -p "Please enter your Civitai API token: " CIVITAI_TOKEN
        if [ -z "$CIVITAI_TOKEN" ]; then
            echo "Error: API token is required"
            return 1
        fi
    fi

    # 获取模型元数据
    metadata=$(curl -s "$api_url")
    
    # 检查是否成功获取元数据
    if [ $? -ne 0 ]; then
        echo "Error: Failed to fetch model metadata"
        return 1
    fi

    # 解析文件名和下载链接
    filename=$(echo "$metadata" | jq -r '.files[0].name')
    download_url=$(echo "$metadata" | jq -r '.files[0].downloadUrl')
    
    # 检查解析结果
    if [ -z "$filename" ] || [ "$filename" = "null" ] || [ -z "$download_url" ] || [ "$download_url" = "null" ]; then
        echo "Error: Failed to parse filename or download URL from metadata"
        return 1
    fi

    # 添加token到下载链接
    download_url="${download_url}?token=${CIVITAI_TOKEN}"

    # 使用aria2c下载文件
    echo "Downloading $filename..."
    aria2c -x 8 -s 8 -k 1M "$download_url" -o "$filename"
    
    if [ $? -eq 0 ]; then
        echo "Download completed successfully"
    else
        echo "Error: Download failed"
        return 1
    fi
}