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

# Ask when a terminal is attached, so a missing folder never fails silently.
if { [ -z "$JD_DIR" ] || [ ! -d "$JD_DIR/cfg" ]; } && [ -t 0 ]; then
  printf "Could not auto-detect JDownloader.\nEnter your JDownloader folder (contains 'cfg'), or leave empty to cancel: "
  read -r JD_DIR
fi

if [ -z "$JD_DIR" ] || [ ! -d "$JD_DIR/cfg" ]; then
  echo "JDownloader cfg dir not found." >&2
  echo "Usage: install.sh /path/to/JDownloader [accent-hex]   (the folder that contains 'cfg')" >&2
  exit 1
fi

. "$HERE/lib/accent.sh"
ACCENT="${2:-${JD_HL_ACCENT:-#ffee00}}"
case "$ACCENT" in \#*) : ;; *) ACCENT="#$ACCENT" ;; esac
case "$ACCENT" in
  \#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]) : ;;
  *) echo "Accent $ACCENT is not a #rrggbb colour, using #ffee00" >&2; ACCENT="#ffee00" ;;
esac

mkdir -p "$JD_DIR/cfg/laf"
render_properties "$SRC" "$ACCENT" "$JD_DIR/cfg/laf/FlatDarkLaf.json"
echo "Wrote FlatDarkLaf.json (accent=$ACCENT) -> $JD_DIR/cfg/laf/"

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
# JD's own advertising: the premium banner also squeezes the download graph.
for k in ("bannerenabled", "statusbaraddpremiumbuttonvisible",
          "premiumalertspeedcolumnenabled", "premiumalerttaskcolumnenabled",
          "premiumalertetacolumnenabled", "premiumdisabledwarningflashenabled",
          "specialdealsenabled", "specialdealoboomdialogvisibleonstartup"):
    d[k] = False
json.dump(d, open(p, "w"), indent=2)
PY
  echo "Set lookandfeeltheme=FLATLAF_DARK and turned off JD's ads"
else
  echo "NOTE: python3 not found. Open JDownloader and pick"
  echo "      Settings > GUI > Look & Feel > FLATLAF_DARK once."
fi

HLROOT="$JD_DIR/.jd-highlighter"
HLDIR="$HLROOT/flatlaf-defaults"
mkdir -p "$HLDIR"
render_properties "$HERE/theme/flatlaf/FlatDarkLaf.properties.tmpl" "$ACCENT" "$HLDIR/FlatDarkLaf.properties"
printf '%s\n' "$ACCENT" > "$HLROOT/accent"
echo "Rendered FlatDarkLaf.properties (accent=$ACCENT) -> $HLDIR/"

rm -rf "$HLROOT/icons" "$HLROOT/jd-tabler"
cp -R "$HERE/theme/icons" "$HLROOT/icons"
cp -R "$HERE/theme/jd-tabler" "$HLROOT/jd-tabler"
echo "Copied the icon sets -> $HLROOT/"

# The release zip carries the jar built in CI; without it the colours still apply.
AGENT_SRC="$HERE/agent/jd-highlighter-agent.jar"
AGENT="$HLROOT/jd-highlighter-agent.jar"
if [ -f "$AGENT_SRC" ]; then
  # A running JD keeps the old jar open, so the new one is moved in instead of written over it.
  cp "$AGENT_SRC" "$AGENT.new"
  mv -f "$AGENT.new" "$AGENT"
  echo "Installed jd-highlighter-agent.jar -> $HLROOT/"
fi

# install4j reads JDownloader2.vmoptions next to the launcher on Linux and
# Contents/vmoptions.txt inside the app bundle on macOS. Old JD Highlighter lines are
# dropped first, so running the installer again leaves exactly one pair. Java refuses to
# start with a -javaagent whose jar is missing, so that line needs the jar.
HOMELINE="-Djd.highlighter.home=$HLROOT"
AGENTLINE=""
if [ -f "$AGENT" ]; then
  AGENTLINE="-javaagent:$AGENT"
else
  echo "NOTE: there is no jd-highlighter-agent.jar in this folder, so only the colours apply." >&2
fi
VMDIR="$JD_DIR"
VMO="$JD_DIR/JDownloader2.vmoptions"
if [ -d "$JD_DIR/Contents" ]; then VMDIR="$JD_DIR/Contents"; VMO="$JD_DIR/Contents/vmoptions.txt"; fi

if [ -w "$VMDIR" ] || { [ -f "$VMO" ] && [ -w "$VMO" ]; }; then
  touch "$VMO"
  sed -e '/jd-highlighter-agent\.jar/d' -e '/jd\.highlighter\.home/d' -e '/jd-highlighter\.vmoptions/d' "$VMO" > "$VMO.tmp"
  printf '%s\n' "$HOMELINE" ${AGENTLINE:+"$AGENTLINE"} >> "$VMO.tmp"
  mv "$VMO.tmp" "$VMO"
  echo "Wired the theme agent -> $VMO"
else
  USERVMO="$HLROOT/jd-highlighter.vmoptions"
  printf '%s\n' "$HOMELINE" ${AGENTLINE:+"$AGENTLINE"} > "$USERVMO"
  echo "NOTE: $VMDIR is not writable, so $VMO stays as it is." >&2
  echo "      Wrote $USERVMO. Add this line to your JDownloader .vmoptions:" >&2
  echo "        -include-options $USERVMO" >&2
  echo "      Or, as a last resort that survives every JD relaunch:" >&2
  echo "        export JAVA_TOOL_OPTIONS=\"$HOMELINE $AGENTLINE\"" >&2
fi

echo "Done. Restart JDownloader."
