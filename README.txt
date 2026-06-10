=====================================================
  DRIFT CLOCK
  Ambient fluid clock screensaver for Windows
=====================================================

A full-screen clock with a slowly flowing, aurora-like
background. Five color themes. Exits on mouse move or
key press, like any normal screensaver.

REQUIREMENTS
------------
- Windows 10 or 11
- Microsoft Edge (preinstalled on both - no download needed)

INSTALL (2 minutes)
-------------------
1. Extract this ENTIRE zip to a folder (don't run from
   inside the zip).
2. Double-click  install.bat
3. Click "Yes" when Windows asks for permission.
4. Type a number to pick your theme:
      1. Aurora       - teal / periwinkle / violet on navy
      2. Twilight     - violet / magenta / warm coral
      3. Sunset       - dusty coral / rose / amber
      4. Deep Space   - magenta / purple on near-black
      5. Midnight     - calm desaturated blues
5. The Screen Saver Settings window opens automatically.
   Select "DriftClock" from the dropdown, set your wait
   time (e.g. 5 minutes), click OK.

That's it. Click "Preview" in that window to see it now.

CHANGE THEME LATER
------------------
Double-click  change-theme.bat  any time. No admin needed.

EXIT THE SCREENSAVER
--------------------
Move your mouse or press any key.

IF WINDOWS SMARTSCREEN WARNS YOU
--------------------------------
SmartScreen flags any script downloaded from the internet.
Click "More info" then "Run anyway". Both install.bat and
install.ps1 are plain text - open them in Notepad and read
exactly what they do before running. Nothing is downloaded
from the internet during install.

UNINSTALL
---------
1. Delete  C:\Windows\System32\DriftClock.scr  (needs admin)
2. Delete the folder  %LOCALAPPDATA%\DriftClock

TROUBLESHOOTING
---------------
- "Running scripts is disabled": use install.bat, not the
  .ps1 directly - it handles this automatically.
- Black screen on preview: wait 3-4 seconds; Edge takes a
  moment to start the first time.
- Clock doesn't exit on mouse move: re-run install.bat to
  rebuild the launcher.

CREDITS & LICENSE
-----------------
Clock typeface: "Mattone" by Nunzio Mazzaferro, published
by Collletttivo (collletttivo.it). Licensed under the SIL
Open Font License 1.1 - see FONT-LICENSE.txt.

The screensaver code (HTML/WebGL/PowerShell/C#) is released
into the public domain. Use it, modify it, share it.
