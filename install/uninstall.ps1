# JD Highlighter uninstaller (Windows)
# Removes the theme agent lines from the .vmoptions and the .jd-highlighter dir.
# Manual: powershell -ExecutionPolicy Bypass -File uninstall.ps1 [-JdDir "C:\path\to\JDownloader"]
param([string]$JdDir = "")
$ErrorActionPreference = "Stop"

function Hold { try { if ($Host.UI.RawUI) { Read-Host "`nPress Enter to close" | Out-Null } } catch {} }
function Write-TextFileNoBom([string]$path, [string]$content) {
  [System.IO.File]::WriteAllText($path, $content, (New-Object System.Text.UTF8Encoding($false)))
}

# Auto-detect the JDownloader folder (the one that contains 'cfg').
if (-not $JdDir) {
  $cands = @(
    "C:\Program Files\JDownloader",
    "C:\Program Files\JDownloader 2.0",
    "C:\Program Files (x86)\JDownloader",
    "C:\Program Files (x86)\JDownloader 2.0",
    "$env:LOCALAPPDATA\JDownloader",
    "$env:LOCALAPPDATA\JDownloader 2.0",
    "$env:APPDATA\JDownloader",
    "$env:APPDATA\JDownloader 2.0",
    "$env:USERPROFILE\JDownloader",
    "$env:USERPROFILE\JDownloader 2.0"
  )
  foreach ($c in $cands) { if ($c -and (Test-Path (Join-Path $c "cfg"))) { $JdDir = $c; break } }
}

while (-not $JdDir -or -not (Test-Path (Join-Path $JdDir "cfg"))) {
  Write-Host "Could not auto-detect JDownloader."
  $JdDir = Read-Host "Enter your JDownloader folder (the one that contains 'cfg'), or leave empty to cancel"
  if (-not $JdDir) { Write-Host "Cancelled - nothing changed."; Hold; exit 1 }
}

# Strips the agent lines and any -include-options redirect from the vmoptions.
$vmo = Join-Path $JdDir "JDownloader2.vmoptions"
if (Test-Path $vmo) {
  $kept = Get-Content $vmo | Where-Object {
    $_ -notmatch 'jd-highlighter-agent\.jar' -and $_ -notmatch 'jd\.highlighter\.(home|variant)' -and $_ -notmatch 'jd-highlighter\.vmoptions'
  }
  Write-TextFileNoBom $vmo (($kept -join "`n") + "`n")
  Write-Host "Removed the JD Highlighter agent lines from $vmo"
}

# The agent keeps light copies of a few JD icons in JD's own iconset, where a light theme
# cannot show them. Only files that still match the shipped copies go.
$hlRoot = Join-Path $JdDir ".jd-highlighter"
$img = Join-Path $JdDir "themes\flat\org\jdownloader\images"
foreach ($n in "tree_plus.svg", "tree_minus.svg", "exttable\lockColumn.svg", "exttable\widthLocked.svg") {
  $mine = Join-Path $hlRoot "icons\$n"
  $theirs = Join-Path $img $n
  if ((Test-Path $mine) -and (Test-Path $theirs) -and
      (Get-FileHash $mine).Hash -eq (Get-FileHash $theirs).Hash) { Remove-Item -Force $theirs }
}

# The theme dir holds the rendered .properties, the agent jar, the icons and the accent.
if (Test-Path $hlRoot) {
  Remove-Item -Recurse -Force $hlRoot
  Write-Host "Removed $hlRoot"
}

Write-Host "Done. Your Look & Feel is still FLATLAF_DARK; the theme JSON stays in cfg\laf\."
Write-Host "Pick a different theme in Settings > GUI > Look & Feel and restart if you want to fully revert."
Hold
