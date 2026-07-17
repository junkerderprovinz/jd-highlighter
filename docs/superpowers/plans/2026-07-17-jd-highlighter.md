# JD Highlighter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship JD Highlighter — a minimalist, borderless, freely-accented dark JDownloader 2 theme — working on both the desktop app and the Docker container, as a new `jd-highlighter` repo, with `jd-plain-dark` left untouched.

**Architecture:** Two rendering paths, two files. JD's own content areas (download list, panels, scrollbars) are themed by a `colorfor*` JSON (`cfg/laf/FlatDarkLaf.json`); the Swing controls (buttons, checkboxes, toggles, text fields, borders, accent, rounded corners) are themed by a FlatLaf `.properties` that must be loaded by a running JVM via `FlatLaf.registerCustomDefaultsSource(dir)`. The **container** already has an agent that registers that dir; the **desktop** ships a new tiny theme agent wired in via install4j `.vmoptions`. A single user-chosen accent (`@accentColor`) lights up the controls; large fills stay neutral for readability.

**Tech Stack:** FlatLaf theme properties + JD `colorfor*` JSON; a small Java `premain` agent (compiled `javac --release 21`); POSIX sh + PowerShell installers; Node (opentype.js + @resvg/resvg-js) for branding; GitHub Actions for lint/release.

## Global Constraints

- **Java class target:** the desktop agent MUST be `javac --release 21` (JD runs on Java 21; a class-69 agent crash-loops the GUI — see the v4.2.1 hotfix). Verify the built class is major version 65.
- **LAF identity:** JD Highlighter is a FlatLaf-Dark theme → the JD-side filenames stay `FlatDarkLaf.json` / `FlatDarkLaf.properties` and the L&F value stays `FLATLAF_DARK` / `lookandfeeltheme: FLATLAF_DARK`. Only colour/control values differ.
- **Accent:** free (any hex), default `#ffee00`. One knob `@accentColor`. Large text-bearing fills (list selection) stay neutral `#525252`. Accent-button/progress-% foreground is auto-contrasted: `#161616` for a light accent (sRGB luminance ≥ 0.5), else `#f4f4f4`.
- **Palette:** IBM Carbon greyscale — `#161616` base, `#1e1e1e` component fill, `#262626` panel, `#393939` hairline, `#525252` selection, `#6f6f6f` disabled, `#8d8d8d` dim, `#f4f4f4` text. Functional error `#fa4d56`, warning `#f1c21b`.
- **Borderless:** all component/border/separator colours = the surface behind them; focus width 0; button border width 0. Rounded arcs ~6px (checkbox 4px).
- **No AI attribution** in any commit/PR/release. English in repo/forum; German only in the vault + chat.
- **jd-plain-dark stays untouched.** `jd-highlighter` is a new sibling repo.
- **`.gitattributes`:** `* text=auto eol=lf`; `*.bat text eol=crlf`; `*.png *.ico binary` (carry over from jd-plain-dark — the `.bat` CRLF rule is load-bearing).

---

## File structure

**New repo `d:/nextcloud/it/github/jd-highlighter/`** (mirrors jd-plain-dark; new files marked ★):
```
.gitattributes .gitignore LICENSE renovate.json README.md
theme/README.md
theme/cfg/laf/FlatDarkLaf.json                 # colorfor* Carbon palette (selection neutral)
theme/flatlaf/FlatDarkLaf.properties.tmpl      # ★ FlatLaf controls; @@ACCENT@@/@@ACCENT_FG@@ tokens
agent/src/io/github/junkerderprovinz/HighlighterThemeAgent.java  # ★ tiny premain theme agent
agent/manifest.mf                              # ★ Premain-Class only
lib/accent.sh                                  # ★ shared: accent-fg contrast + .properties render (POSIX)
install/install.sh install/install.ps1 install/install.bat      # extended (agent + .vmoptions + uninstall)
install/uninstall.sh install/uninstall.ps1     # ★ remove agent line + restore
test/test-install.sh                           # extended
.github/assets/icon.svg icon.png               # ★ new hand-authored branding
.github/assets/gen-banner.mjs                  # copied; NAME/CLAIM changed
.github/assets/banner.svg banner.png           # generated
.github/assets/button-buy-me-a-coffee.svg      # copied
.github/workflows/lint.yml                     # extended (agent compile)
.github/workflows/release.yml                  # ★ build agent + package + release notes
.github/release-notes/v1.0.0.md                # ★
docs/screenshots/preview.png docs/screenshots/preview-accent.png # ★
```

**Modified in `d:/nextcloud/it/github/jdownloader/`** (container integration):
```
rootfs/usr/local/bin/jdownloader-theme.sh      # + jd-highlighter case, + JD_ACCENT, + write .properties
rootfs/opt/JDownloader/flatlaf-defaults/highlighter.properties.tmpl  # ★ template shipped in image
rootfs/defaults/autostart                      # + jd-highlighter case, + pass JD_ACCENT
Dockerfile                                     # + JD_ACCENT env default + comment
README.md                                      # + JD_THEME=jd-highlighter + JD_ACCENT rows
```

**Modified in `d:/nextcloud/it/github/unraid-apps/`:**
```
jdownloader/jdownloader.xml                     # JD_THEME dropdown + new JD_ACCENT field
```

---

# Phase 1 — Theme assets (repo: jd-highlighter)

### Task 1: Repo scaffold mirrored from jd-plain-dark

**Files:**
- Create: `.gitattributes`, `.gitignore`, `LICENSE`, `renovate.json`
- Copy: `.github/assets/button-buy-me-a-coffee.svg`

- [ ] **Step 1: Copy the static repo furniture from jd-plain-dark**
```bash
cd d:/nextcloud/it/github/jd-highlighter
SRC=../jd-plain-dark
cp "$SRC/.gitattributes" "$SRC/.gitignore" "$SRC/LICENSE" "$SRC/renovate.json" .
mkdir -p .github/assets
cp "$SRC/.github/assets/button-buy-me-a-coffee.svg" .github/assets/
```
- [ ] **Step 2: Verify `.gitattributes` carries the LF/CRLF rules** — `grep -E 'eol=lf|bat text eol=crlf|png binary' .gitattributes` prints all three.
- [ ] **Step 3: Commit** — `git add -A && git commit -m "chore: scaffold repo furniture (mirror jd-plain-dark)"`

### Task 2: The `colorfor*` JSON (JD content areas)

**Files:**
- Create: `theme/cfg/laf/FlatDarkLaf.json`
- Create: `theme/README.md`

**Interfaces:**
- Produces: a JD theme payload copied to `<JD>/cfg/laf/FlatDarkLaf.json`; the palette matches jd-plain-dark's Carbon; **selection stays neutral `#ff525252`** (readable at any accent).

- [ ] **Step 1: Copy jd-plain-dark's payload as the base**
```bash
mkdir -p theme/cfg/laf
cp ../jd-plain-dark/theme/cfg/laf/FlatDarkLaf.json theme/cfg/laf/FlatDarkLaf.json
```
- [ ] **Step 2: Confirm the selection key is the neutral grey** — open the file, ensure `"colorfortableselectedrowsbackground": "#ff525252"` (it already is in jd-plain-dark). Leave the rest of the Carbon palette as-is (base `#ff161616`, `iconsetid: "flat"`). No accent belongs in this file — the accent lives in the `.properties`.
- [ ] **Step 3: Write `theme/README.md`** — one paragraph: "`cfg/laf/FlatDarkLaf.json` is the IBM-Carbon palette for JD's own content areas (download list, panels, scrollbars). The interactive controls, borders and accent are themed separately by `theme/flatlaf/FlatDarkLaf.properties.tmpl` (loaded via a FlatLaf custom-defaults source)." Add a drift note pointing at `junkerderprovinz/jdownloader` `rootfs/usr/local/bin/jdownloader-theme.sh` (the `jd-highlighter` branch).
- [ ] **Step 4: Validate JSON** — `python -c "import json;json.load(open('theme/cfg/laf/FlatDarkLaf.json'))" && echo OK`. Expected: `OK`.
- [ ] **Step 5: Commit** — `git add theme && git commit -m "feat: Carbon colorfor* palette (JD content areas)"`

### Task 3: The FlatLaf `.properties` template (controls, accent, borderless, rounded)

**Files:**
- Create: `theme/flatlaf/FlatDarkLaf.properties.tmpl`

**Interfaces:**
- Produces: a template with two tokens `@@ACCENT@@` (the accent hex) and `@@ACCENT_FG@@` (the auto-contrast foreground). A renderer (Task 4) substitutes them and writes the result to the FlatLaf defaults dir as `FlatDarkLaf.properties`.

- [ ] **Step 1: Write the template** — `theme/flatlaf/FlatDarkLaf.properties.tmpl`:
```properties
# JD Highlighter — FlatLaf control theme (loaded via registerCustomDefaultsSource).
# @@ACCENT@@ / @@ACCENT_FG@@ are substituted at apply time (container: jdownloader-theme.sh;
# desktop: the theme agent / installer). The accent is the one knob; large fills stay neutral.

# --- base ---
@background          = #161616
@foreground          = #f4f4f4
@componentBackground = #1e1e1e
@disabledForeground  = #6f6f6f

# --- accent (the one knob) ---
@accentColor                    = @@ACCENT@@
ToggleButton.selectedBackground = @@ACCENT@@
Button.default.foreground       = @@ACCENT_FG@@
ProgressBar.selectionForeground = @@ACCENT_FG@@
ProgressBar.background          = #262626
ProgressBar.selectionBackground = #f4f4f4

# --- selection stays neutral (readable at any accent) ---
@selectionBackground = #525252
@selectionForeground = #f4f4f4

# --- borderless ---
Component.borderColor         = #161616
Component.disabledBorderColor = #161616
Component.focusWidth          = 0
Component.innerFocusWidth     = 0.5
Button.borderWidth            = 0
Button.default.borderWidth    = 0
Separator.foreground          = #161616
TabbedPane.showTabSeparators  = false
MenuBar.borderColor           = #161616
ToolBar.borderColor           = #161616
PopupMenu.borderColor         = #161616

# --- rounded ---
Button.arc        = 6
Component.arc     = 6
TextComponent.arc = 6
CheckBox.arc      = 4
```
- [ ] **Step 2: Sanity — no stray tokens except the two intended** — `grep -o '@@[A-Z_]*@@' theme/flatlaf/FlatDarkLaf.properties.tmpl | sort -u` prints exactly `@@ACCENT@@` and `@@ACCENT_FG@@`.
- [ ] **Step 3: Commit** — `git add theme/flatlaf && git commit -m "feat: FlatLaf control theme template (borderless, accent, rounded)"`

### Task 4: Shared accent helper (contrast + template render)

**Files:**
- Create: `lib/accent.sh`
- Test: `test/test-accent.sh`

**Interfaces:**
- Produces (sourced by installers + container script):
  - `accent_fg <hex>` → echoes `#161616` (light accent) or `#f4f4f4` (dark accent).
  - `render_properties <tmpl> <accent-hex> <out>` → writes the template with both tokens substituted.

- [ ] **Step 1: Write the failing test** — `test/test-accent.sh`:
```sh
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
```
- [ ] **Step 2: Run it, expect failure** — `sh test/test-accent.sh` → fails (`accent.sh` not found).
- [ ] **Step 3: Implement `lib/accent.sh`**:
```sh
# POSIX accent helpers. No bashisms.
accent_fg() {
  hex=$(printf '%s' "$1" | tr 'A-F' 'a-f' | sed 's/^#//')
  r=$(printf '%d' "0x${hex%????}"); g=$(printf '%d' "0x$(echo "$hex" | cut -c3-4)"); b=$(printf '%d' "0x$(echo "$hex" | cut -c5-6)")
  # sRGB relative luminance *1000, integer math: 0.2126 R + 0.7152 G + 0.0722 B, /255
  lum=$(( (2126*r + 7152*g + 722*b) / 255 ))   # 0..10000
  if [ "$lum" -ge 5000 ]; then echo "#161616"; else echo "#f4f4f4"; fi
}
render_properties() {
  tmpl="$1"; accent="$2"; out="$3"
  case "$accent" in \#*) : ;; *) accent="#$accent" ;; esac
  fg=$(accent_fg "$accent")
  sed -e "s/@@ACCENT@@/$accent/g" -e "s/@@ACCENT_FG@@/$fg/g" "$tmpl" > "$out"
}
```
- [ ] **Step 4: Run the test, expect pass** — `sh test/test-accent.sh` → `ALL PASS`.
- [ ] **Step 5: Commit** — `git add lib test/test-accent.sh && git commit -m "feat: accent contrast + properties render helper"`

---

# Phase 2 — Container integration (repo: jdownloader)

### Task 5: `jdownloader-theme.sh` — recognise jd-highlighter, read JD_ACCENT, write the .properties

**Files:**
- Modify: `rootfs/usr/local/bin/jdownloader-theme.sh` (case at 22-27; after line 17; the LAF branch at 44)
- Create: `rootfs/opt/JDownloader/flatlaf-defaults/highlighter.properties.tmpl` (the Task-3 template, shipped in the image)
- Test: `rootfs/usr/local/bin/test-theme-highlighter.sh` (temp-dir harness)

**Interfaces:**
- Consumes: `$1` = theme (`jd-highlighter`), `JD_ACCENT` env (default `#ffee00`), the Task-3 template.
- Produces: writes `${JD_CFG}/laf/FlatDarkLaf.json` (Carbon), sets `lookandfeeltheme: FLATLAF_DARK`, and writes `/opt/JDownloader/flatlaf-defaults/FlatDarkLaf.properties` with the accent baked in (for `jd-highlighter`) or the existing minimal Dark content (otherwise).

- [ ] **Step 1: Ship the template + a copy of `lib/accent.sh` into the image** — copy `jd-highlighter/theme/flatlaf/FlatDarkLaf.properties.tmpl` to `rootfs/opt/JDownloader/flatlaf-defaults/highlighter.properties.tmpl`, and vendor the `accent_fg`/`render_properties` functions inline into `jdownloader-theme.sh` (the container has no jd-highlighter checkout at runtime).
- [ ] **Step 2: Add the theme case** — in `rootfs/usr/local/bin/jdownloader-theme.sh` extend the `case` (lines 22-27):
```sh
    jd-highlighter|*[Hh]ighlight*)          LAF="FLATLAF_DARK"  ; HL=1 ;;
```
and initialise `HL=0` before the case, and read the accent after line 17:
```sh
ACCENT="${JD_ACCENT:-#ffee00}"
```
- [ ] **Step 3: Write the `.properties` for jd-highlighter** — after the colorfor* JSON write (post line 115, inside the `FLATLAF_DARK` branch), add:
```sh
DEF="/opt/JDownloader/flatlaf-defaults/FlatDarkLaf.properties"
if [ "${HL:-0}" = "1" ] && [ -f /opt/JDownloader/flatlaf-defaults/highlighter.properties.tmpl ]; then
    render_properties /opt/JDownloader/flatlaf-defaults/highlighter.properties.tmpl "$ACCENT" "$DEF"
    log "jd-highlighter: wrote accented FlatLaf defaults (accent=$ACCENT)"
fi
```
(When HL≠1 the baked default `FlatDarkLaf.properties` stays as-is, preserving today's Dark behaviour.) Add the `accent_fg`/`render_properties` functions near the top.
- [ ] **Step 4: Write the failing test** — `test-theme-highlighter.sh` runs the script with `JD_INST_DIR=$TMP JD_ACCENT=#ffee00 sh jdownloader-theme.sh jd-highlighter`, then asserts: `$TMP/cfg/laf/FlatDarkLaf.json` exists + valid JSON; GUI settings `lookandfeeltheme` == `FLATLAF_DARK`; the rendered `.properties` (point the DEF path at a temp via an env override in the test) contains `@accentColor                    = #ffee00` and `Button.default.foreground       = #161616` and has no `@@`.
- [ ] **Step 5: Run test → pass.** Also run with `JD_THEME=Dark` to confirm the plain path is unchanged (no accent write).
- [ ] **Step 6: Commit** — `git -C ../jdownloader add -A && git -C ../jdownloader commit -m "feat(theme): jd-highlighter theme + JD_ACCENT (accented FlatLaf defaults)"`

### Task 6: `autostart` — expected-LAF case + pass JD_ACCENT

**Files:**
- Modify: `rootfs/defaults/autostart` (case 26-31; line 386)

- [ ] **Step 1: Add the case arm** (lines 26-31), so the READY/healer expects flatdark:
```sh
    jd-highlighter|*[Hh]ighlight*)          EXPECT_LAF="flatdark"  ;;
```
- [ ] **Step 2: Pass the accent to the theme script** — line 386:
```sh
/usr/local/bin/jdownloader-theme.sh "${JD_THEME:-Dark}" "${JD_ACCENT:-#ffee00}" >/dev/null 2>&1 || true
```
(and make `jdownloader-theme.sh` accept `$2` as the accent, overriding the env read for robustness.)
- [ ] **Step 3: Static check** — `grep -n 'jd-highlighter' rootfs/defaults/autostart` shows the case; `bash -n rootfs/defaults/autostart` parses.
- [ ] **Step 4: Commit** — `git -C ../jdownloader commit -am "feat(theme): autostart recognises jd-highlighter + forwards JD_ACCENT"`

### Task 7: Dockerfile env + container README + Unraid template

**Files:**
- Modify: `Dockerfile` (comment 229; ENV 234-240)
- Modify: `README.md` (config table ~187, ~220)
- Modify: `../unraid-apps/jdownloader/jdownloader.xml` (Config 62-65; new accent Config)

- [ ] **Step 1: Dockerfile** — extend the `JD_THEME` comment (line 229) to mention `jd-highlighter`, and add `JD_ACCENT=#ffee00` to the `ENV` block (234-240) with a comment: `# JD_ACCENT – jd-highlighter accent, any hex (default #ffee00)`.
- [ ] **Step 2: README** — after line 187 add a row: `| \`JD_THEME\` | ... \`jd-highlighter\` = borderless, freely-accented dark ... |` and a row `| \`JD_ACCENT\` | \`#ffee00\` | Accent colour for the jd-highlighter theme (any hex) |`. Mention at ~220 that the accent re-applies on every start.
- [ ] **Step 3: Unraid template** — `../unraid-apps/jdownloader/jdownloader.xml` line 63 → `Default="Dark|Light|jd-highlighter"`; update the description (64). Add a new `<Config Name="Accent (JD_ACCENT)" Target="JD_ACCENT" Default="#ffee00" ... Description="Accent colour for the jd-highlighter theme (any hex).">#ffee00</Config>` block modelled on the JD_SELFUPDATE block (67-70).
- [ ] **Step 4: Validate** — `python -c "import xml.dom.minidom as m;m.parse('../unraid-apps/jdownloader/jdownloader.xml');print('xml ok')"`.
- [ ] **Step 5: Commit** both repos — jdownloader (Dockerfile+README), unraid-apps (template).

### Task 8: Container boot smoke + screenshots

- [ ] **Step 1:** Rely on CI: push the jdownloader changes to a branch; the existing `build.yml` hardened smoke gate boots the image. Additionally set `JD_THEME=jd-highlighter` in a local `docker run` (or a temporary CI matrix arm) and confirm the log shows `jd-highlighter: wrote accented FlatLaf defaults` and `registered custom defaults source` and the JVM stays up (no crash loop).
- [ ] **Step 2:** Capture real screenshots (download list, settings, a dialog, a checkbox/toggle/button, an input field) with `JD_ACCENT=#ffee00` and one alternate (e.g. `#4589ff`) → save to `jd-highlighter/docs/screenshots/preview.png` and `preview-accent.png`.
- [ ] **Step 3: GATE — user reviews screenshots** before release (visual approval; Swing look can only be judged on the real app).

---

# Phase 3 — Desktop delivery (repo: jd-highlighter)

### Task 9: The tiny desktop theme agent

**Files:**
- Create: `agent/src/io/github/junkerderprovinz/HighlighterThemeAgent.java`
- Create: `agent/manifest.mf`
- Test: build + `javap` class-version assertion

**Interfaces:**
- Produces: `jd-highlighter-agent.jar` whose `premain` registers a defaults dir with FlatLaf. The dir is passed as the agent arg (`-javaagent:...=<dir>`); it contains the already-rendered `FlatDarkLaf.properties`.

- [ ] **Step 1: Write the agent** — `HighlighterThemeAgent.java`:
```java
package io.github.junkerderprovinz;

import java.io.File;
import java.lang.instrument.Instrumentation;

/** Registers a FlatLaf custom-defaults source so JD Highlighter's control theme loads.
 *  premain arg = absolute path to the defaults directory holding FlatDarkLaf.properties. */
public final class HighlighterThemeAgent {
    public static void premain(String arg, Instrumentation inst) {
        try {
            File dir = (arg != null && !arg.isEmpty())
                ? new File(arg)
                : new File(System.getProperty("user.home"), ".jd-highlighter/flatlaf-defaults");
            if (!dir.isDirectory()) { System.out.println("[jd-highlighter] defaults dir missing: " + dir); return; }
            // FlatLaf is on JD's classpath by the time the UI starts; retry briefly at premain.
            new Thread(() -> register(dir), "jd-highlighter-register").start();
        } catch (Throwable t) { System.out.println("[jd-highlighter] premain failed: " + t); }
    }
    private static void register(File dir) {
        for (int i = 0; i < 60; i++) {
            try {
                Class<?> flatLaf = Class.forName("com.formdev.flatlaf.FlatLaf");
                flatLaf.getMethod("registerCustomDefaultsSource", File.class).invoke(null, dir);
                System.out.println("[jd-highlighter] registered custom defaults source " + dir);
                return;
            } catch (ClassNotFoundException notYet) {
                try { Thread.sleep(500); } catch (InterruptedException ie) { return; }
            } catch (Throwable t) { System.out.println("[jd-highlighter] register failed: " + t); return; }
        }
        System.out.println("[jd-highlighter] FlatLaf never appeared; giving up");
    }
}
```
- [ ] **Step 2: Write `agent/manifest.mf`**:
```
Manifest-Version: 1.0
Premain-Class: io.github.junkerderprovinz.HighlighterThemeAgent

```
(trailing blank line required.)
- [ ] **Step 3: Build + assert class version 65** — `javac --release 21 -d /tmp/hl agent/src/io/github/junkerderprovinz/HighlighterThemeAgent.java && javap -v -classpath /tmp/hl io.github.junkerderprovinz.HighlighterThemeAgent | grep 'major version: 65'`. Expected: prints `major version: 65`.
- [ ] **Step 4: Package** — `(cd /tmp/hl && jar cfm jd-highlighter-agent.jar <path>/agent/manifest.mf io)`.
- [ ] **Step 5: Commit** — `git add agent && git commit -m "feat: tiny desktop theme agent (registerCustomDefaultsSource, --release 21)"`

### Task 10: Desktop installers (files + `.vmoptions` wiring + uninstall)

**Files:**
- Modify: `install/install.sh`, `install/install.ps1`, `install/install.bat` (copied from jd-plain-dark, extended)
- Create: `install/uninstall.sh`, `install/uninstall.ps1`
- Modify: `test/test-install.sh`

**Interfaces:**
- Consumes: `lib/accent.sh`, the theme JSON, `.properties.tmpl`, the built `jd-highlighter-agent.jar`.
- Produces (per OS): copies the JSON to `<JD>/cfg/laf/FlatDarkLaf.json`; sets `lookandfeeltheme: FLATLAF_DARK`; renders `.properties` (with the user's accent) + the agent jar into `<JD>/.jd-highlighter/flatlaf-defaults/`; adds one idempotent `-javaagent:<jar>=<dir>` line to the install4j `.vmoptions`; writes the accent to `<JD>/.jd-highlighter/accent`.

- [ ] **Step 1: Copy the jd-plain-dark installers as the base** and keep their JD-dir detection + JSON copy + `lookandfeeltheme` merge (documented in the mapping). 
- [ ] **Step 2 (install.sh, Linux/macOS): add the FlatLaf + agent + vmoptions block** after the JSON copy:
```sh
. "$HERE/lib/accent.sh"
ACCENT="${JD_HL_ACCENT:-#ffee00}"                        # installer arg/env; prompt if TTY
HLDIR="$JD_DIR/.jd-highlighter/flatlaf-defaults"
mkdir -p "$HLDIR"
render_properties "$HERE/theme/flatlaf/FlatDarkLaf.properties.tmpl" "$ACCENT" "$HLDIR/FlatDarkLaf.properties"
cp "$HERE/agent/jd-highlighter-agent.jar" "$JD_DIR/.jd-highlighter/"
printf '%s\n' "$ACCENT" > "$JD_DIR/.jd-highlighter/accent"
AGENT="$JD_DIR/.jd-highlighter/jd-highlighter-agent.jar"
LINE="-javaagent:$AGENT=$HLDIR"
# install4j vmoptions: JDownloader2.vmoptions next to the launcher (Linux); Contents/vmoptions.txt (macOS bundle)
VMO="$JD_DIR/JDownloader2.vmoptions"; [ -d "$JD_DIR/Contents" ] && VMO="$JD_DIR/Contents/vmoptions.txt"
touch "$VMO"
grep -qF "jd-highlighter-agent.jar" "$VMO" || printf '%s\n' "$LINE" >> "$VMO"   # idempotent
```
- [ ] **Step 3 (install.ps1, Windows): the same** — render the `.properties` (port `render_properties` to PS or shell out), copy the jar to `$JdDir\.jd-highlighter\`, and append the `-javaagent` line to `$JdDir\JDownloader2.vmoptions` only if absent (idempotent), ensuring a trailing newline.
- [ ] **Step 4: Non-writable-install-dir fallback** — if the `.vmoptions` dir is not writable, write `-include-options <user-dir>/jd-highlighter.vmoptions` once and put the `-javaagent` line in the user file (documented in README). Document `JAVA_TOOL_OPTIONS` as the last-resort fallback.
- [ ] **Step 5: Uninstall scripts** — remove exactly the `jd-highlighter-agent.jar` line (and the `-include-options` redirect) from `.vmoptions`, delete `<JD>/.jd-highlighter/`, and restore the previous `lookandfeeltheme` (or note it). 
- [ ] **Step 6: Extend `test/test-install.sh`** — after running install into a temp fake JD dir: assert `<JD>/.jd-highlighter/flatlaf-defaults/FlatDarkLaf.properties` exists with the substituted accent; assert `JDownloader2.vmoptions` contains exactly ONE `-javaagent:...jd-highlighter-agent.jar` line; run install AGAIN and assert still exactly one (idempotent); run uninstall and assert the line + dir are gone.
- [ ] **Step 7: Run tests → pass** (`sh test/test-install.sh`; the pwsh arm in CI).
- [ ] **Step 8: Commit** — `git add install test && git commit -m "feat: desktop installers wire the theme agent via .vmoptions (idempotent) + uninstall"`

---

# Phase 4 — Branding, CI, release (repo: jd-highlighter)

### Task 11: Branding (icon + banner)

**Files:**
- Create: `.github/assets/icon.svg`, `icon.png`
- Copy+edit: `.github/assets/gen-banner.mjs`
- Generate: `.github/assets/banner.svg`, `banner.png`

- [ ] **Step 1: Hand-author `icon.svg`** (48×48) — a minimalist highlighter-cap / spark mark on transparent; save `icon.png` too. (User designs the SVG; take it verbatim per house rule.)
- [ ] **Step 2: Copy the generator + change the two strings** — `cp ../jd-plain-dark/.github/assets/gen-banner.mjs .github/assets/`, then set `NAME = "JD Highlighter"` and `CLAIM = "The only highlighter that won't dry out."` (lines 25-27). Keep the fills or tune.
- [ ] **Step 3: Generate + eyeball** — `node .github/assets/gen-banner.mjs`; open `banner.png`, confirm name + claim render fully (watch the NaN-safe fit — see the profile-banner lesson).
- [ ] **Step 4: Commit** — `git add .github/assets && git commit -m "feat: branding (icon + banner: name + claim)"`

### Task 12: README + release notes

**Files:**
- Create: `README.md`, `.github/release-notes/v1.0.0.md`

- [ ] **Step 1: Write `README.md`** mirroring jd-plain-dark's 7 numbered sections (banner, grey badges, description, BMAC, ToC, `## 1. What it does` … `## 7. Support`). Content differences: describe the borderless/accent/rounded design; **§3 Install** covers desktop (installer wires the tiny agent) AND container (`JD_THEME=jd-highlighter`, `JD_ACCENT`); document how to change the accent on each; **§5 Uninstall** covers the new uninstall scripts. Replace every `jd-plain-dark` URL with `jd-highlighter`.
- [ ] **Step 2: Write `v1.0.0.md`** — one-line summary + `## Added` (the theme, free accent, desktop+container). No AI attribution.
- [ ] **Step 3: Commit.**

### Task 13: CI (lint + release)

**Files:**
- Copy+extend: `.github/workflows/lint.yml`
- Create: `.github/workflows/release.yml`

- [ ] **Step 1: lint.yml** — copy jd-plain-dark's; add a job that `javac --release 21` compiles the agent and asserts `javap` major version 65; add `sh test/test-accent.sh`. Keep JSON-validate + shellcheck + installer tests.
- [ ] **Step 2: release.yml** — on a `v*` tag: build the agent (`eclipse-temurin` `javac --release 21`), package `jd-highlighter-agent.jar`, zip the theme + installers + lib + agent jar into `jd-highlighter-<tag>.zip`, publish a GitHub release with `body_path: .github/release-notes/<tag>.md` and the zip asset.
- [ ] **Step 3: Validate YAML** — `python -c "import yaml;yaml.safe_load(open('.github/workflows/release.yml',encoding='utf-8'))"` (both files).
- [ ] **Step 4: Commit.**

### Task 14: Publish (GitHub repo, first release, ecosystem sync)

- [ ] **Step 1: Create the GitHub repo** `junkerderprovinz/jd-highlighter` (public), push `main`.
- [ ] **Step 2: GATE — user approval to tag** the first release (`never-release-without-approval`). On approval: `git tag v1.0.0 && git push --tags`; verify the release + asset.
- [ ] **Step 3: Ecosystem sync** — add JD Highlighter to the profile README app list, the `unraid-apps` overview if listed, and cross-link from `jd-plain-dark`'s README ("want borderless + a free accent? see JD Highlighter"). Update the JDownloader container README/template (done in Task 7) is live.
- [ ] **Step 4: Vault + changelogs** — project note + daily note + the two chat changelogs (repo + vault).

---

## Self-review

**Spec coverage:** palette (Task 2/3), borderless+fill+rounded (Task 3), free accent + auto-contrast (Task 3/4), neutral big fills (Task 2/3), two-file mechanism (Task 2/3), container delivery + JD_ACCENT (Task 5-7), desktop agent + .vmoptions (Task 9-10), branding/name/claim (Task 11-12), validation/screenshots (Task 8), coexistence with jd-plain-dark (new repo throughout). All spec sections map to a task.

**Open risks carried into execution:** (1) verify the desktop agent's `premain` runs in the FINAL UI JVM after JD's self-relaunch (install4j re-reads `.vmoptions`; `JAVA_TOOL_OPTIONS` is the fallback) — prove with the agent's stdout in Task 10 testing. (2) Confirm `@accentColor` (not just `@accentBaseColor`) actually tints checkmarks/toggles on the Linux JVM — verify on the Task 8 screenshots; if the checkmark stays grey, also set `@accentBaseColor = @@ACCENT@@`. (3) Progress bar = accent by default (intended); flip `ProgressBar.foreground` to neutral if too heavy — decide from Task 8 screenshots.

**No placeholders:** every code step contains real content; the only tokens are the intentional `@@ACCENT@@`/`@@ACCENT_FG@@` runtime substitutions.
