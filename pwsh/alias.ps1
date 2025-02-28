# add `which` alias to show the full path of an executable
Set-Alias which Get-Command

# Remove the curl alias, if it exists
if (Test-Path Alias:curl) {
    Remove-Item Alias:curl
}

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