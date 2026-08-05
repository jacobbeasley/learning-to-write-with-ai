Add-Type -AssemblyName System.Drawing

$files = Get-ChildItem -Path "game/prose-quest/assets/images/map_icons/*.png"
foreach ($f in $files) {
    $tempPath = $f.FullName + ".tmp.png"
    $bmp = [System.Drawing.Bitmap]::FromFile($f.FullName)
    $clean = New-Object System.Drawing.Bitmap($bmp)
    $bmp.Dispose()
    $clean.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $clean.Dispose()
    
    Remove-Item -Path $f.FullName -Force
    Move-Item -Path $tempPath -Destination $f.FullName -Force
    Write-Host "Cleaned PNG metadata for: $($f.Name)"
}

# Also delete any stale .import files so Godot imports fresh clean PNGs
Get-ChildItem -Path "game/prose-quest/assets/images/map_icons/*.import" -ErrorAction SilentlyContinue | Remove-Item -Force
Get-ChildItem -Path "game/prose-quest/.godot/imported/*" -Include "*campsite*", "*kindling*", "*flint*", "*shavings*" -ErrorAction SilentlyContinue | Remove-Item -Force

Write-Host "Clean PNG re-encoding complete!"
