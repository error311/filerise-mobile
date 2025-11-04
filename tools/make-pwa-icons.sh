#!/usr/bin/env bash
set -euo pipefail

SRC="${1:-app/assets/logo.svg}"    # or point this at a 1024px PNG if you prefer
OUT="public/assets/icons"
BG="#2196F3"                       # FileRise blue
mkdir -p "$OUT"

# 1) Rasterize a crisp 1024 base (transparent background preserved)
magick -density 384 "$SRC" -resize 1024x1024 PNG32:"$OUT/base-1024.png"

# 2) Plain 512 & 192 (no extra padding)
magick "$OUT/base-1024.png" -resize 512x512  PNG24:"$OUT/icon-512.png"
magick "$OUT/base-1024.png" -resize 192x192  PNG24:"$OUT/icon-192.png"

# 3) Maskable 512 with inner padding (about 20–25% safe area)
#    Shrink art to 400px and center on a 512 canvas so rounded masks don’t clip it.
magick -size 512x512 xc:none \
  "$OUT/base-1024.png" -resize 400x400 -gravity center -compose over -composite \
  PNG32:"$OUT/maskable-512.png"

# Optional: if your SVG has transparency and you want a solid blue square behind it:
# (do this instead of the maskable step above if you want blue pad)
# magick -size 512x512 xc:"$BG" \
#   "$OUT/base-1024.png" -resize 400x400 -gravity center -compose over -composite \
#   PNG24:"$OUT/maskable-512.png"

# 4) iOS PWA hint (apple-touch-icon)
magick "$OUT/base-1024.png" -resize 180x180 PNG24:"$OUT/apple-touch-icon.png"

echo "Wrote: $OUT/icon-192.png, $OUT/icon-512.png, $OUT/maskable-512.png, $OUT/apple-touch-icon.png"