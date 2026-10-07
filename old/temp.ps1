

    }

    # Check om filen er kopieret til externt drev proof of concept
    $files = Get-ChildItem -Path $extern_drev -File # alle file i directory
    
    ForEach ($file in $files) {
        $temp_path = Join-Path -Path $extern_drev -ChildPath $file
	    # Add-Content -Path $monitor_log -Value "$temp_path - new path"
        $new_hash = (Get-FileHash $temp_path).Hash

        if ($new_hash -eq $backup_hash) {
            Add-Content -Path $monitor_log -Value "$time Filen kopieret til eksternt drev"
	        # Add-Content -Path $monitor_log -Value "$new_hash - new hash"
            # en eller anden alarm. lige nu vil den også blive ved med at logge den samme besked hver 5 sekund
            # istedet for at logge kan vi køre en task
            # Start-ScheduledTask -TaskName "ServiceDemo-Alert"
        }
	else {
		# Add-Content -Path $monitor_log -Value "$file - file"
		# Add-Content -Path $monitor_log -Value "$new_hash - new hash"
	}
    }

    Start-Sleep -Seconds 5  # det her er ikke en god løsning, men den virker
}
Add-Content -Path $logFile -Value "Service stopped"

Complete-ServiceStop   # keep this as the last line
