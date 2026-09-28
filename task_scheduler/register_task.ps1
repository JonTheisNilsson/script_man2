#Requires -RunAsAdministrator
# Registers a scheduled task that has NO trigger. It never runs by itself,
# only when a script starts it with Start-ScheduledTask.
#
# Why use a task? A service runs as SYSTEM in the background and can't show
# anything to the user. This task runs as whoever is logged in, in their
# session, so its window is visible on their screen.

# CHANGE THESE VALUES
$taskName      = "ServiceDemo-Alert"
$scriptName    = "alert.ps1"
$installFolder = "C:\Program Files\ServiceDemo"

# -----------------------------------------------------------------
# ---- The code below is not necessary to modify (but you can) ----
# -----------------------------------------------------------------

New-Item -Path $installFolder -ItemType Directory -Force | Out-Null
Copy-Item -Path "$PSScriptRoot\$scriptName" -Destination $installFolder -Force

# What the task runs.
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$installFolder\$scriptName`""

# Who the task runs as: every logged-in member of the Users group,
# in their own session (so they can see the window).
$principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users" -RunLevel Limited

# No -Trigger, so the task only runs when started from a script.
Register-ScheduledTask -TaskName $taskName -Action $action -Principal $principal -Force | Out-Null

Write-Host "Task '$taskName' registered."
Write-Host "Start it with: Start-ScheduledTask -TaskName $taskName"