# theme/

- `cfg/laf/FlatDarkLaf.json` holds the IBM Carbon colours JDownloader reads for its own
  content areas (download list, link grabber, settings table, panels, tooltips,
  scrollbars). The download and link lists sit on a `#242424` card, the selection stays
  neutral `#525252`, and the hover row takes the accent. `@@ACCENT_HEX@@` and
  `@@ACCENT_FG_HEX@@` are filled in by the installer.
- `flatlaf/FlatDarkLaf.properties.tmpl` themes the controls: borderless fields, one 8px
  corner radius, and the accent on toggles, focus, tabs, menus and progress.
- `icons/` holds light expander and column-lock icons that replace JD's near-black ones.
- `jd-tabler/` is the Tabler line-art set the agent swaps in for JD's chrome icons.

## Keeping in sync with the container

The same theme ships in the
[JDownloader-for-Unraid container](https://github.com/junkerderprovinz/jdownloader).
`agent/UPSTREAM` names the container commit the agent and the `.properties` template come
from, and CI fails when they differ. The JSON mirrors the jd-highlighter branch of
`rootfs/usr/local/bin/jdownloader-theme.sh` there.
