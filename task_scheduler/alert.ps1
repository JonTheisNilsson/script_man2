# Run by the "ServiceDemo-Alert" scheduled task, as the logged-in user.
# Shows a visible window, which the service itself can't do.

# Optional: using the task scheduler is optional and this is just an example

Write-Host "=================================="
Write-Host "  WARNING from ServiceDemo"
Write-Host "  Something happened at $(Get-Date)"
Write-Host "=================================="

Read-Host "Press Enter to close"