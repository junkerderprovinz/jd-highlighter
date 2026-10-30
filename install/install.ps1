# JD Highlighter installer (Windows)
# Recommended: double-click install.bat. Or right-click this file > Run with PowerShell.
# Manual:      powershell -ExecutionPolicy Bypass -File install.ps1 [-JdDir "C:\path\to\JDownloader"] [-Accent "#ffee00"]
param([string]$JdDir = "", [string]$Accent = "")
$ErrorActionPreference = "Stop"

function Hold { try { if ($Host.UI.RawUI) { Read-Host "`nPress Enter to close" | Out-Null } } catch {} }

# Write UTF-8 without a BOM (install4j .vmoptions and FlatLaf .properties must not carry one).
function Write-TextFileNoBom([string]$path, [string]$content) {
  [System.IO.File]::WriteAllText($path, $content, (New-Object System.Text.UTF8Encoding($false)))
}
function Convert-SrgbLin([double]$c) {
  $c = $c / 255.0
  if ($c -le 0.03928) { return $c / 12.92 }
  return [Math]::Pow(($c + 0.055) / 1.055, 2.4)
}
# Auto-contrast: light accent (relative luminance >= 0.5) -> dark fg, else light fg.
function Get-AccentFg([string]$hex) {
  $h = $hex.TrimStart('#').ToLower()
  if ($h.Length -lt 6) { return "#f4f4f4" }
  $r = [Convert]::ToInt32($h.Substring(0,2),16)
  $g = [Convert]::ToInt32($h.Substring(2,2),16)
  $b = [Convert]::ToInt32($h.Substring(4,2),16)
  $L = 0.2126*(Convert-SrgbLin $r) + 0.7152*(Convert-SrgbLin $g) + 0.0722*(Convert-SrgbLin $b)
  if ($L -ge 0.5) { return "#161616" } else { return "#f4f4f4" }
}
# @@ACCENT_HEX@@ and @@ACCENT_FG_HEX@@ are the bare rrggbb that JD's colour JSON needs.
function Render-Properties([string]$tmpl, [string]$accent, [string]$out) {
  if (-not $accent.StartsWith('#')) { $accent = "#$accent" }
  $fg = Get-AccentFg $accent
  $text = (Get-Content $tmpl -Raw) `
    -replace '@@ACCENT_HEX@@', $accent.TrimStart('#') -replace '@@ACCENT_FG_HEX@@', $fg.TrimStart('#') `
    -replace '@@ACCENT@@', $accent -replace '@@ACCENT_FG@@', $fg
  Write-TextFileNoBom $out $text
}

$here = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$src  = Join-Path $here "theme\cfg\laf\FlatDarkLaf.json"
if (-not (Test-Path $src)) {
  Write-Host "ERROR: $src not found. Run this from the unzipped release folder."
  Hold; exit 1
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

# Interactive fallback, so a missing folder never fails silently.
while (-not $JdDir -or -not (Test-Path (Join-Path $JdDir "cfg"))) {
  Write-Host "Could not auto-detect JDownloader."
  $JdDir = Read-Host "Enter your JDownloader folder (the one that contains 'cfg'), or leave empty to cancel"
  if (-not $JdDir) { Write-Host "Cancelled - nothing changed."; Hold; exit 1 }
}

if (-not $Accent) { if ($env:JD_HL_ACCENT) { $Accent = $env:JD_HL_ACCENT } else { $Accent = "#ffee00" } }
if (-not $Accent.StartsWith('#')) { $Accent = "#$Accent" }

$lafDir = Join-Path $JdDir "cfg\laf"
New-Item -ItemType Directory -Force -Path $lafDir | Out-Null
Render-Properties $src $Accent (Join-Path $lafDir "FlatDarkLaf.json")
Write-Host "Wrote FlatDarkLaf.json (accent=$Accent) -> $lafDir"

$gui = Join-Path $JdDir "cfg\org.jdownloader.settings.GraphicalUserInterfaceSettings.json"
# A PSCustomObject rather than -AsHashtable, so Windows PowerShell 5.1 (the default on
# Windows) gets the same result as pwsh.
$d = $null
if (Test-Path $gui) { try { $d = Get-Content $gui -Raw | ConvertFrom-Json } catch { $d = $null } }
if ($null -eq $d) { $d = New-Object PSObject }
$settings = [ordered]@{ lookandfeeltheme = "FLATLAF_DARK" }
# JD's own advertising: the premium banner also squeezes the download graph.
foreach ($k in "bannerenabled", "statusbaraddpremiumbuttonvisible",
               "premiumalertspeedcolumnenabled", "premiumalerttaskcolumnenabled",
               "premiumalertetacolumnenabled", "premiumdisabledwarningflashenabled",
               "specialdealsenabled", "specialdealoboomdialogvisibleonstartup") {
  $settings[$k] = $false
}
foreach ($k in $settings.Keys) { $d | Add-Member -NotePropertyName $k -NotePropertyValue $settings[$k] -Force }
Write-TextFileNoBom $gui ($d | ConvertTo-Json -Depth 10)
Write-Host "Set lookandfeeltheme=FLATLAF_DARK and turned off JD's ads"

$hlRoot = Join-Path $JdDir ".jd-highlighter"
$hlDir  = Join-Path $hlRoot "flatlaf-defaults"
New-Item -ItemType Directory -Force -Path $hlDir | Out-Null
Render-Properties (Join-Path $here "theme\flatlaf\FlatDarkLaf.properties.tmpl") $Accent (Join-Path $hlDir "FlatDarkLaf.properties")
Write-TextFileNoBom (Join-Path $hlRoot "accent") ("{0}`n" -f $Accent)
Write-Host "Rendered FlatDarkLaf.properties (accent=$Accent) -> $hlDir"

foreach ($set in "icons", "jd-tabler") {
  $dst = Join-Path $hlRoot $set
  if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
  Copy-Item -Recurse (Join-Path $here "theme\$set") $dst
}
Write-Host "Copied the icon sets -> $hlRoot"

# The release zip carries the jar built in CI; without it the colours still apply.
$agentSrc = Join-Path $here "agent\jd-highlighter-agent.jar"
$agent    = Join-Path $hlRoot "jd-highlighter-agent.jar"
if (Test-Path $agentSrc) {
  Copy-Item $agentSrc $agent -Force
  Write-Host "Installed jd-highlighter-agent.jar -> $hlRoot"
} else {
  Write-Host "NOTE: $agentSrc not found (the release jar is built in CI)."
  Write-Host "      The .vmoptions lines still point at $agent for when the jar is there."
}

# install4j reads JDownloader2.vmoptions next to the launcher. Old JD Highlighter lines
# are dropped first, so running the installer again leaves exactly one pair.
$homeLine  = "-Djd.highlighter.home=$hlRoot"
$agentLine = "-javaagent:$agent"
$vmo = Join-Path $JdDir "JDownloader2.vmoptions"
try {
  $kept = @()
  if (Test-Path $vmo) {
    $kept = @(Get-Content $vmo | Where-Object {
      $_ -notmatch 'jd-highlighter-agent\.jar' -and $_ -notmatch 'jd\.highlighter\.home' -and $_ -notmatch 'jd-highlighter\.vmoptions'
    })
  }
  $kept += $homeLine, $agentLine
  Write-TextFileNoBom $vmo (($kept -join "`n") + "`n")
  Write-Host "Wired the theme agent -> $vmo"
} catch {
  $userVmo = Join-Path $hlRoot "jd-highlighter.vmoptions"
  Write-TextFileNoBom $userVmo "$homeLine`n$agentLine`n"
  Write-Host "NOTE: could not edit $vmo ($($_.Exception.Message))."
  Write-Host "      Wrote $userVmo. Add this line to your JDownloader .vmoptions:"
  Write-Host "        -include-options $userVmo"
  Write-Host "      Or, as a last resort that survives every JD relaunch:"
  Write-Host "        setx JAVA_TOOL_OPTIONS `"$homeLine $agentLine`""
}

Write-Host "Done. Restart JDownloader."
Hold
