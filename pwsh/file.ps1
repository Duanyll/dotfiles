function Clean-DuplicateFiles {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Path,
        [ValidateSet('Simple','Hash')]
        [string]$Mode = 'Simple',
        [switch]$Force
    )

    # 辅助函数：解析带括号的文件名
    function Parse-FileName {
        param(
            [string]$BaseName,
            [string]$Extension
        )

        $currentName = $BaseName
        do {
            $modified = $false

            # 步骤1：去除所有层级的副本后缀
            if ($currentName -match '^(.*?)(\s*(-\s*(Copy|副本)))+$') {
                $currentName = $matches[1].TrimEnd()
                $modified = $true
            }

            # 步骤2：处理数字括号后缀
            if ($currentName -match '^(.*?)\s*\((\d+)\)$') {
                $currentName = $matches[1].TrimEnd()
                $modified = $true
            }

        } while ($modified)

        if ($currentName -ne $BaseName) {
            return @{
                OriginalName = "$currentName$Extension"
                BasePart = $currentName
            }
        }
        return $null
    }


    $targetPath = Resolve-Path $Path -ErrorAction Stop
    $operations = @()

    # 获取所有需要处理的目录（包含根目录和子目录）
    $directories = @($targetPath) + (Get-ChildItem -Path $targetPath -Recurse -Directory | Select-Object -ExpandProperty FullName)

    foreach ($dir in $directories) {
        $groups = @{}

        Get-ChildItem -Path $dir -File | ForEach-Object {
            $parsed = Parse-FileName -BaseName $_.BaseName -Extension $_.Extension
            if ($parsed) {
                $groupKey = $parsed.OriginalName.ToLower()

                if (-not $groups.ContainsKey($groupKey)) {
                    $groups[$groupKey] = @{
                        OriginalFile = $null
                        ParsedInfo = $parsed
                        Duplicates = @()
                    }
                    # 检查原文件是否存在（精确匹配）
                    $originalPath = Join-Path $dir $parsed.OriginalName
                    if (Test-Path -LiteralPath $originalPath) {
                        $groups[$groupKey].OriginalFile = Get-Item -LiteralPath $originalPath
                    }
                }
                $groups[$groupKey].Duplicates += $_
            }
        }

        # 处理每个文件组
        foreach ($groupKey in $groups.Keys) {
            $group = $groups[$groupKey]
            $originalFile = $group.OriginalFile
            $duplicates = $group.Duplicates | Sort-Object Name

            if ($originalFile) {
                if ($Mode -eq 'Hash') {
                    $originalHash = (Get-FileHash $originalFile.FullName -Algorithm SHA256).Hash
                    $validDups = $duplicates | Where-Object {
                        (Get-FileHash $_.FullName).Hash -eq $originalHash
                    }
                    $operations += $validDups | ForEach-Object {
                        [PSCustomObject]@{
                            Type = 'Delete'
                            Path = $_.FullName
                        }
                    }
                } else {
                    $operations += $duplicates | ForEach-Object {
                        [PSCustomObject]@{
                            Type = 'Delete'
                            Path = $_.FullName
                        }
                    }
                }
            } else {
                if ($duplicates.Count -gt 0) {
                    if ($Mode -eq 'Hash') {
                        $hashes = $duplicates | ForEach-Object { 
                            (Get-FileHash $_.FullName -Algorithm SHA256).Hash 
                        } | Select-Object -Unique
                        if ($hashes.Count -ne 1) { continue }
                    }

                    $keepFile = $duplicates[0]
                    $operations += [PSCustomObject]@{
                        Type = 'Rename'
                        Path = $keepFile.FullName
                        NewName = $group.ParsedInfo.OriginalName
                    }
                    $operations += $duplicates[1..($duplicates.Count-1)] | ForEach-Object {
                        [PSCustomObject]@{
                            Type = 'Delete'
                            Path = $_.FullName
                        }
                    }
                }
            }
        }
    }

    # 显示操作列表并确认
    if ($operations.Count -eq 0) {
        Write-Host "没有需要处理的文件。"
        return
    }

    Write-Host "以下操作将被执行："
    $operations | ForEach-Object {
        if ($_.Type -eq 'Delete') {
            Write-Host "[删除] $($_.Path)"
        } else {
            Write-Host "[重命名] $($_.Path) -> $($_.NewName)"
        }
    }

    if (-not $Force) {
        $confirm = Read-Host "是否继续执行？(Y/N)"
        if ($confirm -ne 'Y') {
            Write-Host "操作已取消。"
            return
        }
    }

    # 执行操作（先重命名后删除）
    $operations | Where-Object { $_.Type -eq 'Rename' } | ForEach-Object {
        Rename-Item -Path $_.Path -NewName $_.NewName -Force
    }
    
    $operations | Where-Object { $_.Type -eq 'Delete' } | ForEach-Object {
        Remove-Item -Path $_.Path -Force
    }

    Write-Host "操作已完成。"
}

