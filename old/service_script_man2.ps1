
$file_path
$hash
$backup_path

If (Test-Path $path): # checker at filen findes
    $new_hash = Get-FileHash $file_path # skal check om den kun giver hashen eller der følger andet med 
    if $new_hash -eq $hash:
        exit
Copy-Item $backup_path -Destination $filepath #overskriver som default
    


# tror ikke vi skal bruge en task, men nøjes med service, da det hele skal køre silent.


# mangler alt indhoold fra service_demo, men vil teste det seperat først.