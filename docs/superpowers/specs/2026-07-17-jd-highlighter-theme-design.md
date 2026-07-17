# JD Highlighter — Design Spec

**Date:** 2026-07-17
**Status:** Design approved (brainstorm); pending user review → implementation plan.

## What this is

A new, standalone JDownloader 2 theme: a **minimalist, clean, modern, elegant dark UI**. It is a sibling to `jd-plain-dark` (which stays untouched as the faithful "JD Plain in dark"). JD Highlighter goes further: **borderless**, **input fields defined by fill instead of frames**, **subtly rounded corners**, and a **freely user-selectable accent colour** that lights up the interactive controls.

- **Name:** JD Highlighter · repo `jd-highlighter`
- **Claim:** *The only highlighter that won't dry out.*
- **Default accent:** `#ffee00` (electric yellow), fully user-changeable.
- **Works on:** the JDownloader **desktop app** AND the **Docker container**.

## Design language

### Palette — IBM Carbon greyscale (matches the Krusader container theme)

Pure neutral greyscale, no tint. The ladder and roles:

| Role | Hex |
|---|---|
| Window / base background | `#161616` |
| Component / input-field fill (one step lighter → borderless fields) | `#1e1e1e` |
| Panel / header / secondary surface | `#262626` |
| Hairline / hover step | `#393939` |
| Selection background (large fills stay neutral) | `#525252` |
| Disabled / inactive foreground | `#6f6f6f` |
| Dim / secondary text | `#8d8d8d` |
| Primary text / foreground | `#f4f4f4` |
| Error red (functional, unchanged) | `#fa4d56` |
| Warning yellow (functional, unchanged) | `#f1c21b` |

### The "clean / edel" moves

1. **Borderless.** Every component/border colour is set to the surface behind it, so lines disappear. Separators are flattened (`Separator.foreground = @background`), tab/menu/toolbar separators off.
2. **Fields defined by fill, not frame.** `@componentBackground = #1e1e1e` (one step lighter than `#161616`) backs text fields, editable combos, spinners; their border colour equals the fill, so a field reads as a soft raised block, not a boxed input.
3. **Subtly rounded corners.** Buttons/fields ~6px, checkbox icon ~4px — modern without being toy-like.
4. **Accent only where it earns it.** The accent lights up **checkmarks, radio dots, toggle-on, focus rings, links, the download progress bar, and primary buttons**. **Large fills stay neutral** — the selected download row keeps `#525252`, never a full accent wash, so text stays readable and the look stays edel at any accent hue.
5. **Icon set:** JD's `flat` (Plain) iconset, unchanged — already clean and minimal.

### Accent — free choice, safe at any hue

The accent is a single value the user picks (any hex). It flows through FlatLaf's `@accentColor`, which automatically tints checkmarks, radios, focus, selection-in-controls, sliders, the progress bar, the default-button border, tab underline, and links. Plain toggle buttons are wired explicitly (`ToggleButton.selectedBackground = @accentColor`).

To stay readable with **any** accent:
- **Accent-button foreground is auto-contrasted:** a light accent (e.g. `#ffee00`) gets dark text `#161616`; a dark accent gets light text `#f4f4f4`. Computed from the accent's relative luminance at apply time.
- **No accent on large text-bearing fills** (the download-list selection stays neutral `#525252`).

## Architecture — two files, two rendering paths

JDownloader paints in two separate paths, so the theme needs both (proven in `jdownloader/analysis/jd-upstream-submission.md`):

| Surface | Mechanism | File |
|---|---|---|
| Download list / link grabber / settings ExtTable, panels, tooltip, error rows, scrollbars, icon set | JD's own `colorfor*` JSON | `theme/cfg/laf/FlatDarkLaf.json` |
| Buttons, checkboxes, radios, toggles, **text fields (fill, no border)**, combos, **borders**, **accent**, focus, rounded corners | FlatLaf custom-defaults `.properties` | `theme/flatlaf/FlatDarkLaf.properties` |

Neither alone covers the whole UI. The `colorfor*` JSON is basically the Carbon palette (largely identical to `jd-plain-dark`'s, selection kept neutral). The `.properties` is where JD Highlighter's character lives.

### FlatLaf `.properties` — the load-bearing keys (verified against FlatLaf source/docs)

```
# base
@background          = #161616
@foreground          = #f4f4f4
@componentBackground = #1e1e1e     # fields/combos/spinners → lighter fill
@disabledForeground  = #6f6f6f

# accent (the one knob, injected from the user's choice)
@accentColor         = #ffee00     # cascades: checkmark, radio, focus, selection, slider, progress, link, default-button border, tab underline
ToggleButton.selectedBackground = @accentColor   # plain toggles are NOT accent by default → wire explicitly
Button.default.foreground       = <auto: dark for light accent, light for dark accent>

# borderless
Component.borderColor           = @background
Component.disabledBorderColor   = @background
Component.focusWidth            = 0
Button.borderWidth              = 0
Button.default.borderWidth      = 0
Separator.foreground            = @background
TabbedPane.showTabSeparators    = false
MenuBar.borderColor = ToolBar.borderColor = PopupMenu.borderColor = @background

# rounded
Button.arc        = 6
Component.arc     = 6
TextComponent.arc = 6
CheckBox.arc      = 4

# selection stays neutral (readable at any accent)
# (JD's list selection is handled by colorfor* JSON = #525252)
```

Exact final values are locked during implementation against a real build.

## Free accent — how the user changes it

The accent is one value baked into both files at apply time (no live in-app colour wheel — same "set value + reload" model as the MediaMonkey `flat-monkey-dark` accent picker).

- **Container:** a new env var `JD_ACCENT=#rrggbb` (a field in the Unraid template). The theme script writes `@accentColor` into the `.properties` and computes the auto-contrast button foreground on start.
- **Desktop:** the accent lives in a small config the theme agent reads on launch (e.g. `<theme-dir>/accent` or an agent arg). Change it → restart JD.
- **Default** when unset: `#ffee00`.

## Delivery

### Container (the container already has an agent that registers FlatLaf defaults)

- Bundle the JD Highlighter `colorfor*` JSON + `.properties` into the image.
- `JD_THEME=jd-highlighter` selects it (coexists with `jd-plain-dark`, still the default until the user chooses otherwise). `jdownloader-theme.sh` writes the JSON to `<JD>/cfg/laf/FlatDarkLaf.json` and the `.properties` into the FlatLaf custom-defaults dir, injecting `JD_ACCENT`.
- The existing agent's `registerCustomDefaultsSource(...)` already loads the defaults dir; point it at the highlighter `.properties` for this theme.

### Desktop (needs a tiny theme agent — the only way to load FlatLaf `.properties` without a jar patch)

- A **new, minimal theme agent** (`jd-highlighter-agent.jar`): `premain` locates the loaded `com.formdev.flatlaf.FlatLaf` class (via the active LAF's classloader, same technique the container agent uses) and calls `registerCustomDefaultsSource(<theme dir>)`, reading the accent from the theme config. **Compiled `javac --release 21`** to match JD's Java-21 runtime (see [[jdownloader-agent-runtime-java-target]] — the exact class-version trap that just broke v4.2.0). NOT the container's `DialogConfirmAgent` (too container-specific: hardcoded `/opt`, `/config`, dialog/ad logic).
- **Installer** (`install/*.{sh,ps1,bat}`, mirroring `jd-plain-dark`) additionally:
  1. copies the JSON to `<JD>/cfg/laf/FlatDarkLaf.json` and sets `lookandfeeltheme: FLATLAF_DARK`;
  2. copies the `.properties` + `jd-highlighter-agent.jar` into a stable theme dir;
  3. wires the agent via the install4j `.vmoptions` file — `JDownloader2.vmoptions` (Windows/Linux, next to the launcher), `Contents/vmoptions.txt` (macOS, inside the bundle) — adding one idempotent line `-javaagent:<abs>/jd-highlighter-agent.jar` (append only if absent, trailing newline). For a non-writable install dir, add `-include-options ${user-dir}/jd-highlighter.vmoptions` once and write the user copy.
  4. Documented fallback: `JAVA_TOOL_OPTIONS` (survives every JD relaunch; used by the container).
- **Uninstall** removes exactly that agent line (and any `-include-options` redirect) and restores the previous LAF.

## Repo structure (mirrors jd-plain-dark + additions)

```
theme/cfg/laf/FlatDarkLaf.json      # colorfor* (Carbon palette, JD's areas)
theme/flatlaf/FlatDarkLaf.properties# FlatLaf controls/accent/borderless/fields/rounded
agent/src/.../HighlighterThemeAgent.java   # tiny desktop theme agent (premain → registerCustomDefaultsSource)
agent/manifest.mf                   # Premain-Class only
install/install.{sh,ps1,bat}        # per-OS: files + vmoptions -javaagent wiring, idempotent
test/test-install.sh
.github/assets/{banner,icon}.{svg,png} + gen scripts   # own branding (name + claim)
.github/release-notes/ , .github/workflows/lint.yml
docs/screenshots/ , README.md , LICENSE , renovate.json
```

## Open items / risks (resolve during implementation)

1. **Verify the desktop agent's `premain` fires in the FINAL UI JVM** after a cold start (JD relaunches its JVM; install4j re-reads `.vmoptions` on launcher restarts, so it should hold — confirm empirically; `JAVA_TOOL_OPTIONS` is the guaranteed fallback).
2. **Container agent wiring:** the existing agent registers a fixed defaults dir; add a small change so `JD_THEME=jd-highlighter` points it at the highlighter `.properties` (or write to the dir it already watches). No new agent in the container.
3. **Download progress bar = accent by default** (FlatLaf `ProgressBar.foreground` follows `@accentColor`). This is intentional (it literally "highlights" active downloads, on-brand) but is a one-line switch to neutral if it reads too heavy with many concurrent downloads.
4. **Lock exact `.properties` values against a real build** (some FlatLaf keys have theme-specific fallbacks).

## Validation & testing

- **Real screenshots**, not mockups (it's a live Swing app): build the container with `JD_THEME=jd-highlighter`, capture the download list, link grabber, settings, a dialog, with the default accent and one alternate accent.
- **Lint:** JSON valid, `.properties` parses, agent compiles (`--release 21`).
- **Container boot smoke:** theme applies, agent registers, no crash, JVM stays up (reuse the hardened gate pattern).
- **Installer idempotency test:** run twice → one agent line; uninstall → clean.

## Success criteria

- Borderless throughout; input fields read as fill, not frames.
- A single user-chosen accent lights up the controls and stays readable at any hue; large fills neutral.
- Works on both desktop and container; `jd-plain-dark` untouched; selectable via `JD_THEME`.
- Looks minimalist, clean, modern, edel — visibly its own thing, not "plain-dark v2".

## Implementation phasing (for the plan)

1. **Theme assets** — the `colorfor*` JSON + FlatLaf `.properties` + accent injection logic; validate values against a build.
2. **Container integration** — `JD_THEME=jd-highlighter` + `JD_ACCENT`, wire the existing agent's defaults source.
3. **Desktop delivery** — the tiny theme agent + per-OS installer `.vmoptions` wiring + idempotent uninstall.
4. **Branding + release** — banner/icon/README (name + claim), lint/CI, screenshots, first release.
