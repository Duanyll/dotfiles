function Set-ProxyEnvironments {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$proxy
    )

    # If $proxy is a number, assume it's a http port on localhost
    if ($proxy -match '^\d+$') {
        $proxy = "http://localhost:$proxy"
    }

    $env:HTTP_PROXY = $proxy
    $env:HTTPS_PROXY = $proxy
    $env:ALL_PROXY = $proxy
    $env:http_proxy = $proxy
    $env:https_proxy = $proxy
    $env:all_proxy = $proxy
}

function Remove-ProxyEnvironments {
    $env:HTTP_PROXY = $null
    $env:HTTPS_PROXY = $null
    $env:ALL_PROXY = $null
    $env:http_proxy = $null
    $env:https_proxy = $null
    $env:all_proxy = $null
}