# RANGE

Full-screen swipe iPhone app (arm64, iOS 17+) with spoken pages, intensity / language rollers, and LiDAR sensing.

## Download

- **[Download ZIP](https://github.com/aeso-168/RANGE-iOS/archive/refs/heads/main.zip)**
- Or clone: `git clone https://github.com/aeso-168/RANGE-iOS.git`

## Open in Xcode

1. Unzip (or clone) this repo.
2. Open `RANGE.xcodeproj` in **Xcode 15+**.
3. Select the RANGE target → **Signing & Capabilities** → pick your **Team**.
4. Plug in an iPhone (iOS 17+, arm64) and press **Run**.

True LiDAR depth uses ARKit `sceneDepth` on **iPhone 12 Pro and later**. Other iPhones fall back to AR feature points. Background sensing uses the audio background mode plus a silent keep-alive.

## Gestures

| Gesture | Action |
|---|---|
| Swipe down | Next page (Disclaimer → Intensity → Language → loop) |
| Swipe up | Previous page |
| Swipe right | Open intensity (1–5) or language (Chinese / English / Hindi) roller |
| Swipe left | Return to the stack |
| Double tap | Start / stop LiDAR sensing |
| Hold both volume keys 2s | Debug |

Pages speak their name on entry. Rollers speak the selected value.

## Project layout

```
RANGE.xcodeproj
RANGE/
  RANGEApp.swift
  ContentView.swift
  AppStore.swift
  Announcer.swift
  LidarSession.swift
  Info.plist
  Assets.xcassets
```
