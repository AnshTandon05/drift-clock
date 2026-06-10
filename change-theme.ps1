# Drift Clock - theme switcher (no admin needed)
$themesDir = "$env:LOCALAPPDATA\DriftClock\themes"
$htmlFile  = "$env:LOCALAPPDATA\DriftClock\clock.html"

if (!(Test-Path $themesDir)) {
    Write-Host "  Drift Clock is not installed yet. Run install.bat first." -ForegroundColor Red
    pause; exit 1
}

$themes = Get-ChildItem $themesDir -Filter *.html | Sort-Object Name
Write-Host ""
Write-Host "  Pick your theme:" -ForegroundColor Cyan
for ($i = 0; $i -lt $themes.Count; $i++) {
    $label = $themes[$i].BaseName -replace '^\d+-','' -replace '-',' '
    Write-Host ("    {0}. {1}" -f ($i+1), (Get-Culture).TextInfo.ToTitleCase($label))
}
Write-Host ""
$choice = Read-Host "  Enter number"
if (-not ($choice -match '^\d+$') -or [int]$choice -lt 1 -or [int]$choice -gt $themes.Count) {
    Write-Host "  Invalid choice, nothing changed." -ForegroundColor Yellow
    pause; exit 0
}
Copy-Item $themes[[int]$choice - 1].FullName $htmlFile -Force
Write-Host ("  Theme changed to: " + $themes[[int]$choice - 1].BaseName) -ForegroundColor Green
pause
