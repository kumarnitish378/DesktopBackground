Add-Type -AssemblyName System.Drawing

# Paths
$inputImage = "C:\Users\nitis\OneDrive\Desktop\DesktopBackground\2.png"
$outputImage = "C:\Users\nitis\OneDrive\Desktop\DesktopBackground\2_edit.png"

# Load image
$bitmap = [System.Drawing.Image]::FromFile($inputImage)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)

# Text settings
$text = "GPS Jammer"
$font = New-Object System.Drawing.Font("Cooper Hewitt", 48, [System.Drawing.FontStyle]::Bold)
# $brush = [System.Drawing.Brushes]::FromArgb(255, 255, 255, 0) # Yellow color
$brush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 153))  # Purple


# Calculate center
$size = $graphics.MeasureString($text, $font)
# $x = ($bitmap.Width - $size.Width) / 2
# $y = ($bitmap.Height - $size.Height) / 2
$x = 1215 # Adjust X position
$y = 140 # Adjust Y position
$point = New-Object System.Drawing.PointF($x, $y)

# Draw text
$graphics.DrawString($text, $font, $brush, $point)
$graphics.Dispose()

# Save image
$bitmap.Save($outputImage, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$bitmap.Dispose()

# Set as wallpaper
Add-Type @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
[Wallpaper]::SystemParametersInfo(20, 0, $outputImage, 3)
