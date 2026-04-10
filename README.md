# apple_maps_flutter

[![codecov](https://codecov.io/gh/ChristopherLinnett/apple_maps_flutter/branch/master/graph/badge.svg)](https://codecov.io/gh/ChristopherLinnett/apple_maps_flutter)

A Flutter plugin that provides an Apple Maps widget.

This fork targets current Flutter and Apple toolchains and supports Apple Maps on iOS through Flutter platform views.

The package still follows the familiar `google_maps_flutter`-style API shape where practical, while adopting Apple-native behavior deliberately when MapKit semantics differ.

## Compatibility

- Flutter: `>=3.41.0`
- Dart: `^3.11.0`
- iOS deployment target: `13.0`
- Modern MapKit configuration APIs are feature-gated for iOS `16+`
- iOS dependency managers: CocoaPods and Swift Package Manager

## Current feature surface

| Capability | Status |
| :--------- | :----- |
| Embedded Apple map view | Supported |
| Camera move and animate operations | Supported |
| Annotations | Supported |
| Polylines, polygons, and circles | Supported |
| Visible region and screen coordinate APIs | Supported |
| Snapshots | Supported |
| Android implementation | Not included |

# Screenshots

|                                     Example 1                                     |                                     Example 2                                     |
| :-------------------------------------------------------------------------------: | :-------------------------------------------------------------------------------: |
| ![Example 1](https://luisthein.de/apple-maps-plugin-images/example_img01-min.png) | ![Example 2](https://luisthein.de/apple-maps-plugin-images/example_img02-min.png) |

# iOS

Add `NSLocationWhenInUseUsageDescription` to the host app if you enable user location features.

If you want to validate Swift Package Manager integration locally, enable it with `flutter config --enable-swift-package-manager` before building the example app.

# Android

There is no Android implementation, but there is a package combining apple_maps_flutter and the google_maps_flutter plugin to have the typical map implementations for Android/iOS called platform_maps_flutter.

## Sample Usage

```dart
class AppleMapsExample extends StatefulWidget {
  const AppleMapsExample({super.key});

  @override
  State<AppleMapsExample> createState() => _AppleMapsExampleState();
}

class _AppleMapsExampleState extends State<AppleMapsExample> {
  AppleMapController? mapController;

  void _onMapCreated(AppleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: Container(
            child: AppleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(0.0, 0.0),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    mapController?.moveCamera(
                      CameraUpdate.newCameraPosition(
                        const CameraPosition(
                          heading: 270.0,
                          target: LatLng(51.5160895, -0.1294527),
                          pitch: 30.0,
                          zoom: 17,
                        ),
                      ),
                    );
                  },
                  child: const Text('newCameraPosition'),
                ),
                TextButton(
                  onPressed: () {
                    mapController?.moveCamera(
                      CameraUpdate.newLatLngZoom(
                        const LatLng(37.4231613, -122.087159),
                        11.0,
                      ),
                    );
                  },
                  child: const Text('newLatLngZoom'),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    mapController?.moveCamera(
                      CameraUpdate.zoomIn(),
                    );
                  },
                  child: const Text('zoomIn'),
                ),
                TextButton(
                  onPressed: () {
                    mapController?.moveCamera(
                      CameraUpdate.zoomOut(),
                    );
                  },
                  child: const Text('zoomOut'),
                ),
                TextButton(
                  onPressed: () {
                    mapController?.moveCamera(
                      CameraUpdate.zoomTo(16.0),
                    );
                  },
                  child: const Text('zoomTo'),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
```

Suggestions and PR's to make this plugin better are always welcome.
