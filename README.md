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
A <b>borderless</b>, freely-accented dark theme for <b>JDownloader 2</b>: minimalist IBM Carbon
(<code>#161616</code>) monochrome with <b>subtly rounded corners</b> and a single <b>user-chosen accent</b>
that lights up the interactive controls. Input fields are defined by <i>fill, not frames</i>; large
fills stay neutral so text stays readable at <i>any</i> accent hue. Works on the JDownloader
<b>desktop app</b> and the <b>Docker container</b>.
</p>

<br>

<p align="center">
  <a href="https://buymeacoffee.com/junkerderprovinz"><img src="https://raw.githubusercontent.com/junkerderprovinz/junkerderprovinz/main/donate/buttons/button-buy-me-a-coffee-live.svg" alt="Buy me a coffee" width="160"></a>
  &nbsp;
  <a href="https://www.paypal.com/donate/?hosted_button_id=76FVV52TKXTUS"><img src="https://raw.githubusercontent.com/junkerderprovinz/junkerderprovinz/main/donate/buttons/button-paypal-live.svg" alt="PayPal" width="160"></a>
  &nbsp;
  <a href="https://junkerderprovinz.github.io/junkerderprovinz/"><img src="https://raw.githubusercontent.com/junkerderprovinz/junkerderprovinz/main/donate/buttons/button-crypto-live.svg" alt="Donate with crypto" width="160"></a>
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
hard separators, grey controls and a toolbar full of colourful icons. **JD Highlighter** is a
complete visual redesign in a neutral IBM Carbon (`#161616`) dark:

- **Borderless.** Borders and separators take the colour of the surface behind them, so the
  lines disappear: no boxes, no hairline grid. Areas stand apart by shade instead.
- **Cards, not frames.** The download list, the link grabber and the settings sections sit on
  a `#242424` card with rounded corners; fields are soft filled blocks without a frame.
- **One corner radius.** Buttons, fields, tabs, menus, cards and dialogs all round at 8px.
- **Clean line icons.** The chrome icons (toolbar, tabs, sidebar, section headers, status
  glyphs) become one consistent set of [Tabler](https://tabler.io/icons) line icons.
- **A single, free accent.** One colour you choose (any hex, default electric yellow `#ffee00`)
  lights up the toolbar toggles, the selected tab, menu and row hover, checkmarks, focus and
  the download progress bar. **Large text-bearing fills stay neutral**: the selected download
  row keeps a readable grey `#525252`, so the look holds at any hue. Text on the accent is
  **auto-contrasted** (dark on a light accent, light on a dark one).

It works on **Windows, macOS and Linux** (via a small installer) and inside the
**JDownloader Docker container** (via `JD_THEME=jd-highlighter`). It is a sibling to
[**jd-plain-dark**](https://github.com/junkerderprovinz/jd-plain-dark). Want the faithful,
accent-free "JD Plain in dark" instead? Use that one; JD Highlighter is the borderless, accented take.

<br>

## 2. Screenshots

<p align="center">
  <img src="docs/screenshots/preview.png" alt="JD Highlighter: borderless download list, controls and settings with the default electric-yellow accent" width="92%">
</p>

<p align="center"><sub>Borderless Carbon <code>#161616</code> with the default electric-yellow accent <code>#ffee00</code>.</sub></p>

<p align="center">
  <img src="docs/screenshots/preview-accent.png" alt="JD Highlighter with an alternate blue accent: the same theme, one colour changed" width="92%">
</p>

<p align="center"><sub>Same theme, one knob turned: an alternate accent (<code>#4589ff</code>). Large fills stay neutral.</sub></p>

<br>

## 3. Install

JD Highlighter runs on the **desktop app** and in the **Docker container**. The accent is a single
value you choose; it is baked in at apply time (set the value, then restart; there is no live colour wheel).

### Desktop (Windows / macOS / Linux)

1. Download `jd-highlighter-vX.Y.Z.zip` from the [latest release](https://github.com/junkerderprovinz/jd-highlighter/releases/latest) and unzip it.
2. Run the installer for your OS:
   - **Windows:** double-click **`install/install.bat`** (recommended). It keeps the window open
     and, if it can't find JDownloader automatically, **asks you for the folder**. Right-click
     `install/install.ps1` → *Run with PowerShell* works as well.
   - **Linux / macOS:** `sh install/install.sh "/path/to/JDownloader"`
     (the folder that contains `cfg`). Without an argument it auto-detects and prompts if it can't.
3. **Restart JDownloader.** If you have never used one of JD's FlatLaf designs before, JD
   downloads it on this start and restarts once more by itself. The theme appears as soon as
   FlatLaf is running.

The installer writes the Carbon colours into JD's `cfg/laf/`, selects the `FLATLAF_DARK`
Look & Feel and switches off JD's built-in ads. Into `<JD>/.jd-highlighter/` it renders the
accented control theme (`FlatDarkLaf.properties`) and copies the theme agent
(`jd-highlighter-agent.jar`) with its icons. Two lines in JDownloader's install4j `.vmoptions`
(`JDownloader2.vmoptions`, or `Contents/vmoptions.txt` inside the macOS bundle) load the agent;
running the installer again replaces them instead of adding more.

**Choose / change the accent (desktop).** Pass any hex to the installer, then restart JDownloader:

```sh
# Linux / macOS: the second argument is the accent
sh install/install.sh "/path/to/JDownloader" "#4589ff"
```

```powershell
# Windows: the -Accent parameter (install.bat passes it on)
install\install.bat -Accent "#4589ff"
```

If JDownloader is installed in a read-only folder, the installer writes the two lines to
`<JD>/.jd-highlighter/jd-highlighter.vmoptions` and prints the one line to add
(`-include-options …`), with `JAVA_TOOL_OPTIONS` as the last-resort fallback.

### Container (Docker / Unraid)

The theme is bundled in the [JDownloader-for-Unraid container](https://github.com/junkerderprovinz/jdownloader).
Select it and set the accent with two environment variables, both re-applied on **every start**:

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

JDownloader paints in **two separate paths**, and some of its look is hard-coded, so JD
Highlighter works on three levels:

| Surface | Mechanism | File |
|---|---|---|
| Download list, link grabber, settings table, panels, tooltips, scrollbars | JD's own `colorfor*` config | `theme/cfg/laf/FlatDarkLaf.json` |
| Buttons, checkboxes, toggles, fields, combos, tabs, menus, borders, accent, corner radius | FlatLaf custom-defaults `.properties` | `theme/flatlaf/FlatDarkLaf.properties.tmpl` |
| Icons, cards, menu badges, dialogs, progress rings, everything JD hard-codes | a Java agent | `agent/` |

The **JSON** is the Carbon palette JDownloader reads itself. The **`.properties`** holds the
borderless colours, the fill-based fields, the rounded corners and the `@accentColor` that
cascades through the controls. The installer fills the accent and its auto-contrast colour into
both at apply time.

The **agent** (`jd-highlighter-agent.jar`, compiled for JD's Java 21 runtime) registers the
`.properties` with FlatLaf and then reworks what no theme key reaches: it swaps the chrome icons
for the Tabler set, lays the lists onto rounded cards, turns menus and dialogs borderless and
replaces JD's coloured progress globes with a plain accent ring. JDownloader's own jars stay
untouched. The agent is the same one the
[JDownloader-for-Unraid container](https://github.com/junkerderprovinz/jdownloader) runs;
`agent/UPSTREAM` names the container commit it comes from.

The L&F stays `FLATLAF_DARK` throughout: JD Highlighter is a FlatLaf Dark theme with its own
colours, control values and icons.

<br>

## 5. Uninstall

### Desktop

Run the uninstaller for your OS (it auto-detects JDownloader, or takes the folder as an argument):

- **Windows:** right-click `install/uninstall.ps1` → *Run with PowerShell*.
- **Linux / macOS:** `sh install/uninstall.sh "/path/to/JDownloader"`

It removes exactly the two JD Highlighter lines (and any `-include-options` redirect) from the
`.vmoptions` and deletes the `<JD>/.jd-highlighter/` directory. The Look & Feel is left as
`FLATLAF_DARK` and the theme JSON stays in `cfg/laf/`; to fully revert, pick another theme under
**Settings → GUI → Look & Feel** and restart JDownloader.

### Container

Set `JD_THEME` back to `Dark` (or `Light`) and restart the container.

<br>

## 6. Credits

The two-path technique, overriding JDownloader's native `colorfor*` config for the content areas
and loading a FlatLaf custom-defaults `.properties` for the controls, comes from the dark theme
built into the [JDownloader-for-Unraid container](https://github.com/junkerderprovinz/jdownloader).
The chrome icons are [Tabler Icons](https://tabler.io/icons) (MIT, see
`theme/jd-tabler/LICENSE.tabler`). The agent bundles [ASM](https://asm.ow2.io/) (BSD-3-Clause, see `agent/LICENSE.asm`).
Sibling to [jd-plain-dark](https://github.com/junkerderprovinz/jd-plain-dark).

<br>

## 7. License

**Copyright (C) 2026 Junker der Provinz.**

JD Highlighter is free software under the **GNU Affero General Public License v3.0** (AGPL-3.0); see [LICENSE](LICENSE). You may run, study, share and modify it. If you distribute it, or run a modified version as a network service, you must release your source under the same AGPL-3.0 terms and keep the existing copyright and attribution notices intact.

**Name and branding are not licensed.** The AGPL covers the source code only. "JD Highlighter", its logo and its branding remain reserved: a fork or derivative must use its own distinct name and branding, and may not present itself as JD Highlighter. This keeps it unambiguous which project is the original.

<br>

## 8. Support this project

If this made JDownloader a little easier on the eyes, you can

<p align="center">
  <a href="https://buymeacoffee.com/junkerderprovinz"><img src="https://raw.githubusercontent.com/junkerderprovinz/junkerderprovinz/main/donate/buttons/button-buy-me-a-coffee-live.svg" alt="Buy me a coffee" width="160"></a>
  &nbsp;
  <a href="https://www.paypal.com/donate/?hosted_button_id=76FVV52TKXTUS"><img src="https://raw.githubusercontent.com/junkerderprovinz/junkerderprovinz/main/donate/buttons/button-paypal-live.svg" alt="PayPal" width="160"></a>
  &nbsp;
  <a href="https://junkerderprovinz.github.io/junkerderprovinz/"><img src="https://raw.githubusercontent.com/junkerderprovinz/junkerderprovinz/main/donate/buttons/button-crypto-live.svg" alt="Donate with crypto" width="160"></a>
</p>

Issues and suggestions: [GitHub Issues](https://github.com/junkerderprovinz/jd-highlighter/issues).
