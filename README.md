# RANGE

Full-screen swipe iPhone app (arm64, iOS 17+) with spoken pages, intensity / language rollers, and LiDAR sensing.

## Open in Xcode

1. Download the ZIP from this repo (Code → Download ZIP) or clone it.
2. Unzip. You should see `RANGE.xcodeproj` next to a `RANGE` folder.
3. Double-click **RANGE.xcodeproj** (Xcode 15 or later).
4. In the toolbar, choose the **RANGE** scheme and an **iPhone simulator** or a plugged-in iPhone.
5. Select the RANGE target → **Signing & Capabilities**.
6. Check **Automatically manage signing** and pick your **Team** (Apple ID).
7. Press **Run** (⌘R).

### If it still says Build Failed

Xcode’s error is almost always one of these:

| Message | Fix |
|---|---|
| Signing for "RANGE" requires a development team | Target → Signing & Capabilities → Team → your Apple ID |
| Failed to register bundle identifier | Change the bundle ID to something unique, e.g. `com.yourname.range` |
| Requires a device with arkit | Use this latest project — Simulator is allowed |
| No such module ARKit | Xcode Settings → Platforms → install **iOS 17+** |
| App icon unassigned | Product → Clean Build Folder, then Run again |

True LiDAR depth uses ARKit `sceneDepth` on **iPhone 12 Pro and later**. Other iPhones and the Simulator fall back to AR feature points.

## Gestures

- Swipe down — next page (Disclaimer → Intensity → Language → loop)
- Swipe up — previous page
- Swipe right — open intensity (1–5) or language (Chinese / English / Hindi) roller
- Swipe left — return to the stack
- Double tap — start / stop LiDAR sensing
- Hold both volume keys 2 seconds — debug
