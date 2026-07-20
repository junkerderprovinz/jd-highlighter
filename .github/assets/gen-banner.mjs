/**
 * Generates the JD Highlighter README banner (house standard):
 *   banner.svg / banner.png : white 1600x500; the recoloured JDownloader logo
 *   (from icon.svg) on the left, "JD Highlighter" in Bree Serif + a claim in
 *   Lato to the right. Text is baked to paths (opentype.js) so the SVG needs no font.
 *
 * Deps (global): opentype.js, @resvg/resvg-js. Bree Serif + Lato (OFL) are
 * fetched at runtime to the OS temp dir — not committed.
 *
 * Run: node .github/assets/gen-banner.mjs
 */
import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { tmpdir } from "node:os";
import { createRequire } from "node:module";
import { execSync } from "node:child_process";

const require = createRequire(import.meta.url);
const groot = execSync("npm root -g").toString().trim();
const opentype = require(`${groot}/opentype.js`);
const { Resvg } = require(`${groot}/@resvg/resvg-js`);
const __dir = dirname(fileURLToPath(import.meta.url));

const NAME = "JD Highlighter";
const CLAIM = "The only highlighter that won't dry out.";
const NAME_FILL = "#242626", CLAIM_FILL = "#5a5d5e";
const W = 1600, H = 500, LH = 380, LW = 380;
const LX = 150, LY = (H - LH) / 2;     // logo: fixed left
const textX = 600, claimSize = 40, lineGap = 18;

async function loadFont(name, url) {
  const p = join(tmpdir(), name);
  if (!existsSync(p)) {
    const r = await fetch(url);
    if (!r.ok) throw new Error(`font fetch ${r.status}`);
    writeFileSync(p, Buffer.from(await r.arrayBuffer()));
  }
  return opentype.parse(readFileSync(p));
}
const font = await loadFont("BreeSerif-Regular.ttf", "https://github.com/google/fonts/raw/main/ofl/breeserif/BreeSerif-Regular.ttf");
const claimFont = await loadFont("Lato-Regular.ttf", "https://github.com/google/fonts/raw/main/ofl/lato/Lato-Regular.ttf");

// Shrink the name until it fits the available width to the right of the logo.
const maxTextW = W - textX - 80;
let nameSize = 124;
while (font.getAdvanceWidth(NAME, nameSize) > maxTextW && nameSize > 60) nameSize -= 2;

const sc = (s) => s / font.unitsPerEm;
const nameAsc = font.ascender * sc(nameSize);
const nameDesc = -font.descender * sc(nameSize);
const claimAsc = claimFont.ascender * (claimSize / claimFont.unitsPerEm);
const blockH = nameAsc + nameDesc + lineGap + claimAsc;
const nameBaseline = H / 2 - blockH / 2 + nameAsc;
const claimBaseline = nameBaseline + nameDesc + lineGap + claimAsc;

// Lay out each glyph manually from its stored path commands. opentype.js's Glyph.getPath() mutates
// a REUSED glyph object, so the 2nd occurrence of a letter (e.g. the "h" in "highlighter" after the
// "h" in "The") comes back with NaN coords and truncates the render. Reading glyph.path.commands is
// read-only, and we position + flip (font y-up -> SVG y-down) per glyph ourselves. No kern/GPOS.
function textPath(f, text, x, y, size) {
  const s = size / f.unitsPerEm;
  const n = (v) => (Math.round(v * 100) / 100);
  let cx = x, d = "";
  for (const ch of text) {
    const g = f.charToGlyph(ch);
    const px = (v) => n(cx + v * s), py = (v) => n(y - v * s);
    for (const c of g.path.commands) {
      if (c.type === "M") d += `M${px(c.x)} ${py(c.y)}`;
      else if (c.type === "L") d += `L${px(c.x)} ${py(c.y)}`;
      else if (c.type === "C") d += `C${px(c.x1)} ${py(c.y1)} ${px(c.x2)} ${py(c.y2)} ${px(c.x)} ${py(c.y)}`;
      else if (c.type === "Q") d += `Q${px(c.x1)} ${py(c.y1)} ${px(c.x)} ${py(c.y)}`;
      else if (c.type === "Z") d += "Z";
    }
    cx += g.advanceWidth * s;
  }
  return d;
}
const namePath = textPath(font, NAME, textX, nameBaseline, nameSize);
const claimPath = textPath(claimFont, CLAIM, textX, claimBaseline, claimSize);

// Embed the logo as a <g transform> (no nested <svg> viewport → no clipping).
const iconInner = readFileSync(join(__dir, "icon.svg"), "utf8")
  .replace(/<\?xml[^>]*\?>\s*/, "")
  .replace(/^[\s\S]*?<svg[^>]*>/, "")
  .replace(/<\/svg>\s*$/, "");

const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">
  <rect width="${W}" height="${H}" fill="#ffffff"/>
  <g transform="translate(${LX},${LY}) scale(${(LW / 48).toFixed(4)})">${iconInner}</g>
  <path d="${namePath}" fill="${NAME_FILL}"/>
  <path d="${claimPath}" fill="${CLAIM_FILL}"/>
</svg>
`;
writeFileSync(join(__dir, "banner.svg"), svg);
writeFileSync(join(__dir, "banner.png"), new Resvg(svg, { background: "#ffffff", fitTo: { mode: "width", value: W } }).render().asPng());
console.log("banner.svg + banner.png written");
