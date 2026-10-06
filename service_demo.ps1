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

#todo: skift til pascalcase
#



$target_file = "C:\Users\John Doe\Desktop\Man_2\honeypot.txt"
$backup_file = "C:\Users\John Doe\Desktop\Man_2\Honeypot_Backup\honeypot_backup.txt"
$monitor_log = "C:\Users\John Doe\Desktop\Man_2\monitor.log"

$extern_drev = "C:\Users\John Doe\Desktop\Man_2\monitor.log"

while (Test-ServiceRunning) {
    # Opret datovariabel
    $time = Get-Date

    # Kontroller om målfilen eksisterer
    if (Test-Path $target_file) {

        # Beregn hash af den aktuelle fil
        $current_hash = (Get-FileHash $target_file).Hash
        $backup_hash = (Get-FileHash $backup_file).hash   #todo: hvis vi gemmer backup-hashen behøver vi ikke beregne den hvert 5. sekund

        # Sammenlign med backup-hash
        if ($current_hash -eq $backup_hash) {
            Add-Content -Path $monitor_log -Value "$time Filen findes og hash matcher"
        }
        else {
            Add-Content -Path $monitor_log -Value "$time Filen findes, men hash matcher ikke"
            Add-Content -Path $monitor_log -Value $current_hash
            Copy-Item $backup_file $target_file -Force
        }
    }
    else {
        Add-Content -Path $monitor_log -Value "$time Filen er slettet - filen genskabes!"
        Copy-Item $backup_file $target_file -Force
    }

    # Check om filen er kopieret til externt drev proof of concept

    $Files = Get-ChildItem -Path $extern_drev -File
    
    # Loop through Files
    ForEach ($File in $Files) {
        $new_hash = (Get-FileHash $File).Hash
        if ($new_hash -eq $backup_hash) {
            Add-Content -Path $monitor_log -Value "$time Filener kopieret til eksternt drev"
            # en eller anden alarm
        }
    }

    Start-Sleep -Seconds 5
}
Add-Content -Path $logFile -Value "Service stopped"

Complete-ServiceStop   # keep this as the last line
