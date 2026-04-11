# apple_maps_flutter

[![CI](https://github.com/ChristopherLinnett/apple_maps_flutter/actions/workflows/dart.yml/badge.svg)](https://github.com/ChristopherLinnett/apple_maps_flutter/actions/workflows/dart.yml)
[![codecov](https://codecov.io/gh/ChristopherLinnett/apple_maps_flutter/branch/master/graph/badge.svg)](https://codecov.io/gh/ChristopherLinnett/apple_maps_flutter)
[![pub package](https://img.shields.io/pub/v/apple_maps_flutter.svg)](https://pub.dev/packages/apple_maps_flutter)

A Flutter plugin that provides an Apple Maps widget backed by MapKit on iOS.

This is a fully modernized fork targeting current Flutter, Dart, Swift, and MapKit baselines. The plugin uses a typed [Pigeon](https://pub.dev/packages/pigeon) channel boundary, supports Swift Package Manager, and surfaces modern MapKit configuration APIs alongside the established core feature set.

## Requirements

| Requirement | Minimum |
| :---------- | :------ |
| Flutter | `>=3.41.0` |
| Dart | `^3.11.0` |
| iOS deployment target | `13.0` |
| Swift | `5.9` |
| Xcode | Current stable |
| iOS dependency manager | Swift Package Manager |

Modern MapKit APIs (map configuration, emphasis style, feature taps) are feature-gated for iOS 16+. The core map widget works on iOS 13+.

## Feature surface

| Capability | Status | Notes |
| :--------- | :----- | :---- |
| Embedded map view | ✅ | Full-screen or sized via parent widget |
| Camera animate and move | ✅ | All `CameraUpdate` variants |
| Camera bounds and zoom constraints | ✅ | `MinMaxZoomPreference`, `CameraTargetBounds` |
| Annotations | ✅ | Custom icons, info windows, dragging, clustering |
| Polylines | ✅ | Width, color, caps, joints, dash patterns |
| Polygons | ✅ | Fill, stroke, tap events |
| Circles | ✅ | Center, radius, fill, stroke |
| Visible region query | ✅ | `getVisibleRegion()` returns `LatLngBounds` |
| Screen ↔ geo projection | ✅ | `getScreenCoordinate` and `getLatLng` (round-trip) |
| My location and tracking | ✅ | `none`, `follow`, `followWithHeading` tracking modes |
| Location permission flow | ✅ | `onPermissionDenied` callback when user denies |
| Map appearance | ✅ | Standard, satellite, hybrid |
| Modern map configuration | ✅ | `MKStandardMapConfiguration`, emphasis style (iOS 16+) |
| Traffic display | ✅ | `trafficEnabled` |
| Compass, scale, compass gestures | ✅ | Individually toggleable |
| Snapshots | ✅ | `takeSnapshot()` with `SnapshotOptions` |
| Native feature taps | ✅ | POIs, territories, physical features (iOS 16+) |
| Android implementation | ❌ | iOS only |

## Setup

### 1. Enable Swift Package Manager

This package requires Swift Package Manager. Run once before building the iOS host app:

```bash
flutter config --enable-swift-package-manager
```

### 2. Add the dependency

```yaml
dependencies:
  apple_maps_flutter: ^2.0.0
```

### 3. Add the usage description

If you call `myLocationEnabled: true`, add `NSLocationWhenInUseUsageDescription` to your app's `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app uses your location to show it on the map.</string>
```

### Migrating from CocoaPods

If you previously used this package with CocoaPods:

1. Remove `Podfile`, `Podfile.lock`, and the `Pods/` directory from your `ios/` folder.
2. Remove the `pod` invocations from your `ios/Runner.xcodeproj` build phases if manually edited.
3. Enable Swift Package Manager (`flutter config --enable-swift-package-manager`).
4. Run `flutter pub get` and `flutter build ios` to regenerate the Xcode project.

## Basic usage

```dart
import 'package:flutter/material.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  AppleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(51.5074, -0.1278),
          zoom: 12,
        ),
        onMapCreated: (controller) => _controller = controller,
        compassEnabled: true,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onTap: (latLng) => debugPrint('Tapped $latLng'),
      ),
    );
  }
}
```

## Camera control

```dart
// Animate the camera to a new position
final controller = _controller;
if (controller != null) {
  await controller.animateCamera(
    CameraUpdate.newCameraPosition(
      const CameraPosition(
        target: LatLng(51.5074, -0.1278),
        zoom: 14,
        pitch: 30,
        heading: 90,
      ),
    ),
  );
}

// Constrain zoom levels
AppleMap(
  initialCameraPosition: ...,
  minMaxZoomPreference: const MinMaxZoomPreference(10, 18),
);

// Restrict camera target to a region
AppleMap(
  initialCameraPosition: ...,
  cameraTargetBounds: CameraTargetBounds(
    LatLngBounds(
      southwest: const LatLng(50.0, -2.0),
      northeast: const LatLng(53.0, 2.0),
    ),
  ),
);
```

## Annotations

```dart
AppleMap(
  initialCameraPosition: ...,
  annotations: {
    Annotation(
      annotationId: const AnnotationId('marker_1'),
      position: const LatLng(51.5074, -0.1278),
      infoWindow: const InfoWindow(
        title: 'London',
        snippet: 'Capital of England',
      ),
      icon: BitmapDescriptor.defaultAnnotation,
      draggable: true,
      onTap: () => debugPrint('Tapped'),
      onDragEnd: (pos) => debugPrint('Dragged to $pos'),
    ),
  },
)
```

### Annotation clustering

Set a `clusteringIdentifier` on annotations that should cluster together when they are close on screen. Annotations with the same identifier will merge into a cluster marker as the user zooms out.

```dart
Annotation(
  annotationId: ...,
  position: ...,
  clusteringIdentifier: 'my_cluster',
)
```

## Overlays

```dart
AppleMap(
  initialCameraPosition: ...,
  polylines: {
    Polyline(
      polylineId: const PolylineId('route'),
      points: const [LatLng(51.5, -0.1), LatLng(51.6, -0.2)],
      color: Colors.blue,
      width: 4,
      polylineCap: Cap.roundCap,
    ),
  },
  polygons: {
    Polygon(
      polygonId: const PolygonId('area'),
      points: const [
        LatLng(51.50, -0.12),
        LatLng(51.51, -0.10),
        LatLng(51.49, -0.09),
      ],
      fillColor: Colors.blue.withOpacity(0.3),
      strokeColor: Colors.blue,
      strokeWidth: 2,
    ),
  },
  circles: {
    Circle(
      circleId: const CircleId('zone'),
      center: const LatLng(51.5074, -0.1278),
      radius: 500,
      fillColor: Colors.green.withOpacity(0.2),
      strokeColor: Colors.green,
    ),
  },
)
```

## Location and tracking

```dart
AppleMap(
  initialCameraPosition: ...,
  myLocationEnabled: true,
  myLocationButtonEnabled: true,
  trackingMode: TrackingMode.followWithHeading,
  onPermissionDenied: () {
    // Called when the user denies location permission.
    // Show a dialog or navigate to Settings.
  },
)
```

## Map appearance

```dart
// Map type
AppleMap(
  initialCameraPosition: ...,
  mapType: MapType.hybrid,  // standard | satellite | hybrid
)

// Muted appearance — reduces label/icon prominence for overlay-heavy layouts.
// Requires iOS 16+; has no effect on older OS versions.
AppleMap(
  initialCameraPosition: ...,
  emphasisStyle: MapEmphasisStyle.muted,
)
```

## Projection and visible region

```dart
// Get the visible map bounds
final LatLngBounds bounds = await _controller!.getVisibleRegion();

// Convert a geographic coordinate to a screen pixel offset
final Offset? point = await _controller!.getScreenCoordinate(
  const LatLng(51.5074, -0.1278),
);

// Convert a screen pixel offset back to a geographic coordinate
final LatLng? latLng = await _controller!.getLatLng(Offset(200, 300));
```

## Snapshots

```dart
final controller = _controller;
if (controller != null) {
  final Uint8List? bytes = await controller.takeSnapshot(
    const SnapshotOptions(
      showBuildings: true,
      showPointsOfInterest: true,
      showAnnotations: true,
      showOverlays: true,
    ),
  );
  if (bytes != null) {
    // Display or save the image bytes
  }
}
```

## Native feature taps (iOS 16+)

Listen for taps on native map elements such as restaurants, parks, or country labels:

```dart
AppleMap(
  initialCameraPosition: ...,
  selectableFeatures: const {
    MapSelectableFeature.pointsOfInterest,
    MapSelectableFeature.territories,
  },
  onFeatureTapped: (MapFeature feature) {
    debugPrint('Tapped: ${feature.title} (${feature.featureType})');
    debugPrint('Location: ${feature.coordinate}');
    debugPrint('POI category: ${feature.pointOfInterestCategory}');
  },
)
```

Feature taps are distinct from annotation taps and require iOS 16 or later. On earlier iOS versions the callback is never invoked regardless of `selectableFeatures`.

## Controller API

| Method | Description |
| :----- | :---------- |
| `animateCamera(update)` | Animate the camera to a new position |
| `moveCamera(update)` | Jump the camera without animation |
| `getZoomLevel()` | Return the current zoom level |
| `getVisibleRegion()` | Return the current visible `LatLngBounds` |
| `getScreenCoordinate(latLng)` | Convert geo → screen pixel |
| `getLatLng(offset)` | Convert screen pixel → geo |
| `showMarkerInfoWindow(id)` | Show the info window for an annotation |
| `hideMarkerInfoWindow(id)` | Hide the info window for an annotation |
| `isMarkerInfoWindowShown(id)` | Query info window visibility |
| `takeSnapshot([options])` | Capture the map as PNG bytes |
| `dispose()` | Release the controller and native resources |

## Architecture

### Typed channel boundary (Pigeon)

All communication between Dart and the native Swift host goes through a fully typed [Pigeon](https://pub.dev/packages/pigeon) API defined in `pigeons/messages.dart`. There are no raw `MethodChannel` string dispatches in the production code path — every message has a generated typed wrapper. The generated files are `lib/src/messages.g.dart` (Dart) and `ios/.../Messages.g.swift` (Swift).

### Per-instance state

Each `AppleMap` widget gets its own named Pigeon channel (suffixed with the map view ID). There is no shared static state between map instances. Multiple maps on the same screen are fully independent.

### Modern MapKit configuration (iOS 16+)

On iOS 16 and later the plugin uses `MKMapView.preferredConfiguration` with `MKStandardMapConfiguration`, `MKHybridMapConfiguration`, or `MKImageryMapConfiguration` instead of the legacy `mapType` integer. This enables traffic display, emphasis style, and point-of-interest filtering through the native configuration API rather than ad-hoc overrides. On iOS 13–15 the plugin falls back to the equivalent legacy APIs.

### Swift Package Manager only

CocoaPods support was removed in 2.0.0. The iOS integration uses Swift Package Manager exclusively. The plugin ships with a `PrivacyInfo.xcprivacy` manifest — no user tracking, no data collection.

## Android

There is no Android implementation. If you need cross-platform maps, see [platform_maps_flutter](https://pub.dev/packages/platform_maps_flutter).

## Contributing

Pull requests are welcome. Before submitting, please ensure:

```bash
flutter analyze
flutter test
cd example && flutter build ios --no-codesign
```
