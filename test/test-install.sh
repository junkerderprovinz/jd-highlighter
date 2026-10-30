#!/usr/bin/env sh
# Tests for the JD Highlighter installers.
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
TMP2="$(mktemp -d)"
TMP4="$(mktemp -d)"

# CI builds the real jar; a placeholder exercises the copy, and cleanup removes only ours.
JAR="$ROOT/agent/jd-highlighter-agent.jar"
CREATED_JAR=0
cleanup() { rm -rf "$TMP" "$TMP2" "$TMP4"; [ "$CREATED_JAR" = 1 ] && rm -f "$JAR"; return 0; }
trap cleanup EXIT
if [ ! -f "$JAR" ]; then printf 'PK\003\004 placeholder jar (real one built in CI)\n' > "$JAR"; CREATED_JAR=1; fi

# Test 1: explicit path argument.
mkdir -p "$TMP/cfg"
printf '{"foo":"bar"}' > "$TMP/cfg/org.jdownloader.settings.GraphicalUserInterfaceSettings.json"
sh "$ROOT/install/install.sh" "$TMP" </dev/null
test -f "$TMP/cfg/laf/FlatDarkLaf.json" || { echo "FAIL(1): FlatDarkLaf.json not written"; exit 1; }
grep -q '"#ffffee00"' "$TMP/cfg/laf/FlatDarkLaf.json" || { echo "FAIL(1): default accent not in the colour JSON"; exit 1; }
if grep -q '@@' "$TMP/cfg/laf/FlatDarkLaf.json"; then echo "FAIL(1): leftover @@ token in the colour JSON"; exit 1; fi
grep -q 'FLATLAF_DARK' "$TMP/cfg/org.jdownloader.settings.GraphicalUserInterfaceSettings.json" \
  || { echo "FAIL(1): lookandfeeltheme not set"; exit 1; }
grep -q '"foo"' "$TMP/cfg/org.jdownloader.settings.GraphicalUserInterfaceSettings.json" \
  || { echo "FAIL(1): existing key lost"; exit 1; }
grep -q '"bannerenabled": false' "$TMP/cfg/org.jdownloader.settings.GraphicalUserInterfaceSettings.json" \
  || { echo "FAIL(1): built-in ads not disabled (bannerenabled)"; exit 1; }
echo "PASS(1) explicit path"

# Test 2: auto-detection (no argument), via a $HOME candidate.
mkdir -p "$TMP2/JDownloader/cfg"
HOME="$TMP2" sh "$ROOT/install/install.sh" </dev/null
test -f "$TMP2/JDownloader/cfg/laf/FlatDarkLaf.json" || { echo "FAIL(2): auto-detect wrote nothing"; exit 1; }
echo "PASS(2) auto-detect"

# Test 3: the Windows installer knows the plain "JDownloader" folder and asks when detection fails.
PS1="$ROOT/install/install.ps1"
grep -qF '"C:\Program Files\JDownloader"' "$PS1" \
  || { echo "FAIL(3): install.ps1 missing 'C:\Program Files\JDownloader' (no 2.0 suffix) candidate"; exit 1; }
grep -q 'Read-Host' "$PS1" \
  || { echo "FAIL(3): install.ps1 missing interactive fallback (Read-Host)"; exit 1; }
echo "PASS(3) windows installer guards"

# Test 4: agent wiring, accent render, icons, idempotency, uninstall.
mkdir -p "$TMP4/cfg"
HLROOT="$TMP4/.jd-highlighter"
PROPS="$HLROOT/flatlaf-defaults/FlatDarkLaf.properties"
VMO="$TMP4/JDownloader2.vmoptions"
printf '%s\n' '-Xmx1g' '-javaagent:/old/jd-highlighter-agent.jar=/old/flatlaf-defaults' > "$VMO"

sh "$ROOT/install/install.sh" "$TMP4" "#ffee00" </dev/null
test -f "$PROPS" || { echo "FAIL(4): FlatDarkLaf.properties not rendered"; exit 1; }
grep -Eq '^@accentColor +=  ?#ffee00$' "$PROPS" \
  || { echo "FAIL(4): accent not substituted in .properties"; exit 1; }
grep -Eq '^TabbedPane.selectedForeground +=  ?#161616$' "$PROPS" \
  || { echo "FAIL(4): accent-fg not substituted (yellow -> dark)"; exit 1; }
if grep -q '@@' "$PROPS"; then echo "FAIL(4): leftover @@ token in .properties"; exit 1; fi
[ "$(cat "$HLROOT/accent")" = "#ffee00" ] || { echo "FAIL(4): accent file wrong"; exit 1; }
test -f "$HLROOT/jd-highlighter-agent.jar" || { echo "FAIL(4): agent jar not copied"; exit 1; }
test -f "$HLROOT/icons/tree_plus.svg" || { echo "FAIL(4): light icons not copied"; exit 1; }
test -f "$HLROOT/jd-tabler/mapping.json" || { echo "FAIL(4): Tabler set not copied"; exit 1; }
grep -qx -- '-Xmx1g' "$VMO" || { echo "FAIL(4): unrelated vmoptions line lost"; exit 1; }
N=$(grep -c 'jd-highlighter-agent\.jar' "$VMO")
[ "$N" = "1" ] || { echo "FAIL(4): expected 1 -javaagent line, got $N"; exit 1; }
grep -qx -- "-javaagent:$HLROOT/jd-highlighter-agent.jar" "$VMO" || { echo "FAIL(4): agent line wrong"; exit 1; }
grep -qx -- "-Djd.highlighter.home=$HLROOT" "$VMO" || { echo "FAIL(4): home line missing"; exit 1; }
echo "PASS(4) install wires agent + renders accent"

sh "$ROOT/install/install.sh" "$TMP4" "#ffee00" </dev/null
N=$(grep -c 'jd-highlighter' "$VMO")
[ "$N" = "2" ] || { echo "FAIL(4b): re-install left $N JD Highlighter lines, expected 2"; exit 1; }
echo "PASS(4b) re-install is idempotent"

sh "$ROOT/install/uninstall.sh" "$TMP4" </dev/null
if grep -q 'jd-highlighter\|jd\.highlighter' "$VMO"; then echo "FAIL(4c): agent lines not removed on uninstall"; exit 1; fi
grep -qx -- '-Xmx1g' "$VMO" || { echo "FAIL(4c): unrelated vmoptions line lost on uninstall"; exit 1; }
if [ -d "$HLROOT" ]; then echo "FAIL(4c): .jd-highlighter dir not removed on uninstall"; exit 1; fi
echo "PASS(4c) uninstall removes lines + theme dir"

# Test 5: Windows agent wiring and uninstall, checked statically.
grep -q 'javaagent' "$PS1" || { echo "FAIL(5): install.ps1 missing -javaagent wiring"; exit 1; }
grep -q 'jd\.highlighter\.home' "$PS1" || { echo "FAIL(5): install.ps1 missing the home property"; exit 1; }
test -f "$ROOT/install/uninstall.ps1" || { echo "FAIL(5): uninstall.ps1 missing"; exit 1; }
grep -qF 'jd\.highlighter\.home' "$ROOT/install/uninstall.ps1" \
  || { echo "FAIL(5): uninstall.ps1 does not strip the home line"; exit 1; }
echo "PASS(5) windows agent-wiring + uninstall guards"

echo "ALL PASS"
