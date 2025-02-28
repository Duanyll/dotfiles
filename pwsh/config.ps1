$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$config_dir = "$script_dir/../config"

function Create-SyncedFile {
    param(
        [string]$source,
        [string]$destination
    )

    # Make source absolute
    $source = (Get-Item $source).FullName
    if (Test-Path $destination) {
        $overwrite = Read-Host "Overwrite $destination ? (y/n)"
        if ($overwrite -ne "y") {
            return
        }
    }
    New-Item -ItemType SymbolicLink -Path $destination -Value $source -Force | Out-Null
    Write-Host "Created $destination -> $source"
}

function Install-SyncedConfigFiles {
    New-Item -ItemType Directory -Path $env:USERPROFILE/.config -Force | Out-Null
    Create-SyncedFile "$config_dir/starship.toml" "$env:USERPROFILE/.config/starship.toml"
}