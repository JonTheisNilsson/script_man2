#Requires -RunAsAdministrator
# Registers service.ps1 as a Windows service and starts it.

# CHANGE THESE 5 VALUES
$serviceName   = "service_script_man2"
$displayName   = "Script mandatory 2"
$scriptName    = "service_script_man2.ps1"
$description   = "Mandatory 2 - Windows service written in PowerShell"
$installFolder = "C:\Program Files\$serviceName"


# -----------------------------------------------------------------
# ---- The code below is not necessary to modify (but you can) ----
# -----------------------------------------------------------------

# Skip installation if service is already installed
if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
    Write-Host "$serviceName is already installed. Run uninstall.ps1 first."
    return
}

try {
	# Copy the service script to a folder that normal users can't edit,
	# because the service runs as SYSTEM (the most powerful account).
	New-Item -Path $installFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null

	# We need to use $PSScriptRoot, which points to the location of install.ps1
	# otherwise this will only work when we have cd'd into the directory.
	Copy-Item -Path "$PSScriptRoot\$scriptName" -Destination $installFolder -Force


	# The command Windows runs when the service starts.
	$command = 'C:\Windows\System32\cmd.exe /c {0}\powershell.exe -NoProfile -ExecutionPolicy Bypass -File "{1}\{2}"' -f $PSHOME, $installFolder, $scriptName
    
	New-Service -Name $serviceName -DisplayName $displayName -Description $description -BinaryPathName $command -StartupType Automatic

	# If the service crashes, restart it after 5 seconds.
    # This will retry 3 times.
	sc.exe failure $serviceName reset= 86400 actions= restart/5000/restart/5000/restart/5000

	Write-Host "Installed."
	Write-Host "Run the following command to start the service:"
    Write-Host ""
    Write-Host "Start-Service -Name $serviceName"
} catch [System.UnauthorizedAccessException] {
	Write-Error "Permission denied. Run this script as Administrator."
	exit 1
}