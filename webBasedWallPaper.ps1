# Load Configuration
$configPath = Join-Path $PSScriptRoot "config.json"
if (-not (Test-Path $configPath)) {
    Write-Error "Configuration file 'config.json' not found."
    exit 1
}
$config = Get-Content $configPath -Raw | ConvertFrom-Json

# Fetch TODO JSON from API
try {
    $headers = @{ "X-API-KEY" = $config.apiKey }
    $todoList = Invoke-RestMethod -Uri $config.apiUrl -Headers $headers -ErrorAction Stop
}
catch {
    Write-Warning "Could not connect to API or Invalid API Key. Proceeding with empty list."
    $todoList = @()
}

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

# Resolution & Scaling Logic (Baseline: 1080p)
$screenHeight = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Height
$baseHeight = 1080.0
$scaleFactor = $screenHeight / $baseHeight

# Apply Scaling
$scaledFontSize = $config.layout.fontSize * $scaleFactor
$scaledStartX = $config.layout.textX * $scaleFactor # Assuming X coordinate also needs scaling relative to aspect ratio, or keep absolute if right-aligned
# Note: If textX is large (1215), it's likely absolute pixels. For robust scaling on different aspect ratios, right-alignment calc is better.
# But for now, we scale proportional to height to maintain size-relative-to-screen.
$scaledStartX = $config.layout.textX * ([System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Width / 1920.0)

$scaledStartY = $config.layout.startY * $scaleFactor
$scaledLineHeight = $config.layout.lineHeight * $scaleFactor
$scaledShadow = $config.layout.shadowOffsetXY * $scaleFactor

# Define Paths
$inputImage = Join-Path $PSScriptRoot $config.paths.templateInput
$outputImage = Join-Path $PSScriptRoot $config.paths.wallpaperOutput

if (-Not (Test-Path $inputImage)) {
    Write-Error "Template image not found at $inputImage"
    exit 1
}

# Graphics Logic
# Note: We are drawing ON the template. If the template is 1920x1080, we should load it.
# However, if the screen is 4K, setting a 1080p wallpaper will stretch. 
# ideally we resize the template to screen res, OR we just draw on the template and let Windows stretch it.
# Given the task "Multi-Monitor / Resolution Support", we should ideally resize the canvas.
# For simplicity and perf, we will rely on Windows fitting the image, but we scale the text placement so it looks correct RELATIVE to the image features if the image was also scaled.
# WAIT. If we draw on a 1080p image, we shouldn't scale the text coordinates based on SCREEN resolution, we should use the native 1080p coords.
# Scaling makes sense ONLY if we are generating a wallpaper matching the screen resolution.
# Let's create a NEW bitmap matching the screen resolution, draw the template resized onto it, then draw text.

$templateBmp = [System.Drawing.Image]::FromFile($inputImage)
$finalBmp = New-Object System.Drawing.Bitmap([System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Width, [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Height)
$graphics = [System.Drawing.Graphics]::FromImage($finalBmp)

# Draw resized template
$graphics.DrawImage($templateBmp, 0, 0, $finalBmp.Width, $finalBmp.Height)

$font = New-Object System.Drawing.Font($config.layout.fontFamily, $scaledFontSize)
$y = $scaledStartY
$shadowBrush = [System.Drawing.Brushes]::($config.colors.shadow)

foreach ($item in $todoList) {
    if ($item.priority -eq "high") {
        $brush = [System.Drawing.Brushes]::($config.colors.highPriority)
    } else {
        $brush = [System.Drawing.Brushes]::($config.colors.normalPriority)
    }
    
    # Draw Shadow
    $graphics.DrawString($item.task, $font, $shadowBrush, ($scaledStartX + $scaledShadow), ($y - $scaledShadow))
    # Draw Text
    $graphics.DrawString($item.task, $font, $brush, $scaledStartX, $y)
    
    $y += $scaledLineHeight
}

$graphics.Dispose()
$templateBmp.Dispose()
$finalBmp.Save($outputImage, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$finalBmp.Dispose()

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
    Write-Host "Wallpaper updated successfully (Scaled to $($finalBmp.Width)x$($finalBmp.Height))."
}
catch {
    Write-Error "Failed to set wallpaper."
}