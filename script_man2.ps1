
$file_path
$hash
$backup_path

If (Test-Path $path): # checker at filen findes
    $new_hash = Get-FileHash $file_path 
    if $new_hash -eq $hash:
        exit
Copy-Item $backup_path -Destination $filepath #overskriver som default
    
    