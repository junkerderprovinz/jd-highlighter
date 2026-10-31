"""The download buttons the README shows, read by gen_download_buttons.py.

Each entry names a button the generator knows and where it leads. The rows,
their order, the colours and the words are the generator's, the same in every
repository.
"""

REPO = "jd-highlighter"

# One zip holds the theme and the installers for every system, and its name
# carries the version, so the desktop buttons lead to the release that lists it.
RELEASE = "https://github.com/junkerderprovinz/jd-highlighter/releases/latest"

BUTTONS = {
    # The JDownloader container carries JD Highlighter as its default look.
    "unraid": "https://ca.unraid.net/apps/jdownloader-18m0vwh17mexzh",
    "source": RELEASE,
    "windows": RELEASE,
    "macos": RELEASE,
    "linux": RELEASE,
}
