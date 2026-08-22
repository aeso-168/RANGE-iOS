# LASAL

Full-screen swipe iPhone app (arm64, iOS 17+) that helps people with visual impairment sense proximity to objects.

Merged with [AtharvSP04/LASAL](https://github.com/AtharvSP04/LASAL): double-tap starts **ObstacleDetector** (LiDAR 3×3 grid + haptics). Hold volume up + volume down for 2s to open their heatmap **ContentView** as the debug overlay.

Home-screen name, product, target, and scheme: **LASAL**. Open `RANGE.xcodeproj` (folder name is unchanged).

## Gestures

- Swipe up — next page (Disclaimer → Language → Intensity → loop)
- Swipe down — previous page
- Swipe left — language / intensity settings
- Swipe right — back to the menu
- Double tap — start / stop ObstacleDetector
- Press and hold — repeat the current page narration (also reads intensity on selection pages)
- Hold both volume keys 2 seconds — ObstacleDetector debug (heatmap + 3×3 grid)

## Open in Xcode

1. Download the ZIP or clone this repo.
2. Open **RANGE.xcodeproj**.
3. Select the **LASAL** scheme.
4. Signing & Capabilities → Team → your Apple ID.
5. Run on a LiDAR iPhone (12 Pro or later) for real depth.
