# POSIX accent helpers. No bashisms.
accent_fg() {
  hex=$(printf '%s' "$1" | tr 'A-F' 'a-f' | sed 's/^#//')
  r=$(printf '%d' "0x$(echo "$hex" | cut -c1-2)"); g=$(printf '%d' "0x$(echo "$hex" | cut -c3-4)"); b=$(printf '%d' "0x$(echo "$hex" | cut -c5-6)")
  # sRGB relative luminance (WCAG): gamma-expand each channel, then 0.2126 R + 0.7152 G + 0.0722 B.
  # Light accent (L >= 0.5) -> dark fg; dark accent -> light fg.
  fg=$(awk -v r="$r" -v g="$g" -v b="$b" \
    'function lin(c){c=c/255; return (c<=0.03928)?c/12.92:((c+0.055)/1.055)^2.4}
     BEGIN{L=0.2126*lin(r)+0.7152*lin(g)+0.0722*lin(b); print (L>=0.5)?"#161616":"#f4f4f4"}')
  echo "$fg"
}
render_properties() {
  tmpl="$1"; accent="$2"; out="$3"
  case "$accent" in \#*) : ;; *) accent="#$accent" ;; esac
  fg=$(accent_fg "$accent")
  sed -e "s/@@ACCENT@@/$accent/g" -e "s/@@ACCENT_FG@@/$fg/g" "$tmpl" > "$out"
}
