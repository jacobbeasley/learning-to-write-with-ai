Add-Type -AssemblyName System.Drawing

# Targets only Part 11 and Chapters 35-42 comics & map icons
$targetPattern = "^(part11_|chapter35_|chapter36_|chapter37_|chapter38_|chapter39_|chapter40_|chapter41_|chapter42_|ch_35_|ch_36_|ch_37_|ch_38_|ch_39_|ch_40_|ch_41_|ch_42_)"

$files = Get-ChildItem -Path "game/prose-quest/assets/images" -Recurse -Filter "*.png" | Where-Object { $_.Name -match $targetPattern }

foreach ($f in $files) {
    $tempPath = $f.FullName + ".tmp.png"
    try {
        $bmp = [System.Drawing.Bitmap]::FromFile($f.FullName)
        $clean = New-Object System.Drawing.Bitmap($bmp)
        $bmp.Dispose()
        $clean.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Png)
        $clean.Dispose()
        
        Remove-Item -Path $f.FullName -Force
        Move-Item -Path $tempPath -Destination $f.FullName -Force
        
        # Remove corresponding .import file so Godot re-imports only this file
        $importFile = $f.FullName + ".import"
        if (Test-Path $importFile) {
            Remove-Item -Path $importFile -Force
        }
        
        Write-Host "Cleaned PNG metadata for: $($f.Name)"
    } catch {
        Write-Host "[ERROR] Failed cleaning $($f.Name): $_"
    }
}

Write-Host "Clean PNG re-encoding complete for Part 11 & Chapters 35-42!"
