# Load Configuration
$configPath = Join-Path $PSScriptRoot "config.json"
if (-not (Test-Path $configPath)) {
    Write-Error "Configuration file 'config.json' not found."
    exit 1
}
$config = Get-Content $configPath -Raw | ConvertFrom-Json

# Fetch TODO JSON from API
try {
    $todoList = Invoke-RestMethod -Uri $config.apiUrl -ErrorAction Stop
}
catch {
    Write-Warning "Could not connect to API at $($config.apiUrl). Proceeding with empty list or previous state."
    $todoList = @()
}

Add-Type -AssemblyName System.Drawing

# Define Paths
$inputImage = Join-Path $PSScriptRoot $config.paths.templateInput
$outputImage = Join-Path $PSScriptRoot $config.paths.wallpaperOutput

if (-Not (Test-Path $inputImage)) {
    Write-Error "Template image not found at $inputImage"
    exit 1
}

# Graphics Logic
$bitmap = [System.Drawing.Image]::FromFile($inputImage)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$font = New-Object System.Drawing.Font($config.layout.fontFamily, $config.layout.fontSize)

$y = $config.layout.startY
$shadowOffset = $config.layout.shadowOffsetXY
$shadowBrush = [System.Drawing.Brushes]::($config.colors.shadow)

foreach ($item in $todoList) {
    if ($item.priority -eq "high") {
        $brush = [System.Drawing.Brushes]::($config.colors.highPriority)
    } else {
        $brush = [System.Drawing.Brushes]::($config.colors.normalPriority)
    }
    
    # Draw Shadow
    $graphics.DrawString($item.task, $font, $shadowBrush, ($config.layout.textX + $shadowOffset), ($y - $shadowOffset))
    # Draw Text
    $graphics.DrawString($item.task, $font, $brush, $config.layout.textX, $y)
    
    $y += $config.layout.lineHeight
}

$graphics.Dispose()
$bitmap.Save($outputImage, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$bitmap.Dispose()

# Set Wallpaper
Add-Type @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

try {
    [Wallpaper]::SystemParametersInfo(20, 0, $outputImage, 3)
    Write-Host "Wallpaper updated successfully."
}
catch {
    Write-Error "Failed to set wallpaper."
}