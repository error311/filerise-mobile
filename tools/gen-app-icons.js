#!/usr/bin/env node
// Generate iOS AppIcon.appiconset from an SVG, centered with blue padding.
// Usage:
//   node tools/gen-app-icons.js app/assets/logo.png ios/App/App/Assets.xcassets/AppIcon.appiconset -p 0.16
//   (padding is a fraction 0..0.4; smaller pad => bigger logo)

const fs = require("fs");
const path = require("path");
const sharp = require("sharp");

const argv = process.argv.slice(2);
const opts = { pad: 0.16 }; // default: bigger logo than before (was 0.22)

const pos = [];
for (let i = 0; i < argv.length; i++) {
  const a = argv[i];
  if (a === "-p" || a === "--pad") {
    const v = parseFloat(argv[i + 1]); i++;
    if (!Number.isNaN(v)) opts.pad = v;
  } else if (a.startsWith("--pad=")) {
    const v = parseFloat(a.split("=")[1]);
    if (!Number.isNaN(v)) opts.pad = v;
  } else {
    pos.push(a);
  }
}

const INPUT  = pos[0] || "app/assets/logo.png";
const OUTSET = pos[1] || "ios/App/App/Assets.xcassets/AppIcon.appiconset";

const BG_TOP    = "#29B6F6";
const BG_BOTTOM = "#2196F3";
const CANVAS    = 1024;

const sizes = [
  {size:20,  scales:[2,3], idiom:"iphone"},
  {size:29,  scales:[2,3], idiom:"iphone"},
  {size:40,  scales:[2,3], idiom:"iphone"},
  {size:60,  scales:[2,3], idiom:"iphone"},
  {size:20,  scales:[1,2], idiom:"ipad"},
  {size:29,  scales:[1,2], idiom:"ipad"},
  {size:40,  scales:[1,2], idiom:"ipad"},
  {size:76,  scales:[1,2], idiom:"ipad"},
  {size:83.5,scales:[2],   idiom:"ipad"},
  {size:1024,scales:[1],   idiom:"ios-marketing"},
];

function bgSVG(w,h){
  return Buffer.from(
`<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}">
  <defs>
    <linearGradient id="g" x1="0" y1="1" x2="1" y2="0">
      <stop offset="0" stop-color="${BG_BOTTOM}"/>
      <stop offset="1" stop-color="${BG_TOP}"/>
    </linearGradient>
  </defs>
  <rect width="${w}" height="${h}" fill="url(#g)"/>
</svg>`);
}

async function makeMaster(svgIn, outPng){
  const pad = Math.max(0, Math.min(0.4, Number(opts.pad) || 0.16));
  const logoSize = Math.round(CANVAS * (1 - 2 * pad));
  const offset   = Math.round((CANVAS - logoSize) / 2);

  const background = sharp(bgSVG(CANVAS, CANVAS)).png();
  const logoBuf = await sharp(svgIn)
    .resize(logoSize, logoSize, { fit: "contain" })
    .toBuffer();

  await background
    .composite([{ input: logoBuf, left: offset, top: offset }])
    .png()
    .toFile(outPng);
}

function contentsJSON(){
  const images = [];
  for (const row of sizes){
    for (const s of row.scales){
      const filename = row.idiom === "ios-marketing"
        ? "AppIcon-1024.png"
        : `AppIcon-${row.size}@${s}x.png`;
      images.push({
        size: `${row.size}x${row.size}`,
        idiom: row.idiom,
        filename,
        scale: `${s}x`,
      });
    }
  }
  return { images, info: { version: 1, author: "xcode" } };
}

(async ()=>{
  try {
    fs.mkdirSync(OUTSET, { recursive: true });

    // 1) Master 1024
    const master = path.join(OUTSET, "AppIcon-1024.png");
    await makeMaster(INPUT, master);

    // 2) Downscales
    const jobs = [];
    for (const row of sizes){
      for (const s of row.scales){
        if (row.idiom === "ios-marketing") continue;
        const px = Math.round(row.size * s);
        const out = path.join(OUTSET, `AppIcon-${row.size}@${s}x.png`);
        jobs.push(sharp(master).resize(px, px, { fit: "cover" }).png().toFile(out));
      }
    }
    await Promise.all(jobs);

    // 3) Contents.json
    fs.writeFileSync(path.join(OUTSET, "Contents.json"), JSON.stringify(contentsJSON(), null, 2));
    console.log(`✓ AppIcon.appiconset generated at ${OUTSET} (pad=${opts.pad})`);
  } catch (e) {
    console.error("Icon generation failed:", e);
    process.exit(1);
  }
})();