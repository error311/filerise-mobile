#!/usr/bin/env bash
set -euo pipefail

SRC="${1:-}"
if [[ -z "$SRC" || ! -f "$SRC" ]]; then
  echo "Usage: $0 path/to/logo.png"; exit 1
fi

# Tools
INK="inkscape"
CONVERT="convert"

out_png () { # out_png DEST SIZE
  local dest="$1"; local sz="$2"
  mkdir -p "$(dirname "$dest")"
  $INK "$SRC" --export-type=png -w "$sz" -h "$sz" -o "$dest"
}

# ---------- iOS ----------
IOS_DIR="ios/App/App/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$IOS_DIR"

# iPhone
out_png "$IOS_DIR/Icon-App-20x20@2x.png"   40
out_png "$IOS_DIR/Icon-App-20x20@3x.png"   60
out_png "$IOS_DIR/Icon-App-29x29@2x.png"   58
out_png "$IOS_DIR/Icon-App-29x29@3x.png"   87
out_png "$IOS_DIR/Icon-App-40x40@2x.png"   80
out_png "$IOS_DIR/Icon-App-40x40@3x.png"  120
out_png "$IOS_DIR/Icon-App-60x60@2x.png"  120
out_png "$IOS_DIR/Icon-App-60x60@3x.png"  180

# iPad
out_png "$IOS_DIR/Icon-App-20x20@1x~ipad.png"   20
out_png "$IOS_DIR/Icon-App-20x20@2x~ipad.png"   40
out_png "$IOS_DIR/Icon-App-29x29@1x~ipad.png"   29
out_png "$IOS_DIR/Icon-App-29x29@2x~ipad.png"   58
out_png "$IOS_DIR/Icon-App-40x40@1x~ipad.png"   40
out_png "$IOS_DIR/Icon-App-40x40@2x~ipad.png"   80
out_png "$IOS_DIR/Icon-App-76x76@1x~ipad.png"   76
out_png "$IOS_DIR/Icon-App-76x76@2x~ipad.png"  152
out_png "$IOS_DIR/Icon-App-83.5x83.5@2x~ipad.png" 167

# Marketing (App Store) — must have NO alpha
out_png "$IOS_DIR/ItunesArtwork@1024.png" 1024
$CONVERT "$IOS_DIR/ItunesArtwork@1024.png" -alpha off "$IOS_DIR/ItunesArtwork@1024.png"

# Contents.json
cat > "$IOS_DIR/Contents.json" <<'JSON'
{
  "images": [
    { "size": "20x20",  "idiom": "iphone", "filename": "Icon-App-20x20@2x.png", "scale":"2x" },
    { "size": "20x20",  "idiom": "iphone", "filename": "Icon-App-20x20@3x.png", "scale":"3x" },
    { "size": "29x29",  "idiom": "iphone", "filename": "Icon-App-29x29@2x.png", "scale":"2x" },
    { "size": "29x29",  "idiom": "iphone", "filename": "Icon-App-29x29@3x.png", "scale":"3x" },
    { "size": "40x40",  "idiom": "iphone", "filename": "Icon-App-40x40@2x.png", "scale":"2x" },
    { "size": "40x40",  "idiom": "iphone", "filename": "Icon-App-40x40@3x.png", "scale":"3x" },
    { "size": "60x60",  "idiom": "iphone", "filename": "Icon-App-60x60@2x.png", "scale":"2x" },
    { "size": "60x60",  "idiom": "iphone", "filename": "Icon-App-60x60@3x.png", "scale":"3x" },

    { "size": "20x20",  "idiom": "ipad",   "filename": "Icon-App-20x20@1x~ipad.png", "scale":"1x" },
    { "size": "20x20",  "idiom": "ipad",   "filename": "Icon-App-20x20@2x~ipad.png", "scale":"2x" },
    { "size": "29x29",  "idiom": "ipad",   "filename": "Icon-App-29x29@1x~ipad.png", "scale":"1x" },
    { "size": "29x29",  "idiom": "ipad",   "filename": "Icon-App-29x29@2x~ipad.png", "scale":"2x" },
    { "size": "40x40",  "idiom": "ipad",   "filename": "Icon-App-40x40@1x~ipad.png", "scale":"1x" },
    { "size": "40x40",  "idiom": "ipad",   "filename": "Icon-App-40x40@2x~ipad.png", "scale":"2x" },
    { "size": "76x76",  "idiom": "ipad",   "filename": "Icon-App-76x76@1x~ipad.png", "scale":"1x" },
    { "size": "76x76",  "idiom": "ipad",   "filename": "Icon-App-76x76@2x~ipad.png", "scale":"2x" },
    { "size": "83.5x83.5", "idiom": "ipad", "filename": "Icon-App-83.5x83.5@2x~ipad.png", "scale":"2x" },

    { "size": "1024x1024", "idiom": "ios-marketing", "filename": "ItunesArtwork@1024.png", "scale":"1x" }
  ],
  "info": { "version": 1, "author": "xcode" }
}
JSON

# ---------- Android ----------
# Legacy mipmaps (launcher fallback)
declare -A MIPS=( [mdpi]=48 [hdpi]=72 [xhdpi]=96 [xxhdpi]=144 [xxxhdpi]=192 )
for d in "${!MIPS[@]}"; do
  out_png "android/app/src/main/res/mipmap-$d/ic_launcher.png" "${MIPS[$d]}"
done

# Adaptive foregrounds (108dp per density)
declare -A ADP=( [mdpi]=108 [hdpi]=162 [xhdpi]=216 [xxhdpi]=324 [xxxhdpi]=432 )
for d in "${!ADP[@]}"; do
  out_png "android/app/src/main/res/mipmap-$d/ic_launcher_foreground.png" "${ADP[$d]}"
done

# Monochrome (Android 13+) — reuse foreground flattened to single color
for d in "${!ADP[@]}"; do
  out_png "android/app/src/main/res/mipmap-$d/ic_launcher_monochrome.png" "${ADP[$d]}"
  $CONVERT "android/app/src/main/res/mipmap-$d/ic_launcher_monochrome.png" -colorspace Gray -threshold 50% "android/app/src/main/res/mipmap-$d/ic_launcher_monochrome.png"
done

# Background color resource
mkdir -p android/app/src/main/res/values
cat > android/app/src/main/res/values/ic_launcher_background.xml <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<resources>
  <color name="ic_launcher_background">#2196F3</color>
</resources>
XML

# Adaptive icon XMLs
mkdir -p android/app/src/main/res/mipmap-anydpi-v26
cat > android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
  <background android:drawable="@color/ic_launcher_background"/>
  <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
  <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>
</adaptive-icon>
XML

cat > android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
  <background android:drawable="@color/ic_launcher_background"/>
  <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
  <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>
</adaptive-icon>
XML

# ---------- Web / PWA icons ----------
out_png "app/assets/icon-512.png" 512
out_png "app/assets/icon-192.png" 192

# ---------- Capacitor splash ----------
mkdir -p resources
out_png "resources/splash.png" 2732
echo "✓ Icons and splash generated."