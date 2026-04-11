# Changelog

## 2.0.0

This is a major modernization release. The core plugin architecture, native iOS integration, and public API surface have all changed significantly since 1.4.0.

### Breaking changes

- **Swift Package Manager only.** CocoaPods support has been removed. Run `flutter config --enable-swift-package-manager` and rebuild your iOS app. See the README migration guide.
- **iOS minimum raised to 13.0.** The previous floor of iOS 9.0 has been dropped. All iOS 9–12 compatibility branches and workarounds have been removed from the native code.
- **Dart SDK raised to `^3.11.0`.** The package no longer supports Dart 2 or pre-Dart-3 SDK ranges.
- **Flutter minimum raised to `>=3.41.0`.** Older Flutter stable releases are no longer supported.
- **`AppleMapController.dispose()` is now `async`.** Awaiting it ensures the native view is torn down cleanly before the Dart controller is discarded.
- **`takeSnapshot` signature changed.** The method now accepts an optional `SnapshotOptions` parameter: `Future<Uint8List?> takeSnapshot([SnapshotOptions options])`.

### New features

- **`getLatLng(Offset)`** — convert a screen pixel coordinate back to a geographic `LatLng`. Completes the round-trip projection pair with `getScreenCoordinate`.
- **`mapType: MapType.hybrid` and `MapType.satellite`** now use `MKHybridMapConfiguration` and `MKImageryMapConfiguration` on iOS 16+, enabling native configuration-driven rendering.
- **`emphasisStyle`** (`MapEmphasisStyle.defaultStyle` / `MapEmphasisStyle.muted`) — controls the visual weight of labels and icons on standard maps. Requires iOS 16; no-op on earlier versions.
- **`selectableFeatures`** (`Set<MapSelectableFeature>`) — opt-in categories of native map elements that fire a tap event. Supports `pointsOfInterest`, `territories`, and `physicalFeatures`. Requires iOS 16.
- **`onFeatureTapped`** (`void Function(MapFeature)`) — callback fired when the user taps a native map element. The `MapFeature` carries the coordinate, `featureType`, `title`, and (for POIs) the `pointOfInterestCategory`. Requires iOS 16.
- **`onPermissionDenied`** — callback fired when the user denies location permission while `myLocationEnabled` is true.
- **Annotation clustering** — set `clusteringIdentifier` on `Annotation` to enable native `MKAnnotationView` cluster grouping. Annotations with the same identifier merge as the map zooms out.
- **`SnapshotOptions`** — new class controlling what is included in a snapshot: `showBuildings`, `showPointsOfInterest`, `showAnnotations`, `showOverlays`.
- **`cameraTargetBounds`** is now fully wired through to the iOS native layer. Previously the field was present in the Dart API but had no native effect.
- **Privacy manifest** (`PrivacyInfo.xcprivacy`) is now included in the Swift Package Manager bundle. The plugin declares no tracking and no data collection.

### Architecture changes

- **Typed Pigeon channel boundary.** All Dart ↔ Swift communication now goes through a generated typed API (`lib/src/messages.g.dart` / `Messages.g.swift`). Raw `MethodChannel` string dispatch has been removed from the production code path.
- **Per-instance channel naming.** Each map widget gets its own Pigeon channel suffixed with the map view ID. Multiple maps on the same screen no longer share state.
- **No more shared static camera state.** The previous `MKMapView` extension held camera state in static fields, meaning multiple map instances could interfere with one another. State is now stored per-instance inside `AppleMapController.swift`.
- **`applyOptions` replaces `interpretOptions`.** The native map option application path was rewritten from stringly-typed parameter extraction to a typed struct passed from Pigeon. The Swift function is now `applyOptions(_:)` rather than `interpretOptions(_:)`.
- **Modern MapKit configuration on iOS 16+.** The native layer uses `MKMapView.preferredConfiguration` and the `MKStandardMapConfiguration` / `MKHybridMapConfiguration` / `MKImageryMapConfiguration` API instead of the legacy integer-based `mapType` property where available.
- **Camera event deduplication.** Camera move events were previously emitted from both gesture recognizers and delegate callbacks. Events are now gated so each user interaction produces exactly one `onCameraMove` / `onCameraIdle` pair.
- **Snapshot fallback.** When `MKMapSnapshotter` returns a server-failure error (e.g. no network), the plugin falls back to rendering the live map view directly rather than returning nil.

### Bug fixes

- Fixed a crash in `getAnnotationView()` caused by an unsafe `as! FlutterAnnotationView` downcast on marker and pin annotation views.
- Fixed `wasDragged` flag being set on every annotation tap, which caused the first overlay update after a tap to be silently discarded.
- Fixed overlay `==` and `hashCode` implementations for `Polyline`, `Polygon`, and `Circle` to include list fields (`points`, `patterns`). Previously two overlays with different coordinates could compare as equal, preventing updates from being sent to the native layer.
- Fixed `emphasisStyle` resetting to `defaultStyle` when the map type was switched by persisting the emphasis style independently of the map configuration object.
- Fixed the bounds check in `trackingMode` and `mapType` index handling on the native side to guard against out-of-range values.
- Fixed overlay ID unwrapping: `String?` IDs from Pigeon `FlutterApi` callbacks are now properly unwrapped before use.

### Example app

The example app has been fully rewritten using Material 3 with a `MapScaffold` component (full-screen map + draggable bottom sheet for controls). The old collection of loosely organized pages has been replaced with thirteen focused demo screens:

- Map appearance (map type, emphasis style, UI toggles)
- Camera control (animate, move, zoom, bounds)
- Camera bounds (min/max zoom, target bounds restriction)
- Gestures (gesture enable/disable, my-location toggle)
- Map events (tap, long press, camera move event log)
- Location tracking (tracking mode, permission flow)
- Annotations (icons, info windows, dragging, visibility)
- Annotation clustering (toggle clustering on 30 annotations)
- Polylines (width, color, caps, joints, dash patterns)
- Polygons (fill, stroke, alpha, visibility, tap)
- Circles (radius, fill, stroke, alpha, visibility, tap)
- Projection (visible region, screen↔geo round-trip)
- Map padding (padding sliders, safe-area inset toggle)
- Snapshots (`SnapshotOptions`, PNG preview)

### CI

- Moved iOS CI to a self-hosted macOS runner with a toolchain preflight script that validates Xcode version, Flutter channel, and simulator UDID before running tests.
- CI now runs `flutter pub publish --dry-run` on every push to master.
- CI builds both debug and release iOS targets before running integration tests on the simulator.

---

## 1.4.0

* Flutter 3.27.1 compatibility, replace `ui.hash*` with `Object.hash*`

## 1.3.0

* Animate marker position changes instead of removing and re-adding
* Fix Fatal error: Attempted to read an unowned reference but the object was already deallocated
* Fixed an issue where onCameraMove was not invoked by double-tapping
* Added insetsLayoutMarginsFromSafeArea

## 1.2.0

* Added a `markerAnnotationWithHue()` and `pinAnnotationWithHue()` method to allow custom marker/pin colors

## 1.1.0

* Added Annotation zIndex
* Added posibility to take snapshots of the map

## 1.0.3

* Fixes an issue where mapController.moveCamera would animate the camera transition
* To animate a camera movement, mapController.animateCamera should be used instead

## 1.0.2

* Removed Android folder to fix build failures

## 1.0.1

* Fixes memory leak
* Adds ability to take snapshots of the map

## 1.0.0

Thanks to @jonbhanson
* Adds null safety.
* Refreshes the example app.
* Updates .gitignore and removes files that should not be tracked.

## 0.1.4

* Animate to bounds was added. (Thanks to @nghiashiyi)
* Fixed an issue where the user location was only displayed in `authorizationInUse` status. (Thanks to @zgosalvez)
* Minor fixes

## 0.1.3

* Thanks to @maxiundtesa the getter for the current zoomLevel was added
* iOS build failure for Flutter modules was fixed

## 0.1.2+5

* Fixed build failure
* Added anchor param to Annotation
* Added missing comparison of Overlay coordinates, which caused Circles, Annotations, Polylines and Polygons to not update correctly on coordinate changes.

## 0.1.2+4

* Added configurable Anchor for infoWindows

## 0.1.2+3

* Fixed the offset of custom markers

## 0.1.2+2

* Fixed the onTap event for Annotation Callouts

## 0.1.2+1

* Added custom annotation icons from byte data
* Fixed scaling of icons from assets

## 0.1.2

* Annotation rework:
  * onTap for InfoWindow added
  * Multiline InfoWindow subtitle support
  * Overall Annotation handling refactored
  * Correct UserTracking Button added

## 0.1.1+2

* Fixed map freezing when setState is being called

## 0.1.1+1

* Fixed Polygon and Circle Tap events.

## 0.1.1

* Added markerAnnotation as selectable annotation type.

## 0.1.0

* Added ability to place circles on the map.

## 0.0.7

* Added ability to place polygons on the map.

## 0.0.6+2

* Converted iOS code to swift 5.

## 0.0.6+1

* Changed annotation initialisation, fixes custom annotation icons not showing up on the map.

## 0.0.6

* Added ability to add padding to the map

## 0.0.5

* Added ability to place polylines.

## 0.0.4

* Fixed error when updating Annotations on map.

## 0.0.3

* Added getter for visible map region.

## 0.0.2

* Added zoomBy functionality.
* Added setter for min and max zoom levels.

## 0.0.1

* Initial release.
