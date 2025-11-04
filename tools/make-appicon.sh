#!/usr/bin/env bash
set -euo pipefail

# --- paths (edit if needed)
LOGO_IN="app/assets/logo.svg"      # transparent logo (white-on-transparent looks best)
OUT_DIR="resources"
ICON_OUT="$OUT_DIR/icon.svg"

# --- colors (match your index tile vibe)
C1="#64B5F6"  # light
C2="#2196F3"  # mid
C3="#1976D2"  # dark

# --- checks
command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1 || {
  echo "ImageMagick not found. On macOS: brew install imagemagick"; exit 1;
}

if [ ! -f "$LOGO_IN" ]; then
  echo "Logo not found at $LOGO_IN"; exit 1;
fi

mkdir -p "$OUT_DIR"

# --- Render a 1024×1024 gradient background
# Using a simple vertical gradient that blends your three blues.
if command -v magick >/dev/null 2>&1; then
  # Newer ImageMagick
  magick -size 1024x1024 gradient:"$C1-$C2" \
    \( -size 1024x1024 gradient:"$C2-$C3" -rotate 90 \) -compose overlay -composite \
    -colorspace sRGB png32:"$OUT_DIR/bg.png"
else
  # Older "convert" binary
  convert -size 1024x1024 gradient:"$C1-$C2" \
    \( -size 1024x1024 gradient:"$C2-$C3" -rotate 90 \) -compose overlay -composite \
    -colorspace sRGB png32:"$OUT_DIR/bg.png"
fi

# --- Composite logo centered with safe padding (about 68% of the canvas)
# Adjust SCALE if you want the logo bigger/smaller inside the tile.
SCALE=68
if command -v magick >/dev/null 2>&1; then
  magick "$OUT_DIR/bg.png" \
    \( "$LOGO_IN" -resize "${SCALE}%" \) -gravity center -compose over -composite \
    -colorspace sRGB png32:"$ICON_OUT"
else
  convert "$OUT_DIR/bg.png" \
    \( "$LOGO_IN" -resize "${SCALE}%" \) -gravity center -compose over -composite \
    -colorspace sRGB png32:"$ICON_OUT"
fi

echo "✅ Wrote $ICON_OUT"

# --- Generate all platform sizes
# Looks for resources/icon.png by default.
npx -y @capacitor/assets generate --ios --android

echo "🎉 App icons updated. Now run:
  npx cap sync ios android
  npx cap open ios   # or Android Studio for Android
"