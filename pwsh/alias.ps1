# add `which` alias to show the full path of an executable
Set-Alias which Get-Command

function Launch-Vs2022DevShell {
    $pwd = Get-Location
    . "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1"
    Set-Location $pwd
}

function Launch-Vs2019DevShell {
    $pwd = Get-Location
    . "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\Launch-VsDevShell.ps1"
    Set-Location $pwd
}

# 创建一个全局变量来存储已移除的别名
$script:removedAliases = @()

# 缓存文件路径
$script:cacheFile = Join-Path -Path $env:TEMP -ChildPath "PSAliasCache_$(whoami).xml"

function Remove-ConflictingAliases {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]$Silent,
        
        [Parameter()]
        [switch]$Force
    )

    $startTime = Get-Date
    
    if (-not $Silent) {
        Write-Host "正在检查冲突的别名..." -ForegroundColor Cyan
    }
    
    # 检查是否有缓存，以及是否强制刷新
    $useCachedResults = $false
    if (-not $Force -and (Test-Path -Path $script:cacheFile)) {
        try {
            $script:removedAliases = Import-Clixml -Path $script:cacheFile
            
            # 应用缓存中的别名移除
            foreach ($aliasInfo in $script:removedAliases) {
                # 检查该别名是否存在
                if (Test-Path -Path "Alias:\$($aliasInfo.Name)" -ErrorAction SilentlyContinue) {
                    # 如果当前的别名定义与记录的相同，则移除
                    $currentAlias = Get-Alias -Name $aliasInfo.Name -ErrorAction SilentlyContinue
                    if ($currentAlias -and $currentAlias.Definition -eq $aliasInfo.OriginalCommand) {
                        Remove-Item -Path "Alias:\$($aliasInfo.Name)" -Force -ErrorAction SilentlyContinue
                    }
                }
            }
            
            $useCachedResults = $true
            
            if (-not $Silent) {
                Write-Host "使用缓存的别名配置，已移除 $($script:removedAliases.Count) 个别名" -ForegroundColor Green
            }
        }
        catch {
            if (-not $Silent) {
                Write-Host "缓存读取失败，将重新扫描别名" -ForegroundColor Yellow
            }
            $useCachedResults = $false
        }
        
    }
    
    # 如果没有使用缓存，则执行完整的别名检查
    if (-not $useCachedResults) {
        # 获取所有的别名
        $aliasesToCheck = Get-Alias
        
        # 重置已移除的别名列表
        $script:removedAliases = @()
        
        foreach ($alias in $aliasesToCheck) {
            $aliasName = $alias.Name
            
            # 检查是否有同名的可执行文件在 PATH 中
            $exePath = $null
            
            # 使用更高效的方式检查可执行文件是否存在
            try {
                # 使用Get-Command查找应用程序，设置超时限制
                $exePath = Get-Command -Name $aliasName -CommandType Application -ErrorAction Stop -TotalCount 1
            }
            catch {
                # 忽略错误
                continue
            }
            
            if ($null -ne $exePath) {
                # 记录原始别名指向的命令
                $originalCommand = $alias.Definition
                
                # 获取可执行文件的完整路径
                $exeFullPath = $exePath.Source
                
                if (-not $Silent) {
                    Write-Host "发现冲突的别名: $aliasName -> $originalCommand (与可执行文件 $exeFullPath 冲突)" -ForegroundColor Yellow
                }
                
                # 移除此别名
                Remove-Alias -Name $aliasName
                
                # 记录被移除的别名
                $script:removedAliases += [PSCustomObject]@{
                    Name = $aliasName
                    OriginalCommand = $originalCommand
                    ExePath = $exeFullPath
                }
            }
        }
        
        # 缓存结果
        try {
            # Create the cache directory if it doesn't exist
            $cacheDir = Split-Path -Path $script:cacheFile -Parent
            if (-not (Test-Path -Path $cacheDir)) {
                New-Item -Path $cacheDir -ItemType Directory -Force | Out-Null
            }
            $script:removedAliases | Export-Clixml -Path $script:cacheFile -Force
        }
        catch {
            if (-not $Silent) {
                Write-Host "无法缓存别名配置: $_" -ForegroundColor Yellow
            }
        }
    }
    
    # 显示结果
    if (-not $Silent) {
        if ($script:removedAliases.Count -gt 0) {
            Write-Host "`n已移除以下别名以允许使用 PATH 中的可执行文件:" -ForegroundColor Green
            $script:removedAliases | Format-Table -AutoSize
        }
        else {
            Write-Host "未发现冲突的别名。" -ForegroundColor Green
        }
        
        $endTime = Get-Date
        $duration = $endTime - $startTime
        Write-Host "别名检查耗时: $($duration.TotalMilliseconds) 毫秒" -ForegroundColor Cyan
    }
    
    return $script:removedAliases
}

# 可选：添加一个函数来恢复 PowerShell 的默认别名
function Restore-DefaultAliases {
    Write-Host "正在恢复 PowerShell 默认别名..." -ForegroundColor Cyan
    
    # 如果有记录的已移除别名，优先恢复它们
    if ($script:removedAliases -and $script:removedAliases.Count -gt 0) {
        foreach ($item in $script:removedAliases) {
            # 检查别名是否已经存在
            if (-not (Get-Alias -Name $item.Name -ErrorAction SilentlyContinue)) {
                # 创建别名
                New-Alias -Name $item.Name -Value $item.OriginalCommand -Force -Scope Global
                Write-Host "已恢复别名: $($item.Name) -> $($item.OriginalCommand)" -ForegroundColor Green
            }
            else {
                Write-Host "别名 $($item.Name) 已经存在，跳过恢复" -ForegroundColor Yellow
            }
        }
        
        $script:removedAliases = @()
    }
}

# 重新检查别名的函数，用于强制刷新
function Update-AliasConfiguration {
    [CmdletBinding()]
    param()
    
    # 清除缓存文件
    if (Test-Path -Path $script:cacheFile) {
        Remove-Item -Path $script:cacheFile -Force
    }
    
    # 重新检查别名
    Remove-ConflictingAliases -Force
}

# 启动时自动运行
Remove-ConflictingAliases -Silent | Out-Null