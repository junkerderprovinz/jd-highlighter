#!/usr/bin/env sh
# JD Highlighter uninstaller (Linux/macOS)
# Removes the theme agent lines from the .vmoptions and the .jd-highlighter dir.
# Usage: uninstall.sh [/path/to/JDownloader]   (the folder that contains 'cfg')
set -eu

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

if { [ -z "$JD_DIR" ] || [ ! -d "$JD_DIR/cfg" ]; } && [ -t 0 ]; then
  printf "Could not auto-detect JDownloader.\nEnter your JDownloader folder (contains 'cfg'), or leave empty to cancel: "
  read -r JD_DIR
fi

if [ -z "$JD_DIR" ] || [ ! -d "$JD_DIR/cfg" ]; then
  echo "JDownloader cfg dir not found." >&2
  echo "Usage: uninstall.sh /path/to/JDownloader   (the folder that contains 'cfg')" >&2
  exit 1
fi

# Strips the agent lines and any -include-options redirect from the install4j vmoptions.
VMO="$JD_DIR/JDownloader2.vmoptions"
[ -d "$JD_DIR/Contents" ] && VMO="$JD_DIR/Contents/vmoptions.txt"
if [ -f "$VMO" ]; then
  sed -e '/jd-highlighter-agent\.jar/d' -e '/jd\.highlighter\.home/d' -e '/jd-highlighter\.vmoptions/d' "$VMO" > "$VMO.tmp" && mv "$VMO.tmp" "$VMO"
  echo "Removed the JD Highlighter agent lines from $VMO"
fi

# The theme dir holds the rendered .properties, the agent jar, the icons and the accent.
if [ -d "$JD_DIR/.jd-highlighter" ]; then
  rm -rf "$JD_DIR/.jd-highlighter"
  echo "Removed $JD_DIR/.jd-highlighter/"
fi

echo "Done. Your Look & Feel is still FLATLAF_DARK; the theme JSON stays in cfg/laf/."
echo "Pick a different theme in Settings > GUI > Look & Feel and restart if you want to fully revert."
