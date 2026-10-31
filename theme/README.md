# theme/

- `cfg/laf/FlatDarkLaf.json` holds the IBM Carbon colours JDownloader reads for its own
  content areas (download list, link grabber, settings table, panels, tooltips,
  scrollbars). The download and link lists sit on a `#242424` card, the selection stays
  neutral `#525252`, and the hover row takes the accent. `@@ACCENT_HEX@@` and
  `@@ACCENT_FG_HEX@@` are filled in by the installer.
- `cfg/laf/FlatLightLaf.json` is the same for JD Highlighter Light: white cards on a
  `#f4f4f4` base and a `#d0d0d0` selection.
- `flatlaf/FlatDarkLaf.properties.tmpl` and `flatlaf/FlatLightLaf.properties.tmpl` theme the
  controls: borderless fields, one 8px corner radius, and the accent on toggles, focus,
  tabs, menus and progress.
- `icons/` holds light expander and column-lock icons that replace JD's near-black ones.
- `jd-tabler/` is the Tabler line-art set the agent swaps in for JD's chrome icons.

## Keeping in sync with the container

The same themes ship in the
[JDownloader-for-Unraid container](https://github.com/junkerderprovinz/jdownloader).
`agent/UPSTREAM` names the container commit the agent, the `.properties` templates and the
Tabler icons come from, and CI fails when they differ. The JSON files mirror the
jd-highlighter branches of `rootfs/usr/local/bin/jdownloader-theme.sh` there.
