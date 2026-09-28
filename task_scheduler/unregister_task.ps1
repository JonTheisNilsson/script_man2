#Requires -RunAsAdministrator
# Removes the task created by register-task.ps1.

# CHANGE THIS (MUST MATCH register-task.ps1)
$taskName = "ServiceDemo-Alert"


# -----------------------------------------------------------------
# ---- The code below is not necessary to modify (but you can) ----
# -----------------------------------------------------------------

if (-not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
    Write-Host "Task '$taskName' is not registered."
    return
}

Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
Write-Host "Task '$taskName' removed."