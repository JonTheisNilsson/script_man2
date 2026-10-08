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

# give path til det directory scriptet er i. check om det virker som forventet med services
$script_path = (Split-Path -Parent $MyInvocation.MyCommand.Path) 

# hvis $MyInvocation ikke virker, kan vi måske bruge $installFolder
$target_file = Join-Path -Path $script_path -ChildPath "honeypot.txt"
$backup_file = Join-Path -Path $script_path -ChildPath "honeypot_backup.txt"
$monitor_log = Join-Path -Path $script_path -ChildPath "monitor.log"
$extern_drev = Join-Path -Path $script_path -ChildPath "extern"

$backup_hash = (Get-FileHash $backup_file).hash  
# kan eventuelt skiftes ud med hardcoded hash, eller hentes fra config
# 1CD28021AA2A4360BCA501B72B3EC2A4F8B2276147E22B3A022E223A5CEEA254

while (Test-ServiceRunning) {
    # Opret datovariabel
    $time = Get-Date

    # Kontroller om målfilen eksisterer
    if (Test-Path $target_file) {
        # Beregn hash af den aktuelle fil
        $current_hash = (Get-FileHash $target_file).Hash
        
        # Sammenlign med backup-hash
        if ($current_hash -eq $backup_hash) {
            Add-Content -Path $monitor_log -Value "$time Filen findes og hash matcher"
        }
        else {
            Add-Content -Path $monitor_log -Value "$time Filen findes, men hash matcher ikke"
            Copy-Item $backup_file $target_file -Force
        }
    }
    else {
        Add-Content -Path $monitor_log -Value "$time Filen er slettet - filen genskabes!"
        Copy-Item $backup_file $target_file -Force
    }

    # Check om filen er kopieret til externt drev - proof of concept
    $files = Get-ChildItem -Path $extern_drev -File # alle file i directory
    
    ForEach ($file in $files) {     
        $temp_path = Join-Path -Path $extern_drev -ChildPath $file
        $new_hash = (Get-FileHash $temp_path).Hash
        if ($new_hash -eq $backup_hash) {
            Add-Content -Path $monitor_log -Value "$time Filen kopieret til eksternt drev"
            # istedet for at logge kan vi køre en task der popper en alert op. Kræver registering i task_scheduler
            # Start-ScheduledTask -TaskName "ServiceDemo-Alert"
        }
    }

    Start-Sleep -Seconds 5  # det her er ikke en god løsning, men den virker
}
Add-Content -Path $logFile -Value "Service stopped"

Complete-ServiceStop   # keep this as the last line
