# FileRise Mobile (Capacitor)

A lightweight iOS/Android companion app for connecting to one or more FileRise servers.  
Works great with FileRise v1.8.2+.

![FileRise-Mobile](https://github.com/user-attachments/assets/7ae89713-98f3-423f-898f-3c8f03a56b66)


## Features
- Save multiple FileRise servers; quick switcher
- Online/offline indicator & verification
- In-app “FileRise Switcher” bottom sheet (gesture-friendly)
- iOS safe-area and double-tap/pinch zoom disabled for app-like feel

## Build

```bash
npm i
npx cap sync
# iOS
npx cap open ios   # open Xcode, select Team & run on device
# Android
npx cap open android
```

## App icons

Source: app/assets/logo.svg
Generated iOS asset catalog: ios/App/App/Assets.xcassets/AppIcon.appiconset/

