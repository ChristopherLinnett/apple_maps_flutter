// Tests that pin the exact wire format produced by `_AppleMapOptions.toMap()`
// and `CameraPosition._toMap()`, and that verify the `updatesMap()` list-equality
// fix that prevents spurious map resets while scrolling.
//
// These tests exist because `fromCreationDictionary` on the Swift side must
// parse the dict that `toMap()` produces.  If either side drifts — key names,
// value encoding, enum indices — the mismatch is silent at compile time but
// breaks the map at runtime.  Pinning the format here makes such drift a test
// failure instead.

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_maps_controllers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const CameraPosition _kDefaultCamera = CameraPosition(target: LatLng(0.0, 0.0));

/// Pumps an [AppleMap] built from [child], waits for it to settle, and returns
/// the [FakePlatformAppleMap] that was created.
///
/// Sets and immediately clears [debugDefaultTargetPlatformOverride] around the
/// pump so the platform view is created on iOS without leaving the debug
/// variable set by the time the test's invariant check runs.
Future<FakePlatformAppleMap> _pumpMap(
  WidgetTester tester, {
  Widget? child,
}) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: child ?? const AppleMap(initialCameraPosition: _kDefaultCamera),
    ),
  );
  debugDefaultTargetPlatformOverride = null;
  return fakePlatformViewsController.lastCreatedView!;
}

// ---------------------------------------------------------------------------
// Test setup
// ---------------------------------------------------------------------------

final FakePlatformViewsController fakePlatformViewsController =
    FakePlatformViewsController();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          SystemChannels.platform_views,
          fakePlatformViewsController.fakePlatformViewsMethodHandler,
        );
  });

  setUp(() {
    fakePlatformViewsController.reset();
  });

  // Safety net: ensure debugDefaultTargetPlatformOverride is always cleared even
  // if a test throws before _pumpMap's inline clear runs.
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  // -------------------------------------------------------------------------
  // Group 1: toMap() wire format
  // -------------------------------------------------------------------------

  group('_AppleMapOptions.toMap() wire format —', () {
    // ── booleans ────────────────────────────────────────────────────────────

    testWidgets('compassEnabled true encodes as bool true', (tester) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: _kDefaultCamera,
          compassEnabled: true,
        ),
      );
      expect(fake.rawCreationOptions!['compassEnabled'], isTrue);
    });

    testWidgets('compassEnabled false encodes as bool false', (tester) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: _kDefaultCamera,
          compassEnabled: false,
        ),
      );
      expect(fake.rawCreationOptions!['compassEnabled'], isFalse);
    });

    testWidgets('trafficEnabled encodes under key trafficEnabled', (
      tester,
    ) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: _kDefaultCamera,
          trafficEnabled: true,
        ),
      );
      expect(fake.rawCreationOptions!['trafficEnabled'], isTrue);
    });

    testWidgets('trafficEnabled false encodes as bool false', (tester) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: _kDefaultCamera,
          trafficEnabled: false,
        ),
      );
      expect(fake.rawCreationOptions!['trafficEnabled'], isFalse);
    });

    testWidgets('insetsLayoutMarginsFromSafeArea encodes under correct key', (
      tester,
    ) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: _kDefaultCamera,
          insetsLayoutMarginsFromSafeArea: true,
        ),
      );
      expect(
        fake.rawCreationOptions!['insetsLayoutMarginsFromSafeArea'],
        isTrue,
      );
    });

    testWidgets(
      'insetsLayoutMarginsFromSafeArea false encodes as bool false',
      (tester) async {
        final fake = await _pumpMap(
          tester,
          child: const AppleMap(
            initialCameraPosition: _kDefaultCamera,
            insetsLayoutMarginsFromSafeArea: false,
          ),
        );
        expect(
          fake.rawCreationOptions!['insetsLayoutMarginsFromSafeArea'],
          isFalse,
        );
      },
    );

    // ── mapType enum → int ────────────────────────────────────────────────

    testWidgets('mapType.standard encodes as int 0', (tester) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: _kDefaultCamera,
          mapType: MapType.standard,
        ),
      );
      expect(fake.rawCreationOptions!['mapType'], 0);
    });

    testWidgets('mapType.satellite encodes as int 1', (tester) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: _kDefaultCamera,
          mapType: MapType.satellite,
        ),
      );
      expect(fake.rawCreationOptions!['mapType'], 1);
    });

    testWidgets('mapType.hybrid encodes as int 2', (tester) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: _kDefaultCamera,
          mapType: MapType.hybrid,
        ),
      );
      expect(fake.rawCreationOptions!['mapType'], 2);
    });

    // No "omits key when null" test needed here: AppleMap.mapType always
    // defaults to MapType.standard, so the key is always present.

    // ── trackingMode enum → int ───────────────────────────────────────────

    testWidgets('trackingMode.none encodes as int 0', (tester) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: _kDefaultCamera,
          trackingMode: TrackingMode.none,
        ),
      );
      expect(fake.rawCreationOptions!['trackingMode'], 0);
    });

    testWidgets('trackingMode.follow encodes as int 1', (tester) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: _kDefaultCamera,
          trackingMode: TrackingMode.follow,
        ),
      );
      expect(fake.rawCreationOptions!['trackingMode'], 1);
    });

    testWidgets('trackingMode.followWithHeading encodes as int 2', (
      tester,
    ) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: _kDefaultCamera,
          trackingMode: TrackingMode.followWithHeading,
        ),
      );
      expect(fake.rawCreationOptions!['trackingMode'], 2);
    });

    // ── minMaxZoomPreference ──────────────────────────────────────────────

    testWidgets(
      'minMaxZoomPreference encodes as 2-element list under key minMaxZoomPreference',
      (tester) async {
        final fake = await _pumpMap(
          tester,
          child: const AppleMap(
            initialCameraPosition: _kDefaultCamera,
            minMaxZoomPreference: MinMaxZoomPreference(1.0, 8.0),
          ),
        );
        final dynamic z = fake.rawCreationOptions!['minMaxZoomPreference'];
        expect(z, isA<List>());
        final List<dynamic> list = z as List<dynamic>;
        expect(list.length, 2);
        expect(list[0], 1.0);
        expect(list[1], 8.0);
      },
    );

    testWidgets('MinMaxZoomPreference.unbounded encodes as [null, null]', (
      tester,
    ) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: _kDefaultCamera,
          minMaxZoomPreference: MinMaxZoomPreference.unbounded,
        ),
      );
      final dynamic z = fake.rawCreationOptions!['minMaxZoomPreference'];
      expect(z, isA<List>());
      final List<dynamic> list = z as List<dynamic>;
      expect(list.length, 2);
      expect(list[0], isNull);
      expect(list[1], isNull);
    });

    // No "omits key when null" test: AppleMap.minMaxZoomPreference always
    // defaults to MinMaxZoomPreference.unbounded, so the key is always present.

    // ── padding ───────────────────────────────────────────────────────────

    testWidgets('padding encodes as [top, left, bottom, right] list', (
      tester,
    ) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: _kDefaultCamera,
          padding: EdgeInsets.fromLTRB(4.0, 8.0, 12.0, 16.0),
        ),
      );
      final dynamic p = fake.rawCreationOptions!['padding'];
      expect(p, isA<List>());
      final List<dynamic> list = p as List<dynamic>;
      // serialized as [top, left, bottom, right]
      expect(list[0], 8.0); // top
      expect(list[1], 4.0); // left
      expect(list[2], 16.0); // bottom
      expect(list[3], 12.0); // right
    });

    testWidgets('default padding (EdgeInsets.zero) encodes as [0, 0, 0, 0]', (tester) async {
      // AppleMap.padding defaults to EdgeInsets.zero, which always produces
      // a [0.0, 0.0, 0.0, 0.0] list in the creation dict.
      final fake = await _pumpMap(tester);
      final dynamic p = fake.rawCreationOptions!['padding'];
      expect(p, isA<List>());
      final List<dynamic> list = p as List<dynamic>;
      expect(list, [0.0, 0.0, 0.0, 0.0]);
    });

    // ── cameraTargetBounds ────────────────────────────────────────────────

    testWidgets('cameraTargetBounds key is always present in creation dict', (
      tester,
    ) async {
      // The key must be present even when null so that Swift can distinguish
      // "unbounded" from "no change" in the creation-time baseline.
      final fake = await _pumpMap(tester);
      expect(
        fake.rawCreationOptions!.containsKey('cameraTargetBounds'),
        isTrue,
      );
    });

    testWidgets('unbounded cameraTargetBounds encodes as null value', (
      tester,
    ) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: _kDefaultCamera,
          cameraTargetBounds: CameraTargetBounds.unbounded,
        ),
      );
      expect(fake.rawCreationOptions!['cameraTargetBounds'], isNull);
    });

    testWidgets(
      'cameraTargetBounds with bounds encodes as flat [swLat, swLng, neLat, neLng] double list',
      (tester) async {
        final fake = await _pumpMap(
          tester,
          child: AppleMap(
            initialCameraPosition: _kDefaultCamera,
            cameraTargetBounds: CameraTargetBounds(
              LatLngBounds(
                southwest: const LatLng(10.0, 20.0),
                northeast: const LatLng(30.0, 40.0),
              ),
            ),
          ),
        );
        final dynamic b = fake.rawCreationOptions!['cameraTargetBounds'];
        expect(b, isA<List>());
        final List<dynamic> list = b as List<dynamic>;
        expect(list.length, 4);
        expect(list[0], 10.0); // sw.latitude
        expect(list[1], 20.0); // sw.longitude
        expect(list[2], 30.0); // ne.latitude
        expect(list[3], 40.0); // ne.longitude
      },
    );

    // ── emphasisStyle ─────────────────────────────────────────────────────

    testWidgets('emphasisStyle.defaultStyle encodes as int 0', (tester) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: _kDefaultCamera,
          emphasisStyle: MapEmphasisStyle.defaultStyle,
        ),
      );
      expect(fake.rawCreationOptions!['emphasisStyle'], 0);
    });

    testWidgets('emphasisStyle.muted encodes as int 1', (tester) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: _kDefaultCamera,
          emphasisStyle: MapEmphasisStyle.muted,
        ),
      );
      expect(fake.rawCreationOptions!['emphasisStyle'], 1);
    });

    // No "omits key when null" test: AppleMap.emphasisStyle always defaults
    // to MapEmphasisStyle.defaultStyle, so the key is always present.

    // ── selectableFeatures bitmask ────────────────────────────────────────

    testWidgets('selectableFeatures: pointsOfInterest only → bitmask 1', (
      tester,
    ) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: _kDefaultCamera,
          selectableFeatures: {MapSelectableFeature.pointsOfInterest},
        ),
      );
      expect(fake.rawCreationOptions!['selectableFeatures'], 1);
    });

    testWidgets('selectableFeatures: territories only → bitmask 2', (
      tester,
    ) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: _kDefaultCamera,
          selectableFeatures: {MapSelectableFeature.territories},
        ),
      );
      expect(fake.rawCreationOptions!['selectableFeatures'], 2);
    });

    testWidgets('selectableFeatures: physicalFeatures only → bitmask 4', (
      tester,
    ) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: _kDefaultCamera,
          selectableFeatures: {MapSelectableFeature.physicalFeatures},
        ),
      );
      expect(fake.rawCreationOptions!['selectableFeatures'], 4);
    });

    testWidgets('selectableFeatures: all three → bitmask 7', (tester) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: _kDefaultCamera,
          selectableFeatures: {
            MapSelectableFeature.pointsOfInterest,
            MapSelectableFeature.territories,
            MapSelectableFeature.physicalFeatures,
          },
        ),
      );
      expect(fake.rawCreationOptions!['selectableFeatures'], 7);
    });

    testWidgets('selectableFeatures: empty set → bitmask 0', (tester) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: _kDefaultCamera,
          selectableFeatures: {},
        ),
      );
      expect(fake.rawCreationOptions!['selectableFeatures'], 0);
    });

    // No "omits key when null" test: AppleMap.selectableFeatures always
    // defaults to {pointsOfInterest}, so the key is always present.
  });

  // -------------------------------------------------------------------------
  // Group 2: CameraPosition wire format
  // -------------------------------------------------------------------------

  group('CameraPosition creation-params wire format —', () {
    testWidgets('target encodes as [latitude, longitude] list', (tester) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(51.5074, -0.1278),
          ),
        ),
      );
      final dynamic t = fake.rawCreationCameraPosition!['target'];
      expect(t, isA<List>());
      final List<dynamic> list = t as List<dynamic>;
      expect(list[0], closeTo(51.5074, 0.0001));
      expect(list[1], closeTo(-0.1278, 0.0001));
    });

    testWidgets('heading encodes as a numeric value under key heading', (
      tester,
    ) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(0, 0),
            heading: 90.0,
          ),
        ),
      );
      expect(fake.rawCreationCameraPosition!['heading'], 90.0);
    });

    testWidgets('pitch encodes as a numeric value under key pitch', (
      tester,
    ) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(0, 0),
            pitch: 45.0,
          ),
        ),
      );
      expect(fake.rawCreationCameraPosition!['pitch'], 45.0);
    });

    testWidgets('zoom encodes as a numeric value under key zoom', (
      tester,
    ) async {
      final fake = await _pumpMap(
        tester,
        child: const AppleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(0, 0),
            zoom: 12.0,
          ),
        ),
      );
      expect(fake.rawCreationCameraPosition!['zoom'], 12.0);
    });

    testWidgets('default CameraPosition encodes heading=0, pitch=0, zoom=0', (
      tester,
    ) async {
      final fake = await _pumpMap(tester);
      expect(fake.rawCreationCameraPosition!['heading'], 0.0);
      expect(fake.rawCreationCameraPosition!['pitch'], 0.0);
      expect(fake.rawCreationCameraPosition!['zoom'], 0.0);
    });
  });

  // -------------------------------------------------------------------------
  // Group 3: updatesMap() list-equality fix (scroll-reset guard)
  //
  // These are the most important tests in this file.  They verify that the
  // fork's list-equality fix in `updatesMap()` prevents a redundant
  // `updateMapOptions` Pigeon call when widget rebuilds with equal list values.
  //
  // Pattern for "no spurious update":
  //   1. Pump with value X.  Record mapUpdateCallCount.
  //   2. Pump with a distinct but equal value X'.
  //   3. Assert mapUpdateCallCount did NOT increase.
  //
  // Pattern for "genuine update fires":
  //   1. Pump with value X.
  //   2. Pump with value Y (different content).
  //   3. Assert mapUpdateCallCount DID increase.
  // -------------------------------------------------------------------------

  group('updatesMap() list-equality fix (scroll-reset guard) —', () {
    // ── minMaxZoomPreference ──────────────────────────────────────────────

    testWidgets(
      'equal bounded minMaxZoom rebuilds do NOT trigger a native update',
      (tester) async {
        // Use _pumpMap for the first pump so the iOS override is set and
        // cleared correctly within the pump call itself.
        final fake = await _pumpMap(
          tester,
          child: const AppleMap(
            initialCameraPosition: _kDefaultCamera,
            minMaxZoomPreference: MinMaxZoomPreference(2.0, 14.0),
          ),
        );
        final int before = fake.mapUpdateCallCount;

        // Rebuild with a new MinMaxZoomPreference object containing same values.
        // No platform override needed — the platform view already exists.
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: AppleMap(
              initialCameraPosition: _kDefaultCamera,
              minMaxZoomPreference: MinMaxZoomPreference(2.0, 14.0),
            ),
          ),
        );

        expect(
          fake.mapUpdateCallCount,
          before,
          reason:
              'updatesMap() should suppress the call when list content is identical',
        );
      },
    );

    testWidgets(
      'equal unbounded minMaxZoom rebuilds do NOT trigger a native update',
      (tester) async {
        final fake = await _pumpMap(
          tester,
          child: const AppleMap(
            initialCameraPosition: _kDefaultCamera,
            minMaxZoomPreference: MinMaxZoomPreference.unbounded,
          ),
        );
        final int before = fake.mapUpdateCallCount;

        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: AppleMap(
              initialCameraPosition: _kDefaultCamera,
              minMaxZoomPreference: MinMaxZoomPreference.unbounded,
            ),
          ),
        );

        expect(fake.mapUpdateCallCount, before);
      },
    );

    testWidgets(
      'changed minMaxZoom DOES trigger a native update',
      (tester) async {
        final fake = await _pumpMap(
          tester,
          child: const AppleMap(
            initialCameraPosition: _kDefaultCamera,
            minMaxZoomPreference: MinMaxZoomPreference(2.0, 14.0),
          ),
        );
        final int before = fake.mapUpdateCallCount;

        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: AppleMap(
              initialCameraPosition: _kDefaultCamera,
              minMaxZoomPreference: MinMaxZoomPreference(3.0, 18.0),
            ),
          ),
        );

        expect(fake.mapUpdateCallCount, greaterThan(before));
      },
    );

    testWidgets(
      'unbounded to unbounded minMaxZoom does NOT trigger a native update',
      (tester) async {
        // Both builds use the default MinMaxZoomPreference.unbounded, which
        // encodes as [null, null]. The key is never absent — verify that
        // updatesMap() correctly suppresses the redundant call.
        final fake = await _pumpMap(tester);
        final int before = fake.mapUpdateCallCount;

        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: AppleMap(initialCameraPosition: _kDefaultCamera),
          ),
        );

        expect(fake.mapUpdateCallCount, before);
      },
    );

    // ── cameraTargetBounds ────────────────────────────────────────────────

    testWidgets(
      'equal bounded cameraTargetBounds rebuilds do NOT trigger a native update',
      (tester) async {
        final fake = await _pumpMap(
          tester,
          child: AppleMap(
            initialCameraPosition: _kDefaultCamera,
            cameraTargetBounds: CameraTargetBounds(
              LatLngBounds(
                southwest: const LatLng(10.0, 20.0),
                northeast: const LatLng(30.0, 40.0),
              ),
            ),
          ),
        );
        final int before = fake.mapUpdateCallCount;

        // Same bounds values, new object tree.
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: AppleMap(
              initialCameraPosition: _kDefaultCamera,
              cameraTargetBounds: CameraTargetBounds(
                LatLngBounds(
                  southwest: const LatLng(10.0, 20.0),
                  northeast: const LatLng(30.0, 40.0),
                ),
              ),
            ),
          ),
        );

        expect(fake.mapUpdateCallCount, before);
      },
    );

    testWidgets(
      'null-to-null cameraTargetBounds (unbounded → unbounded) does NOT trigger update',
      (tester) async {
        final fake = await _pumpMap(tester);
        final int before = fake.mapUpdateCallCount;

        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: AppleMap(initialCameraPosition: _kDefaultCamera),
          ),
        );

        expect(fake.mapUpdateCallCount, before);
      },
    );

    testWidgets(
      'changed cameraTargetBounds DOES trigger a native update',
      (tester) async {
        final fake = await _pumpMap(
          tester,
          child: AppleMap(
            initialCameraPosition: _kDefaultCamera,
            cameraTargetBounds: CameraTargetBounds(
              LatLngBounds(
                southwest: const LatLng(10.0, 20.0),
                northeast: const LatLng(30.0, 40.0),
              ),
            ),
          ),
        );
        final int before = fake.mapUpdateCallCount;

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: AppleMap(
              initialCameraPosition: _kDefaultCamera,
              cameraTargetBounds: CameraTargetBounds(
                LatLngBounds(
                  southwest: const LatLng(50.0, 60.0),
                  northeast: const LatLng(70.0, 80.0),
                ),
              ),
            ),
          ),
        );

        expect(fake.mapUpdateCallCount, greaterThan(before));
      },
    );

    // ── padding ───────────────────────────────────────────────────────────

    testWidgets(
      'equal padding rebuilds do NOT trigger a native update',
      (tester) async {
        final fake = await _pumpMap(
          tester,
          child: const AppleMap(
            initialCameraPosition: _kDefaultCamera,
            padding: EdgeInsets.all(8.0),
          ),
        );
        final int before = fake.mapUpdateCallCount;

        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: AppleMap(
              initialCameraPosition: _kDefaultCamera,
              padding: EdgeInsets.all(8.0),
            ),
          ),
        );

        expect(fake.mapUpdateCallCount, before);
      },
    );

    testWidgets(
      'changed padding DOES trigger a native update',
      (tester) async {
        final fake = await _pumpMap(
          tester,
          child: const AppleMap(
            initialCameraPosition: _kDefaultCamera,
            padding: EdgeInsets.all(8.0),
          ),
        );
        final int before = fake.mapUpdateCallCount;

        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: AppleMap(
              initialCameraPosition: _kDefaultCamera,
              padding: EdgeInsets.all(16.0),
            ),
          ),
        );

        expect(fake.mapUpdateCallCount, greaterThan(before));
      },
    );
  });
}
