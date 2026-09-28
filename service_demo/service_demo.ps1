# ============================================================================
#  SETUP - you do not need to change anything in this section.
#
#  Windows only accepts a program as a service if it answers the Service
#  Control Manager when it is started and stopped. PowerShell can't do that
#  by itself, so this small piece of C# does it for us in the background.
# ============================================================================
Add-Type -ReferencedAssemblies System.ServiceProcess -TypeDefinition @'
using System.ServiceProcess;
using System.Threading;

public class PSService : ServiceBase {
    public static ManualResetEvent StopRequested = new ManualResetEvent(false);
    public static ManualResetEvent Finished      = new ManualResetEvent(false);

    protected override void OnStop() {
        StopRequested.Set();       // tell the PowerShell loop to stop
        Finished.WaitOne(20000);   // give it up to 20 seconds to finish
    }

    public static void RunInBackground() {
        var t = new Thread(() => ServiceBase.Run(new PSService()));
        t.IsBackground = true;
        t.Start();
    }
}
'@
[PSService]::RunInBackground()

# Returns $true until someone stops the service.
function Test-ServiceRunning {
    return -not [PSService]::StopRequested.WaitOne(0)
}

# Tells Windows that the script has finished stopping.
function Complete-ServiceStop {
    [PSService]::Finished.Set() | Out-Null
}

# ============================================================================
#  YOUR CODE - this is the part you change.
# ============================================================================

# CHANGE THESE VALUES (MUST MATCH install.ps1)
# (Optionally, make a config file and read from it...)
$serviceName = "ServiceDemo"
$installFolder = "C:\Program Files\$serviceName"
$logFile = "$installFolder\service.log"

Add-Content -Path $logFile -Value "Service started"

while (Test-ServiceRunning) {
    $time = Get-Date
    Add-Content -Path $logFile -Value "$time - the service is running"
    Start-Sleep -Seconds 5
}

Add-Content -Path $logFile -Value "Service stopped"

Complete-ServiceStop   # keep this as the last line
