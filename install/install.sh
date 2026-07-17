#!/usr/bin/env sh
# JD Highlighter installer (Linux/macOS)
# Usage: install.sh [/path/to/JDownloader] [accent-hex]   (the folder that contains 'cfg')
#   accent-hex: any #rrggbb (default #ffee00). Also settable via JD_HL_ACCENT.
set -eu

HERE="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$HERE/theme/cfg/laf/FlatDarkLaf.json"
[ -f "$SRC" ] || { echo "ERROR: $SRC not found. Run this from the unzipped release folder." >&2; exit 1; }

JD_DIR="${1:-}"
if [ -z "$JD_DIR" ]; then
  for c in \
    "$HOME/.jd2" \
    "$HOME/JDownloader" "$HOME/JDownloader 2.0" \
    "$HOME/Applications/JDownloader 2.0" \
    "/Applications/JDownloader 2.0" \
    "/opt/JDownloader" "/opt/JDownloader 2.0"; do
    if [ -d "$c/cfg" ]; then JD_DIR="$c"; break; fi
  done
fi

# Interactive fallback when a terminal is attached - never fail silently.
if { [ -z "$JD_DIR" ] || [ ! -d "$JD_DIR/cfg" ]; } && [ -t 0 ]; then
  printf "Could not auto-detect JDownloader.\nEnter your JDownloader folder (contains 'cfg'), or leave empty to cancel: "
  read -r JD_DIR
fi

if [ -z "$JD_DIR" ] || [ ! -d "$JD_DIR/cfg" ]; then
  echo "JDownloader cfg dir not found." >&2
  echo "Usage: install.sh /path/to/JDownloader [accent-hex]   (the folder that contains 'cfg')" >&2
  exit 1
fi

mkdir -p "$JD_DIR/cfg/laf"
cp "$SRC" "$JD_DIR/cfg/laf/FlatDarkLaf.json"
echo "Copied FlatDarkLaf.json -> $JD_DIR/cfg/laf/"

GUI="$JD_DIR/cfg/org.jdownloader.settings.GraphicalUserInterfaceSettings.json"
if command -v python3 >/dev/null 2>&1; then
  python3 - "$GUI" <<'PY'
import json, os, sys
p = sys.argv[1]
d = {}
if os.path.exists(p):
    try:
        d = json.load(open(p))
    except Exception:
        d = {}
d["lookandfeeltheme"] = "FLATLAF_DARK"
# Also switch off JDownloader's built-in advertisements so the GUI stays clean and
# the download graph keeps its full height (the "Become premium user" banner
# otherwise squeezes it). Ads only - Donate and functional settings untouched.
for k in ("bannerenabled", "statusbaraddpremiumbuttonvisible",
          "premiumalertspeedcolumnenabled", "premiumalerttaskcolumnenabled",
          "premiumalertetacolumnenabled", "premiumdisabledwarningflashenabled",
          "specialdealsenabled", "specialdealoboomdialogvisibleonstartup"):
    d[k] = False
json.dump(d, open(p, "w"), indent=2)
PY
  echo "Set lookandfeeltheme=FLATLAF_DARK + disabled built-in ads"
else
  echo "NOTE: python3 not found - open JDownloader and pick"
  echo "      Settings > GUI > Look & Feel > FLATLAF_DARK once."
fi

# --- JD Highlighter: render the accented FlatLaf control theme + wire the theme agent ---
. "$HERE/lib/accent.sh"
ACCENT="${2:-${JD_HL_ACCENT:-#ffee00}}"
case "$ACCENT" in \#*) : ;; *) ACCENT="#$ACCENT" ;; esac

HLROOT="$JD_DIR/.jd-highlighter"
HLDIR="$HLROOT/flatlaf-defaults"
mkdir -p "$HLDIR"
render_properties "$HERE/theme/flatlaf/FlatDarkLaf.properties.tmpl" "$ACCENT" "$HLDIR/FlatDarkLaf.properties"
printf '%s\n' "$ACCENT" > "$HLROOT/accent"
echo "Rendered FlatDarkLaf.properties (accent=$ACCENT) -> $HLDIR/"

# Copy the theme agent jar (built in CI). Tolerate a missing jar so the theme JSON still applies.
AGENT_SRC="$HERE/agent/jd-highlighter-agent.jar"
AGENT="$HLROOT/jd-highlighter-agent.jar"
if [ -f "$AGENT_SRC" ]; then
  cp "$AGENT_SRC" "$AGENT"
  echo "Installed jd-highlighter-agent.jar -> $HLROOT/"
else
  echo "NOTE: $AGENT_SRC not found (the release jar is built in CI)."
  echo "      The .vmoptions line is still wired to $AGENT for when the jar is present."
fi

# Wire the agent via the install4j .vmoptions: JDownloader2.vmoptions next to the launcher
# (Linux), Contents/vmoptions.txt inside the app bundle (macOS). One idempotent line.
LINE="-javaagent:$AGENT=$HLDIR"
VMDIR="$JD_DIR"
VMO="$JD_DIR/JDownloader2.vmoptions"
if [ -d "$JD_DIR/Contents" ]; then VMDIR="$JD_DIR/Contents"; VMO="$JD_DIR/Contents/vmoptions.txt"; fi

if [ -w "$VMDIR" ] || { [ -f "$VMO" ] && [ -w "$VMO" ]; }; then
  touch "$VMO"
  if grep -qF "jd-highlighter-agent.jar" "$VMO"; then
    echo "Agent already wired in $VMO (left as-is)"
  else
    printf '%s\n' "$LINE" >> "$VMO"
    echo "Wired the theme agent -> $VMO"
  fi
else
  # Non-writable launcher dir: keep the agent line in a user file and tell the user how to
  # redirect to it (or use the last-resort JAVA_TOOL_OPTIONS fallback the container uses).
  USERVMO="$HLROOT/jd-highlighter.vmoptions"
  printf '%s\n' "$LINE" > "$USERVMO"
  echo "NOTE: $VMDIR is not writable - could not edit $VMO." >&2
  echo "      Wrote $USERVMO. Add ONE line to your JDownloader .vmoptions:" >&2
  echo "        -include-options $USERVMO" >&2
  echo "      Last-resort fallback (survives every JD relaunch):" >&2
  echo "        export JAVA_TOOL_OPTIONS=\"$LINE\"" >&2
fi

echo "Done. Restart JDownloader."
