# Drift Clock - ambient screensaver installer for Windows 10/11
# This script: copies theme files, lets you pick a theme, builds a tiny
# launcher, and installs it as a Windows screensaver.

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "  Drift Clock Installer" -ForegroundColor Cyan
Write-Host "  ======================" -ForegroundColor DarkGray
Write-Host ""

$installDir = "$env:LOCALAPPDATA\DriftClock"
$themesDir  = "$installDir\themes"
$htmlFile   = "$installDir\clock.html"
$scrTarget  = "$env:SystemRoot\System32\DriftClock.scr"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$srcThemes = Join-Path $scriptDir "themes"
if (!(Test-Path $srcThemes)) {
    Write-Host "  ERROR: 'themes' folder not found next to this script." -ForegroundColor Red
    Write-Host "  Make sure you extracted the FULL zip before running." -ForegroundColor Yellow
    pause; exit 1
}

if (!(Test-Path $themesDir)) { New-Item -ItemType Directory -Path $themesDir -Force | Out-Null }
Copy-Item "$srcThemes\*.html" $themesDir -Force
Write-Host "  [1/4] Copied themes" -ForegroundColor Green

# --- Theme picker ---
$themes = Get-ChildItem $themesDir -Filter *.html | Sort-Object Name
Write-Host ""
Write-Host "  Pick your theme:" -ForegroundColor Cyan
for ($i = 0; $i -lt $themes.Count; $i++) {
    $label = $themes[$i].BaseName -replace '^\d+-','' -replace '-',' '
    Write-Host ("    {0}. {1}" -f ($i+1), (Get-Culture).TextInfo.ToTitleCase($label))
}
Write-Host ""
$choice = Read-Host "  Enter number (default 1)"
if (-not ($choice -match '^\d+$') -or [int]$choice -lt 1 -or [int]$choice -gt $themes.Count) { $choice = 1 }
Copy-Item $themes[[int]$choice - 1].FullName $htmlFile -Force
Write-Host ("  [2/4] Theme set: " + $themes[[int]$choice - 1].BaseName) -ForegroundColor Green

# --- Launcher (C# 5 compatible). Starts Edge in kiosk mode pointing at the
# clock, then watches for mouse/keyboard input and closes it, like a real
# screensaver. Full source is visible below - nothing hidden. ---
$csharpSource = @'
using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

class DriftScr {

    [StructLayout(LayoutKind.Sequential)]
    public struct POINT { public int X; public int Y; }

    [DllImport("user32.dll")]
    static extern bool GetCursorPos(out POINT p);

    [DllImport("user32.dll")]
    static extern short GetAsyncKeyState(int vKey);

    static string ProfileDir() {
        return Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "DriftClock", "edge-profile");
    }

    static void KillKiosk() {
        string ps = "Get-CimInstance Win32_Process -Filter \"Name='msedge.exe'\" | " +
            "Where-Object { $_.CommandLine -like '*DriftClock*edge-profile*' } | " +
            "ForEach-Object { Stop-Process -Id $_.ProcessId -Force }";
        var k = new ProcessStartInfo {
            FileName = "powershell.exe",
            Arguments = "-NoProfile -WindowStyle Hidden -Command \"" + ps.Replace("\"", "\\\"") + "\"",
            UseShellExecute = false,
            CreateNoWindow = true
        };
        Process.Start(k).WaitForExit(5000);
    }

    [STAThread]
    static void Main(string[] args) {
        string mode = args.Length > 0 ? args[0].ToLower() : "/s";
        if (mode.StartsWith("/c") || mode.StartsWith("-c")) {
            MessageBox.Show("Drift Clock Screensaver\nTo change themes, run change-theme.bat from the download folder.",
                "Drift Clock", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }
        if (mode.StartsWith("/p") || mode.StartsWith("-p")) return;

        string html = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "DriftClock", "clock.html");

        var psi = new ProcessStartInfo {
            FileName = "cmd.exe",
            Arguments = "/c start /max msedge --kiosk \"" + html + "\"" +
                " --edge-kiosk-type=fullscreen --no-first-run" +
                " --user-data-dir=\"" + ProfileDir() + "\"" +
                " --disable-features=TranslateUI,msEdgeWelcomePage",
            UseShellExecute = false,
            CreateNoWindow = true
        };
        Process.Start(psi);

        Thread.Sleep(4000);

        POINT start;
        GetCursorPos(out start);

        while (true) {
            Thread.Sleep(150);

            POINT p;
            GetCursorPos(out p);
            bool moved = Math.Abs(p.X - start.X) > 25 || Math.Abs(p.Y - start.Y) > 25;

            bool key = false;
            for (int vk = 1; vk <= 222; vk++) {
                if ((GetAsyncKeyState(vk) & 0x8000) != 0) { key = true; break; }
            }

            if (moved || key) {
                KillKiosk();
                Environment.Exit(0);
            }
        }
    }
}
'@

$csFile  = "$installDir\DriftClock.cs"
$exeFile = "$installDir\DriftClock.exe"
Set-Content -Path $csFile -Value $csharpSource -Encoding UTF8

$cscPath = "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if (!(Test-Path $cscPath)) { $cscPath = "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\csc.exe" }
if (!(Test-Path $cscPath)) {
    Write-Host "  ERROR: .NET Framework 4.x compiler not found (preinstalled on Win10/11)." -ForegroundColor Red
    pause; exit 1
}

$compileResult = & $cscPath /nologo /target:winexe /out:"$exeFile" /reference:System.Windows.Forms.dll "$csFile" 2>&1
if (!(Test-Path $exeFile)) {
    Write-Host "  ERROR: Compilation failed." -ForegroundColor Red
    Write-Host $compileResult
    pause; exit 1
}
Write-Host "  [3/4] Built screensaver launcher" -ForegroundColor Green

try {
    Copy-Item $exeFile $scrTarget -Force
} catch {
    Write-Host "  ERROR: Could not write to System32. Run install.bat (it requests admin)." -ForegroundColor Red
    pause; exit 1
}
Write-Host "  [4/4] Installed DriftClock.scr" -ForegroundColor Green

Write-Host ""
Write-Host "  Done! Opening screensaver settings..." -ForegroundColor Cyan
Start-Process "rundll32.exe" "shell32.dll,Control_RunDLL desk.cpl,,1"
Write-Host "  Select 'DriftClock' from the dropdown, set your wait time, click OK." -ForegroundColor Yellow
Write-Host ""
pause
