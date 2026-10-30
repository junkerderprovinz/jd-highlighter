# POSIX accent helpers. No bashisms.
accent_fg() {
  hex=$(printf '%s' "$1" | tr 'A-F' 'a-f' | sed 's/^#//')
  r=$(printf '%d' "0x$(echo "$hex" | cut -c1-2)"); g=$(printf '%d' "0x$(echo "$hex" | cut -c3-4)"); b=$(printf '%d' "0x$(echo "$hex" | cut -c5-6)")
  # WCAG relative luminance: a light accent (L >= 0.5) gets dark text, a dark one light text.
  fg=$(awk -v r="$r" -v g="$g" -v b="$b" \
    'function lin(c){c=c/255; return (c<=0.03928)?c/12.92:((c+0.055)/1.055)^2.4}
     BEGIN{L=0.2126*lin(r)+0.7152*lin(g)+0.0722*lin(b); print (L>=0.5)?"#161616":"#f4f4f4"}')
  echo "$fg"
}
# render_properties <tmpl> <accent> <out> fills @@ACCENT@@ and @@ACCENT_FG@@ as #rrggbb and
# @@ACCENT_HEX@@ and @@ACCENT_FG_HEX@@ as bare rrggbb, which JD's colour JSON needs.
render_properties() {
  tmpl="$1"; accent="$2"; out="$3"
  case "$accent" in \#*) : ;; *) accent="#$accent" ;; esac
  fg=$(accent_fg "$accent")
  sed -e "s/@@ACCENT_HEX@@/${accent#\#}/g" -e "s/@@ACCENT_FG_HEX@@/${fg#\#}/g" \
      -e "s/@@ACCENT@@/$accent/g" -e "s/@@ACCENT_FG@@/$fg/g" "$tmpl" > "$out"
}
