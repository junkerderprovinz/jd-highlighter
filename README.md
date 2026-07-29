<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset=".github/assets/banner-dark.png">
    <img src=".github/assets/banner.png" alt="JD Highlighter" width="100%">
  </picture>
</p>

<p align="center">
  <a href="https://github.com/junkerderprovinz/jd-highlighter/actions/workflows/lint.yml"><img src="https://img.shields.io/github/actions/workflow/status/junkerderprovinz/jd-highlighter/lint.yml?branch=main&label=Lint&style=for-the-badge&logo=githubactions&logoColor=white" alt="Lint" height="36"></a>&nbsp;
  <a href="https://github.com/junkerderprovinz/jd-highlighter/releases/latest"><img src="https://img.shields.io/github/v/release/junkerderprovinz/jd-highlighter?display_name=tag&sort=semver&style=for-the-badge&logo=semver&logoColor=white&color=success&cacheSeconds=300" alt="Release" height="36"></a>&nbsp;
  <a href="https://github.com/junkerderprovinz/jd-highlighter/releases"><img src="https://img.shields.io/github/downloads/junkerderprovinz/jd-highlighter/total?style=for-the-badge&logo=github&logoColor=white&label=Downloads" alt="Downloads" height="36"></a>&nbsp;
  <a href="#3-install"><img src="https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux%20%7C%20Docker-555?style=for-the-badge" alt="Platform" height="36"></a>&nbsp;
  <a href="https://jdownloader.org"><img src="https://img.shields.io/badge/JDownloader-2-2d8a42?style=for-the-badge&logoColor=white" alt="JDownloader 2" height="36"></a>&nbsp;
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-AGPL--3.0-blue?style=for-the-badge&logo=gnu&logoColor=white" alt="License: AGPL-3.0" height="36"></a>
</p>

<br>

<p align="center">
A <b>borderless</b>, freely-accented dark theme for <b>JDownloader 2</b> — minimalist IBM Carbon
(<code>#161616</code>) monochrome with <b>subtly rounded corners</b> and a single <b>user-chosen accent</b>
that lights up the interactive controls. Input fields are defined by <i>fill, not frames</i>; large
fills stay neutral so text stays readable at <i>any</i> accent hue. Works on the JDownloader
<b>desktop app</b> and the <b>Docker container</b>.
</p>

<br>

<p align="center">
  <a href="https://buymeacoffee.com/junkerderprovinz">
    <img src=".github/assets/button-buy-me-a-coffee.svg" alt="Buy me a coffee" width="220">
  </a>
</p>

<br>

## Table of Contents

1. [What it does](#1-what-it-does)
2. [Screenshots](#2-screenshots)
3. [Install](#3-install)
4. [How it works](#4-how-it-works)
5. [Uninstall](#5-uninstall)
6. [Credits](#6-credits)
7. [License](#7-license)
8. [Support this project](#8-support-this-project)

<br>

## 1. What it does

JDownloader 2 ships no proper dark mode, and even a dark Look & Feel leaves boxed inputs,
hard separators and grey controls. **JD Highlighter** is a complete visual redesign in a
neutral IBM Carbon (`#161616`) dark, built around four "clean / edel" moves:

- **Borderless.** Every component, border and separator colour equals the surface behind it, so
  the lines simply disappear — no boxes, no hairline grid.
- **Fields defined by fill, not frames.** Text fields, editable combos and spinners sit on a fill
  one step lighter than the window (`#1e1e1e`), reading as soft raised blocks instead of framed inputs.
- **Subtly rounded corners.** Buttons and fields ~6px, checkboxes ~4px — modern without being toy-like.
- **A single, free accent.** One colour you choose (any hex, default electric yellow `#ffee00`)
  lights up **checkmarks, radios, toggle-on, focus rings, links, the download progress bar and
  primary buttons**. **Large text-bearing fills stay neutral** — the selected download row keeps a
  readable grey `#525252`, never a full accent wash — so the look stays edel at any hue. The
  accent-button text is **auto-contrasted** (dark text on a light accent, light text on a dark one).

It works on **Windows, macOS and Linux** (via a small installer) and inside the
**JDownloader Docker container** (via `JD_THEME=jd-highlighter`). It is a sibling to
[**jd-plain-dark**](https://github.com/junkerderprovinz/jd-plain-dark) — want the faithful,
accent-free "JD Plain in dark" instead? Use that one; JD Highlighter is the borderless, accented take.

<br>

## 2. Screenshots

<p align="center">
  <img src="docs/screenshots/preview.png" alt="JD Highlighter — borderless download list, controls and settings with the default electric-yellow accent" width="92%">
</p>

<p align="center"><sub>Borderless Carbon <code>#161616</code> with the default electric-yellow accent <code>#ffee00</code>.</sub></p>

<p align="center">
  <img src="docs/screenshots/preview-accent.png" alt="JD Highlighter with an alternate blue accent — the same theme, one colour changed" width="92%">
</p>

<p align="center"><sub>Same theme, one knob turned — an alternate accent (<code>#4589ff</code>). Large fills stay neutral.</sub></p>

<br>

## 3. Install

JD Highlighter runs on the **desktop app** and in the **Docker container**. The accent is a single
value you choose; it is baked in at apply time (set the value, then restart — no live colour wheel).

### Desktop (Windows / macOS / Linux)

1. Download `jd-highlighter-vX.Y.Z.zip` from the [latest release](https://github.com/junkerderprovinz/jd-highlighter/releases/latest) and unzip it.
2. Run the installer for your OS:
   - **Windows:** double-click **`install/install.bat`** (recommended). It keeps the window open
     and, if it can't find JDownloader automatically, **asks you for the folder**. (Right-click
     `install/install.ps1` → *Run with PowerShell* also works.)
   - **Linux / macOS:** `sh install/install.sh "/path/to/JDownloader"`
     (the folder that contains `cfg`). Without an argument it auto-detects and prompts if it can't.
3. **Restart JDownloader.**

The installer copies the Carbon theme JSON into JD's `cfg/laf/`, selects the `FLATLAF_DARK`
Look & Feel, renders the accented control theme (`FlatDarkLaf.properties`) into
`<JD>/.jd-highlighter/`, drops in the tiny theme agent (`jd-highlighter-agent.jar`), and wires it
with **one idempotent** `-javaagent:` line in JDownloader's install4j `.vmoptions`
(`JDownloader2.vmoptions`, or `Contents/vmoptions.txt` inside the macOS bundle). Running it again
never adds a second line.

**Choose / change the accent (desktop).** Pass any hex to the installer, then restart JDownloader:

```sh
# Linux / macOS — second argument is the accent
sh install/install.sh "/path/to/JDownloader" "#4589ff"
```

```powershell
# Windows — the -Accent parameter (forwarded through install.bat too)
install\install.bat -Accent "#4589ff"
```

Re-running the installer re-renders the control theme and leaves the single agent line in place.
If JDownloader is installed in a read-only folder, the installer writes the agent line to
`<JD>/.jd-highlighter/jd-highlighter.vmoptions` and prints the one line to add
(`-include-options …`), with `JAVA_TOOL_OPTIONS` documented as the last-resort fallback.

### Container (Docker / Unraid)

The theme is bundled in the [JDownloader-for-Unraid container](https://github.com/junkerderprovinz/jdownloader).
Select it and set the accent with two environment variables — both are re-applied on **every start**:

| Variable | Default | Meaning |
|---|---|---|
| `JD_THEME` | `Dark` | Set to `jd-highlighter` for the borderless, freely-accented dark theme |
| `JD_ACCENT` | `#ffee00` | Accent colour for `jd-highlighter` (any hex) |

```bash
docker run -e JD_THEME=jd-highlighter -e JD_ACCENT="#4589ff" ...   # or the fields in the Unraid template
```

**Change the accent (container):** edit `JD_ACCENT` and restart the container. The theme script
writes the accent into the control theme and computes the auto-contrast button text on start.

<br>

## 4. How it works

JDownloader paints in **two separate paths**, so JD Highlighter ships **two files**:

| Surface | Mechanism | File |
|---|---|---|
| Download list, link grabber, settings table, panels, tooltips, scrollbars, icon set | JD's own `colorfor*` config | `theme/cfg/laf/FlatDarkLaf.json` |
| Buttons, checkboxes, radios, toggles, **text fields (fill, no border)**, combos, **borders**, **accent**, focus, rounded corners | FlatLaf custom-defaults `.properties` | `theme/flatlaf/FlatDarkLaf.properties.tmpl` |

The **JSON** is basically the Carbon palette JDownloader reads itself (selection kept neutral at
`#525252`). The **`.properties`** is where JD Highlighter's character lives — borderless colours,
the fill-based fields, the rounded arcs and the `@accentColor` that cascades through the controls.
The accent (and its auto-contrast foreground) are substituted into the template at apply time.

FlatLaf only loads that `.properties` if a running JVM calls
`FlatLaf.registerCustomDefaultsSource(<dir>)`:

- **Desktop:** a tiny theme agent (`jd-highlighter-agent.jar`, compiled `--release 21` to match JD's
  Java-21 runtime) does exactly that from `premain`. The installer wires it via the install4j
  `.vmoptions`, so it survives JDownloader's self-relaunch. No patched `flatlaf.jar`.
- **Container:** the image already registers that defaults directory, so `jdownloader-theme.sh`
  simply writes the rendered `.properties` there when `JD_THEME=jd-highlighter`.

Either way the L&F stays `FLATLAF_DARK` — JD Highlighter is a FlatLaf-Dark theme, only the colours
and control values differ.

<br>

## 5. Uninstall

### Desktop

Run the uninstaller for your OS (it auto-detects JDownloader, or takes the folder as an argument):

- **Windows:** right-click `install/uninstall.ps1` → *Run with PowerShell*.
- **Linux / macOS:** `sh install/uninstall.sh "/path/to/JDownloader"`

It removes exactly the JD Highlighter `-javaagent:` line (and any `-include-options` redirect) from
the `.vmoptions` and deletes the `<JD>/.jd-highlighter/` directory. The Look & Feel is left as
`FLATLAF_DARK` and the theme JSON stays in `cfg/laf/`; to fully revert, pick another theme under
**Settings → GUI → Look & Feel** and restart JDownloader.

### Container

Set `JD_THEME` back to `Dark` (or `Light`) and restart the container.

<br>

## 6. Credits

The two-path technique — overriding JDownloader's native `colorfor*` config for the content areas
and loading a FlatLaf custom-defaults `.properties` for the controls — is derived from the dark
theme built into the [JDownloader-for-Unraid container](https://github.com/junkerderprovinz/jdownloader).
The colours here are our own (IBM Carbon monochrome) and the accent handling is original.
Sibling to [jd-plain-dark](https://github.com/junkerderprovinz/jd-plain-dark). Licensed MIT.

<br>

## 7. License

**Copyright (C) 2026 Junker der Provinz.**

JD Highlighter is free software under the **GNU Affero General Public License v3.0** (AGPL-3.0); see [LICENSE](LICENSE). You may run, study, share and modify it. If you distribute it, or run a modified version as a network service, you must release your source under the same AGPL-3.0 terms and keep the existing copyright and attribution notices intact.

**Name and branding are not licensed.** The AGPL covers the source code only. "JD Highlighter", its logo and its branding remain reserved: a fork or derivative must use its own distinct name and branding, and may not present itself as JD Highlighter. This keeps it unambiguous which project is the original.

<br>

## 8. Support this project

If this made JDownloader a little easier on the eyes, you can

<p align="center">
  <a href="https://buymeacoffee.com/junkerderprovinz">
    <img src=".github/assets/button-buy-me-a-coffee.svg" alt="Buy me a coffee" width="220">
  </a>
</p>

Issues and suggestions: [GitHub Issues](https://github.com/junkerderprovinz/jd-highlighter/issues).
