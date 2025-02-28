# Get the location of the script
$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Check $profile already has the installation (marked by # BEGIN: duanyll-dotfiles)
$profile_path = $PROFILE
$profile_content = Get-Content $profile_path
$profile_content | Select-String -Pattern "# BEGIN: duanyll-dotfiles" | ForEach-Object {
    Write-Host "Already installed. Exiting..."
    return
}

# Add the installation to $profile
$profile_content += @"
# BEGIN: duanyll-dotfiles
. "$script_dir/proxy.ps1"
# END: duanyll-dotfiles
"@

# Write the updated $profile
Set-Content -Path $profile_path -Value $profile_content
Write-Host "Installed successfully."