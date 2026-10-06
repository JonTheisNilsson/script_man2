#Requires -RunAsAdministrator
# Stops and removes the service created by install.ps1.

# CHANGE THIS TO THE NAME OF YOUR SERVICE (MUST MATCH install.ps1)
$serviceName = "service_script_man2"


# -----------------------------------------------------------------
# ---- The code below is not necessary to modify (but you can) ----
# -----------------------------------------------------------------

if (-not (Get-Service -Name $serviceName -ErrorAction SilentlyContinue)) {
    Write-Host "$serviceName is not installed."
    return
}

Stop-Service -Name $serviceName
sc.exe delete $serviceName   # in PowerShell 7+ you can use: Remove-Service -Name $serviceName

# (Optionally add removal of installed files, not just the service registration)
Write-Host "$serviceName removed. No data removed (logs, etc.)."
