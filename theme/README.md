# theme/

`cfg/laf/FlatDarkLaf.json` is the IBM-Carbon palette for JD's own content areas
(download list, link grabber, settings table, panels, tooltips, scrollbars):
the keys JDownloader reads itself (`colorfor*`), `#161616` base, selection kept
neutral (`#ff525252`) so text stays readable at any accent. The interactive
controls, borders and accent are themed separately by
`theme/flatlaf/FlatDarkLaf.properties.tmpl` (loaded via a FlatLaf
custom-defaults source), which is where JD Highlighter's borderless, rounded,
freely-accented character lives.

## Source / drift note

This palette mirrors the container image
[`junkerderprovinz/jdownloader`](https://github.com/junkerderprovinz/jdownloader)
→ `rootfs/usr/local/bin/jdownloader-theme.sh` (the `jd-highlighter` branch).
Keep the two in sync when colours change.
