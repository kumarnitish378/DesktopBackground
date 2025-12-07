# Fetch TODO JSON from API
$todoList = Invoke-RestMethod -Uri "https://nitish378.pythonanywhere.com/todos"

Add-Type -AssemblyName System.Drawing

$imageUrl = "https://nitish378.pythonanywhere.com/template.jpg"
$inputImage = "template.png"

if (-Not (Test-Path $inputImage)) {
    Invoke-WebRequest -Uri $imageUrl -OutFile $inputImage
}

$outputImage = "$(Get-Location)\templateEdit.png"

$bitmap = [System.Drawing.Image]::FromFile($inputImage)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$font = New-Object System.Drawing.Font("Cooper Hewitt", 48)
$y = 140


$shadowBrush = [System.Drawing.Brushes]::Gray

foreach ($item in $todoList) {
    if ($item.priority -eq "high") {
        $brush = [System.Drawing.Brushes]::Red
    } else {
        $brush = [System.Drawing.Brushes]::Black
    }
    # $point = New-Object System.Drawing.PointF($x, $y)
    $graphics.DrawString($item.task, $font, $shadowBrush, 1217, ($y - 5))
    $graphics.DrawString($item.task, $font, $brush, 1215, $y)
    $y += 145
}

$graphics.Dispose()
$bitmap.Save($outputImage, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$bitmap.Dispose()

# Set wallpaper code here...
Add-Type @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
[Wallpaper]::SystemParametersInfo(20, 0, $outputImage, 3)