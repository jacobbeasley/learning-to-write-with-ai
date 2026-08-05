Add-Type -AssemblyName System.Drawing

$files = Get-ChildItem -Path "game/prose-quest/assets/images" -Recurse -Filter "*.png"
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
        Write-Host "Cleaned PNG metadata for: $($f.Name)"
    } catch {
        Write-Host "[ERROR] Failed cleaning $($f.Name): $_"
    }
}

# Delete all .import files so Godot re-imports every image freshly
Get-ChildItem -Path "game/prose-quest/assets/images" -Recurse -Filter "*.import" -ErrorAction SilentlyContinue | Remove-Item -Force
Get-ChildItem -Path "game/prose-quest/.godot/imported" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse

Write-Host "Clean PNG re-encoding complete for all asset images!"
