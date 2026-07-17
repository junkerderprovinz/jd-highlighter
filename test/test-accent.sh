#!/bin/sh
set -eu
. "$(dirname "$0")/../lib/accent.sh"
[ "$(accent_fg '#ffee00')" = "#161616" ] || { echo "FAIL: yellow -> dark fg"; exit 1; }
[ "$(accent_fg '#4589ff')" = "#f4f4f4" ] || { echo "FAIL: blue -> light fg"; exit 1; }
[ "$(accent_fg 'ffee00')"  = "#161616" ] || { echo "FAIL: no-hash accepted"; exit 1; }
TMP=$(mktemp)
render_properties "$(dirname "$0")/../theme/flatlaf/FlatDarkLaf.properties.tmpl" '#ffee00' "$TMP"
grep -q '@accentColor                    = #ffee00' "$TMP" || { echo "FAIL: accent not substituted"; exit 1; }
grep -q 'Button.default.foreground       = #161616' "$TMP" || { echo "FAIL: accent-fg not substituted"; exit 1; }
! grep -q '@@' "$TMP" || { echo "FAIL: leftover token"; exit 1; }
echo "ALL PASS"
