// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:apple_maps_flutter/src/messages.g.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_maps_controllers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final FakePlatformViewsController fakePlatformViewsController =
      FakePlatformViewsController();

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

  testWidgets('Initial camera position', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(
      platformAppleMap.cameraPosition,
      const CameraPosition(target: LatLng(10.0, 15.0)),
    );
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Initial camera position change is a no-op', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 16.0)),
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(
      platformAppleMap.cameraPosition,
      const CameraPosition(target: LatLng(10.0, 15.0)),
    );
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Can update compassEnabled', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          compassEnabled: false,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.compassEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          compassEnabled: true,
        ),
      ),
    );

    expect(platformAppleMap.compassEnabled, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Can update mapType', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          mapType: MapType.hybrid,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.mapType, MapType.hybrid);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          mapType: MapType.satellite,
        ),
      ),
    );

    expect(platformAppleMap.mapType, MapType.satellite);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Can update minMaxZoom', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          minMaxZoomPreference: MinMaxZoomPreference(1.0, 3.0),
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(
      platformAppleMap.minMaxZoomPreference,
      const MinMaxZoomPreference(1.0, 3.0),
    );

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          minMaxZoomPreference: MinMaxZoomPreference.unbounded,
        ),
      ),
    );

    expect(
      platformAppleMap.minMaxZoomPreference,
      MinMaxZoomPreference.unbounded,
    );
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Can update rotateGesturesEnabled', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          rotateGesturesEnabled: false,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.rotateGesturesEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          rotateGesturesEnabled: true,
        ),
      ),
    );

    expect(platformAppleMap.rotateGesturesEnabled, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Can update scrollGesturesEnabled', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          scrollGesturesEnabled: false,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.scrollGesturesEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          scrollGesturesEnabled: true,
        ),
      ),
    );

    expect(platformAppleMap.scrollGesturesEnabled, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Can update pitchGesturesEnabled', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          pitchGesturesEnabled: false,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.pitchGesturesEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          pitchGesturesEnabled: true,
        ),
      ),
    );

    expect(platformAppleMap.pitchGesturesEnabled, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Can update zoomGesturesEnabled', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          zoomGesturesEnabled: false,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.zoomGesturesEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          zoomGesturesEnabled: true,
        ),
      ),
    );

    expect(platformAppleMap.zoomGesturesEnabled, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Can update myLocationEnabled', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          myLocationEnabled: false,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.myLocationEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          myLocationEnabled: true,
        ),
      ),
    );

    expect(platformAppleMap.myLocationEnabled, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Can update myLocationButtonEnabled', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          myLocationButtonEnabled: true,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.myLocationButtonEnabled, true);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          myLocationButtonEnabled: false,
        ),
      ),
    );

    expect(platformAppleMap.myLocationButtonEnabled, false);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Equal padding does not trigger a redundant map update', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          padding: EdgeInsets.fromLTRB(1.0, 2.0, 3.0, 4.0),
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.mapUpdateCallCount, 0);
    expect(
      platformAppleMap.padding,
      const EdgeInsets.fromLTRB(1.0, 2.0, 3.0, 4.0),
    );

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          padding: EdgeInsets.fromLTRB(1.0, 2.0, 3.0, 4.0),
        ),
      ),
    );

    expect(platformAppleMap.mapUpdateCallCount, 0);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          padding: EdgeInsets.fromLTRB(4.0, 3.0, 2.0, 1.0),
        ),
      ),
    );

    expect(platformAppleMap.mapUpdateCallCount, 1);
    expect(
      platformAppleMap.padding,
      const EdgeInsets.fromLTRB(4.0, 3.0, 2.0, 1.0),
    );
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Late platform view creation disposes controller', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    fakePlatformViewsController.delayCreate = true;
    int onMapCreatedCallCount = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          onMapCreated: (_) {
            onMapCreatedCallCount += 1;
          },
        ),
      ),
    );

    final dynamic mapState = tester.state(find.byType(AppleMap));
    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    await tester.pumpWidget(const SizedBox.shrink());
    await mapState.onPlatformViewCreated(platformAppleMap.id);
    fakePlatformViewsController.completePendingCreates();
    await tester.pump();

    expect(onMapCreatedCallCount, 0);
    expect(platformAppleMap.disposeCallCount, 1);
    expect(platformAppleMap.disposed, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Controller query methods use typed host API', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Completer<AppleMapController> controllerCompleter =
        Completer<AppleMapController>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
            zoom: 7.0,
          ),
          onMapCreated: controllerCompleter.complete,
        ),
      ),
    );

    final AppleMapController controller = await controllerCompleter.future;

    expect(await controller.getZoomLevel(), 7.0);

    final LatLngBounds visibleRegion = await controller.getVisibleRegion();
    expect(visibleRegion.southwest, const LatLng(10.0, 15.0));
    expect(visibleRegion.northeast, const LatLng(10.0, 15.0));

    final Offset? screenCoordinate = await controller.getScreenCoordinate(
      const LatLng(1.0, 2.0),
    );
    expect(screenCoordinate, const Offset(1.0, 2.0));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.lastScreenCoordinateTarget, const Offset(1.0, 2.0));

    final LatLng? latLng = await controller.getLatLng(const Offset(3.0, 4.0));
    expect(latLng, const LatLng(3.0, 4.0));
    expect(
      platformAppleMap.lastGetLatLngScreenCoordinate,
      const Offset(3.0, 4.0),
    );
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('getLatLng round-trip with getScreenCoordinate', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Completer<AppleMapController> controllerCompleter =
        Completer<AppleMapController>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          onMapCreated: controllerCompleter.complete,
        ),
      ),
    );

    final AppleMapController controller = await controllerCompleter.future;

    final Offset? screenPoint = await controller.getScreenCoordinate(
      const LatLng(37.0, -122.0),
    );
    expect(screenPoint, isNotNull);

    final LatLng roundTrip = (await controller.getLatLng(
      screenPoint ?? Offset.zero,
    ))!;
    // In the fake, getScreenCoordinate echoes lat/lng as x/y, and
    // getLatLng echoes x/y as lat/lng, so the round-trip returns
    // the original values.
    expect(roundTrip.latitude, 37.0);
    expect(roundTrip.longitude, closeTo(-122.0, 1e-10));
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('getLatLng returns null for invalid screen coordinate', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Completer<AppleMapController> controllerCompleter =
        Completer<AppleMapController>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          onMapCreated: controllerCompleter.complete,
        ),
      ),
    );

    final AppleMapController controller = await controllerCompleter.future;
    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    platformAppleMap.getLatLngReturnsNull = true;
    final LatLng? result = await controller.getLatLng(
      const Offset(999.0, 999.0),
    );
    expect(result, isNull);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Controller command methods use typed host API', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Completer<AppleMapController> controllerCompleter =
        Completer<AppleMapController>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          onMapCreated: controllerCompleter.complete,
        ),
      ),
    );

    final AppleMapController controller = await controllerCompleter.future;
    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    platformAppleMap.snapshotBytes = Uint8List.fromList(<int>[1, 2, 3]);

    final AnnotationId annotationId = AnnotationId('annotation_1');
    await controller.showMarkerInfoWindow(annotationId);
    expect(platformAppleMap.lastShownInfoWindowAnnotationId, 'annotation_1');
    expect(await controller.isMarkerInfoWindowShown(annotationId), true);

    await controller.hideMarkerInfoWindow(annotationId);
    expect(platformAppleMap.lastHiddenInfoWindowAnnotationId, 'annotation_1');
    expect(await controller.isMarkerInfoWindowShown(annotationId), false);

    final Uint8List? snapshot = await controller.takeSnapshot(
      const SnapshotOptions(
        showBuildings: false,
        showPointsOfInterest: true,
        showAnnotations: false,
        showOverlays: true,
      ),
    );
    expect(snapshot, Uint8List.fromList(<int>[1, 2, 3]));
    expect(platformAppleMap.takenSnapshotFlags, <int>[0, 1, 0, 1]);

    await controller.dispose();
    await controller.dispose();
    expect(platformAppleMap.disposeCallCount, 1);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Controller camera commands use typed host API', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Completer<AppleMapController> controllerCompleter =
        Completer<AppleMapController>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          onMapCreated: controllerCompleter.complete,
        ),
      ),
    );

    final AppleMapController controller = await controllerCompleter.future;
    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    await controller.animateCamera(
      CameraUpdate.zoomBy(2.5, const Offset(3.0, 4.0)),
    );
    expect(
      platformAppleMap.lastAnimatedPlatformCameraUpdate!.type,
      CameraUpdateType.zoomBy,
    );
    expect(platformAppleMap.lastAnimatedPlatformCameraUpdate!.zoom, 2.5);
    expect(platformAppleMap.lastAnimatedPlatformCameraUpdate!.focus!.x, 3.0);
    expect(platformAppleMap.lastAnimatedPlatformCameraUpdate!.focus!.y, 4.0);

    await controller.moveCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: LatLng(1.0, 2.0), northeast: LatLng(3.0, 4.0)),
        12.0,
      ),
    );
    expect(
      platformAppleMap.lastMovedPlatformCameraUpdate!.type,
      CameraUpdateType.newLatLngBounds,
    );
    expect(platformAppleMap.lastMovedPlatformCameraUpdate!.padding, 12.0);
    expect(
      platformAppleMap
          .lastMovedPlatformCameraUpdate!
          .bounds!
          .southwest
          .latitude,
      1.0,
    );
    expect(
      platformAppleMap
          .lastMovedPlatformCameraUpdate!
          .bounds!
          .southwest
          .longitude,
      2.0,
    );
    expect(
      platformAppleMap
          .lastMovedPlatformCameraUpdate!
          .bounds!
          .northeast
          .latitude,
      3.0,
    );
    expect(
      platformAppleMap
          .lastMovedPlatformCameraUpdate!
          .bounds!
          .northeast
          .longitude,
      4.0,
    );
    debugDefaultTargetPlatformOverride = null;
  });

  // ------------------------------------------------------------------
  // Lifecycle: dispose-during-creation variants
  // ------------------------------------------------------------------

  testWidgets('Dispose before platform view creation completes with no leak', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    fakePlatformViewsController.delayCreate = true;
    bool onMapCreatedCalled = false;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          onMapCreated: (_) {
            onMapCreatedCalled = true;
          },
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    // Grab state reference before the widget is removed.
    final dynamic mapState = tester.state(find.byType(AppleMap));

    // Dispose the widget before the platform view creation callback fires.
    await tester.pumpWidget(const SizedBox.shrink());
    await mapState.onPlatformViewCreated(platformAppleMap.id);
    fakePlatformViewsController.completePendingCreates();
    await tester.pump();

    // The onMapCreated callback must NOT have fired.
    expect(onMapCreatedCalled, false);

    // The late-created controller must have been disposed immediately.
    expect(platformAppleMap.disposed, true);
    expect(platformAppleMap.disposeCallCount, 1);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Double dispose on controller is safe', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Completer<AppleMapController> controllerCompleter =
        Completer<AppleMapController>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          onMapCreated: controllerCompleter.complete,
        ),
      ),
    );

    final AppleMapController controller = await controllerCompleter.future;
    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    await controller.dispose();
    await controller.dispose();
    await controller.dispose();

    // Only one native dispose should have been sent.
    expect(platformAppleMap.disposeCallCount, 1);
    debugDefaultTargetPlatformOverride = null;
  });

  // ------------------------------------------------------------------
  // Multi-map isolation
  // ------------------------------------------------------------------

  testWidgets('Two map instances maintain independent state', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Completer<AppleMapController> controllerA =
        Completer<AppleMapController>();
    final Completer<AppleMapController> controllerB =
        Completer<AppleMapController>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: <Widget>[
            Expanded(
              child: AppleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(10.0, 15.0),
                  zoom: 5.0,
                ),
                compassEnabled: false,
                onMapCreated: controllerA.complete,
              ),
            ),
            Expanded(
              child: AppleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(20.0, 25.0),
                  zoom: 12.0,
                ),
                compassEnabled: true,
                onMapCreated: controllerB.complete,
              ),
            ),
          ],
        ),
      ),
    );

    final AppleMapController ctrlA = await controllerA.future;
    final AppleMapController ctrlB = await controllerB.future;

    // Each controller returns its own initial zoom level.
    expect(await ctrlA.getZoomLevel(), 5.0);
    expect(await ctrlB.getZoomLevel(), 12.0);

    // Each map's visible region reflects its own camera target.
    final LatLngBounds regionA = await ctrlA.getVisibleRegion();
    final LatLngBounds regionB = await ctrlB.getVisibleRegion();
    expect(regionA.southwest.latitude, 10.0);
    expect(regionB.southwest.latitude, 20.0);
    debugDefaultTargetPlatformOverride = null;
  });

  // ------------------------------------------------------------------
  // Annotation update round-trip through Pigeon
  // ------------------------------------------------------------------

  testWidgets('Annotation add/change/remove round-trips through typed API', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final Annotation annotation1 = Annotation(
      annotationId: AnnotationId('a1'),
      position: const LatLng(1.0, 2.0),
      alpha: 0.5,
      draggable: true,
      visible: true,
      zIndex: 3.0,
      infoWindow: const InfoWindow(title: 'Hello', snippet: 'World'),
    );

    // Initial widget with one annotation.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          annotations: <Annotation>{annotation1},
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    // Verify initial annotations came through creation params.
    expect(platformAppleMap.annotationsToAdd, isNotNull);
    expect(platformAppleMap.annotationsToAdd!.length, 1);
    final Annotation addedAnnotation = platformAppleMap.annotationsToAdd!.first;
    expect(addedAnnotation.annotationId, AnnotationId('a1'));
    expect(addedAnnotation.alpha, 0.5);
    expect(addedAnnotation.draggable, true);

    // Change the annotation (update alpha).
    final Annotation annotation1Updated = Annotation(
      annotationId: AnnotationId('a1'),
      position: const LatLng(1.0, 2.0),
      alpha: 0.8,
      draggable: false,
      visible: true,
      zIndex: 3.0,
      infoWindow: const InfoWindow(title: 'Updated'),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          annotations: <Annotation>{annotation1Updated},
        ),
      ),
    );

    // The typed API should have received a change update.
    expect(platformAppleMap.lastPlatformAnnotationUpdates, isNotNull);
    expect(
      platformAppleMap
          .lastPlatformAnnotationUpdates!
          .annotationsToChange
          ?.length,
      1,
    );

    // Remove the annotation.
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          annotations: <Annotation>{},
        ),
      ),
    );

    expect(
      platformAppleMap
          .lastPlatformAnnotationUpdates!
          .annotationIdsToRemove
          ?.length,
      1,
    );
    expect(
      platformAppleMap
          .lastPlatformAnnotationUpdates!
          .annotationIdsToRemove!
          .first,
      'a1',
    );
    debugDefaultTargetPlatformOverride = null;
  });

  // ------------------------------------------------------------------
  // Polyline update round-trip through Pigeon
  // ------------------------------------------------------------------

  testWidgets('Polyline add/change/remove round-trips through typed API', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final Polyline polyline1 = Polyline(
      polylineId: PolylineId('p1'),
      points: const <LatLng>[LatLng(1.0, 2.0), LatLng(3.0, 4.0)],
      color: const Color(0xFFFF0000),
      width: 5,
      visible: true,
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          polylines: <Polyline>{polyline1},
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.polylinesToAdd, isNotNull);
    expect(platformAppleMap.polylinesToAdd!.length, 1);
    expect(platformAppleMap.polylinesToAdd!.first.polylineId, PolylineId('p1'));

    // Change the polyline.
    final Polyline polyline1Updated = Polyline(
      polylineId: PolylineId('p1'),
      points: const <LatLng>[LatLng(5.0, 6.0), LatLng(7.0, 8.0)],
      color: const Color(0xFF00FF00),
      width: 10,
      visible: true,
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          polylines: <Polyline>{polyline1Updated},
        ),
      ),
    );

    expect(platformAppleMap.lastPlatformPolylineUpdates, isNotNull);

    // Remove it.
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          polylines: <Polyline>{},
        ),
      ),
    );

    expect(
      platformAppleMap.lastPlatformPolylineUpdates!.polylineIdsToRemove?.length,
      1,
    );
    debugDefaultTargetPlatformOverride = null;
  });

  // ------------------------------------------------------------------
  // Polygon update round-trip through Pigeon
  // ------------------------------------------------------------------

  testWidgets('Polygon add/change/remove round-trips through typed API', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final Polygon polygon1 = Polygon(
      polygonId: PolygonId('pg1'),
      points: const <LatLng>[
        LatLng(1.0, 2.0),
        LatLng(3.0, 4.0),
        LatLng(5.0, 6.0),
      ],
      fillColor: const Color(0xFF00FF00),
      strokeColor: const Color(0xFFFF0000),
      strokeWidth: 2,
      visible: true,
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          polygons: <Polygon>{polygon1},
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.polygonsToAdd, isNotNull);
    expect(platformAppleMap.polygonsToAdd!.length, 1);

    // Change the polygon.
    final Polygon polygon1Updated = Polygon(
      polygonId: PolygonId('pg1'),
      points: const <LatLng>[
        LatLng(10.0, 20.0),
        LatLng(30.0, 40.0),
        LatLng(50.0, 60.0),
      ],
      fillColor: const Color(0xFFFFFF00),
      strokeColor: const Color(0xFF0000FF),
      strokeWidth: 4,
      visible: true,
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          polygons: <Polygon>{polygon1Updated},
        ),
      ),
    );

    expect(platformAppleMap.lastPlatformPolygonUpdates, isNotNull);

    // Remove it.
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          polygons: <Polygon>{},
        ),
      ),
    );

    expect(
      platformAppleMap.lastPlatformPolygonUpdates!.polygonIdsToRemove?.length,
      1,
    );
    debugDefaultTargetPlatformOverride = null;
  });

  // ------------------------------------------------------------------
  // Circle update round-trip through Pigeon
  // ------------------------------------------------------------------

  testWidgets('Circle add/change/remove round-trips through typed API', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final Circle circle1 = Circle(
      circleId: CircleId('c1'),
      center: const LatLng(1.0, 2.0),
      radius: 100.0,
      fillColor: const Color(0xFF00FF00),
      strokeColor: const Color(0xFFFF0000),
      strokeWidth: 3,
      visible: true,
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          circles: <Circle>{circle1},
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.circlesToAdd, isNotNull);
    expect(platformAppleMap.circlesToAdd!.length, 1);

    // Change the circle.
    final Circle circle1Updated = Circle(
      circleId: CircleId('c1'),
      center: const LatLng(5.0, 6.0),
      radius: 200.0,
      fillColor: const Color(0xFFFFFF00),
      strokeColor: const Color(0xFF0000FF),
      strokeWidth: 5,
      visible: true,
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          circles: <Circle>{circle1Updated},
        ),
      ),
    );

    expect(platformAppleMap.lastPlatformCircleUpdates, isNotNull);

    // Remove it.
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          circles: <Circle>{},
        ),
      ),
    );

    expect(
      platformAppleMap.lastPlatformCircleUpdates!.circleIdsToRemove?.length,
      1,
    );
    debugDefaultTargetPlatformOverride = null;
  });

  // ------------------------------------------------------------------
  // Payload parity: annotation fields survive Pigeon round-trip
  // ------------------------------------------------------------------

  testWidgets('Annotation full payload survives typed round-trip', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final Annotation richAnnotation = Annotation(
      annotationId: AnnotationId('rich'),
      position: const LatLng(37.7749, -122.4194),
      alpha: 0.75,
      anchor: const Offset(0.3, 0.7),
      draggable: true,
      visible: true,
      zIndex: 42.0,
      icon: BitmapDescriptor.defaultAnnotation,
      infoWindow: const InfoWindow(
        title: 'San Francisco',
        snippet: 'CA',
        anchor: Offset(0.5, 1.0),
      ),
    );

    // Create the map, then update with the rich annotation to trigger typed API.
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          annotations: <Annotation>{richAnnotation},
        ),
      ),
    );

    // Verify the platform update preserved all fields.
    final PlatformAnnotationUpdates? updates =
        platformAppleMap.lastPlatformAnnotationUpdates;
    expect(updates, isNotNull);
    expect(updates!.annotationsToAdd, isNotNull);
    expect(updates.annotationsToAdd!.length, 1);

    final PlatformAnnotation pa = updates.annotationsToAdd!.first;
    expect(pa.annotationId, 'rich');
    expect(pa.alpha, 0.75);
    expect(pa.anchor.x, 0.3);
    expect(pa.anchor.y, 0.7);
    expect(pa.draggable, true);
    expect(pa.visible, true);
    expect(pa.zIndex, 42.0);
    expect(pa.position.latitude, 37.7749);
    expect(pa.position.longitude, -122.4194);
    expect(pa.infoWindow.title, 'San Francisco');
    expect(pa.infoWindow.snippet, 'CA');
    expect(pa.infoWindow.anchor!.x, 0.5);
    expect(pa.infoWindow.anchor!.y, 1.0);
    expect(pa.icon.type, BitmapDescriptorType.defaultAnnotation);
    debugDefaultTargetPlatformOverride = null;
  });

  // ------------------------------------------------------------------
  // Payload parity: polyline fields survive Pigeon round-trip
  // ------------------------------------------------------------------

  testWidgets('Polyline full payload survives typed round-trip', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final Polyline richPolyline = Polyline(
      polylineId: PolylineId('rich_pl'),
      points: const <LatLng>[LatLng(1.0, 2.0), LatLng(3.0, 4.0)],
      color: const Color(0xFFABCDEF),
      width: 7,
      polylineCap: Cap.squareCap,
      jointType: JointType.bevel,
      zIndex: 10,
      visible: true,
      consumeTapEvents: true,
      patterns: <PatternItem>[
        PatternItem.dash(10.0),
        PatternItem.gap(5.0),
        PatternItem.dot,
      ],
    );

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          polylines: <Polyline>{richPolyline},
        ),
      ),
    );

    final PlatformPolylineUpdates? updates =
        platformAppleMap.lastPlatformPolylineUpdates;
    expect(updates, isNotNull);
    expect(updates!.polylinesToAdd, isNotNull);
    expect(updates.polylinesToAdd!.length, 1);

    final PlatformPolyline pp = updates.polylinesToAdd!.first;
    expect(pp.polylineId, 'rich_pl');
    expect(pp.color, 0xFFABCDEF);
    expect(pp.width, 7);
    expect(pp.polylineCap, CapType.squareCap);
    expect(pp.jointType, JointType.bevel.value);
    expect(pp.zIndex, 10);
    expect(pp.visible, true);
    expect(pp.consumeTapEvents, true);
    expect(pp.points.length, 2);
    expect(pp.points[0].latitude, 1.0);
    expect(pp.points[1].longitude, 4.0);
    expect(pp.patterns.length, 3);
    expect(pp.patterns[0].type, PatternItemType.dash);
    expect(pp.patterns[0].length, 10.0);
    expect(pp.patterns[1].type, PatternItemType.gap);
    expect(pp.patterns[1].length, 5.0);
    expect(pp.patterns[2].type, PatternItemType.dot);
    debugDefaultTargetPlatformOverride = null;
  });

  // ------------------------------------------------------------------
  // Payload parity: circle fields survive Pigeon round-trip
  // ------------------------------------------------------------------

  testWidgets('Circle full payload survives typed round-trip', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final Circle richCircle = Circle(
      circleId: CircleId('rich_c'),
      center: const LatLng(51.5074, -0.1278),
      radius: 500.0,
      fillColor: const Color(0x8000FF00),
      strokeColor: const Color(0xFF0000FF),
      strokeWidth: 4,
      visible: true,
      consumeTapEvents: true,
      zIndex: 7,
    );

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          circles: <Circle>{richCircle},
        ),
      ),
    );

    final PlatformCircleUpdates? updates =
        platformAppleMap.lastPlatformCircleUpdates;
    expect(updates, isNotNull);
    expect(updates!.circlesToAdd, isNotNull);
    expect(updates.circlesToAdd!.length, 1);

    final PlatformCircle pc = updates.circlesToAdd!.first;
    expect(pc.circleId, 'rich_c');
    expect(pc.center.latitude, 51.5074);
    expect(pc.center.longitude, closeTo(-0.1278, 1e-10));
    expect(pc.radius, 500.0);
    expect(pc.fillColor, 0x8000FF00);
    expect(pc.strokeColor, 0xFF0000FF);
    expect(pc.strokeWidth, 4);
    expect(pc.visible, true);
    expect(pc.consumeTapEvents, true);
    expect(pc.zIndex, 7);
    debugDefaultTargetPlatformOverride = null;
  });

  // ------------------------------------------------------------------
  // Payload parity: polygon fields survive Pigeon round-trip
  // ------------------------------------------------------------------

  testWidgets('Polygon full payload survives typed round-trip', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final Polygon richPolygon = Polygon(
      polygonId: PolygonId('rich_pg'),
      points: const <LatLng>[
        LatLng(0.0, 0.0),
        LatLng(0.0, 10.0),
        LatLng(10.0, 10.0),
        LatLng(10.0, 0.0),
      ],
      fillColor: const Color(0x40FF0000),
      strokeColor: const Color(0xFF00FF00),
      strokeWidth: 6,
      visible: true,
      consumeTapEvents: true,
      zIndex: 15,
    );

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          polygons: <Polygon>{richPolygon},
        ),
      ),
    );

    final PlatformPolygonUpdates? updates =
        platformAppleMap.lastPlatformPolygonUpdates;
    expect(updates, isNotNull);
    expect(updates!.polygonsToAdd, isNotNull);
    expect(updates.polygonsToAdd!.length, 1);

    final PlatformPolygon ppg = updates.polygonsToAdd!.first;
    expect(ppg.polygonId, 'rich_pg');
    expect(ppg.fillColor, 0x40FF0000);
    expect(ppg.strokeColor, 0xFF00FF00);
    expect(ppg.strokeWidth, 6);
    expect(ppg.visible, true);
    expect(ppg.consumeTapEvents, true);
    expect(ppg.zIndex, 15);
    expect(ppg.points.length, 4);
    expect(ppg.points[2].latitude, 10.0);
    expect(ppg.points[2].longitude, 10.0);
    debugDefaultTargetPlatformOverride = null;
  });

  // ------------------------------------------------------------------
  // New map configuration options
  // ------------------------------------------------------------------

  testWidgets('Can update buildingsEnabled', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          buildingsEnabled: false,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.buildingsEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          buildingsEnabled: true,
        ),
      ),
    );

    expect(platformAppleMap.buildingsEnabled, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Can update pointsOfInterestEnabled', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          pointsOfInterestEnabled: false,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.pointsOfInterestEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          pointsOfInterestEnabled: true,
        ),
      ),
    );

    expect(platformAppleMap.pointsOfInterestEnabled, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Can update scaleEnabled', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          scaleEnabled: true,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.scaleEnabled, true);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          scaleEnabled: false,
        ),
      ),
    );

    expect(platformAppleMap.scaleEnabled, false);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Can update cameraTargetBounds', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          cameraTargetBounds: CameraTargetBounds(
            LatLngBounds(
              southwest: LatLng(1.0, 2.0),
              northeast: LatLng(3.0, 4.0),
            ),
          ),
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.cameraTargetBounds, isNotNull);
    expect(platformAppleMap.cameraTargetBounds!.bounds, isNotNull);
    expect(
      platformAppleMap.cameraTargetBounds!.bounds!.southwest,
      const LatLng(1.0, 2.0),
    );
    expect(
      platformAppleMap.cameraTargetBounds!.bounds!.northeast,
      const LatLng(3.0, 4.0),
    );

    // Set to unbounded.
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          cameraTargetBounds: CameraTargetBounds.unbounded,
        ),
      ),
    );

    expect(platformAppleMap.cameraTargetBounds, isNotNull);
    expect(platformAppleMap.cameraTargetBounds!.bounds, isNull);

    // Set to bounded again.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          cameraTargetBounds: CameraTargetBounds(
            LatLngBounds(
              southwest: LatLng(5.0, 6.0),
              northeast: LatLng(7.0, 8.0),
            ),
          ),
        ),
      ),
    );

    expect(
      platformAppleMap.cameraTargetBounds!.bounds!.southwest,
      const LatLng(5.0, 6.0),
    );
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Equal cameraTargetBounds does not trigger a redundant update', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final CameraTargetBounds bounds = CameraTargetBounds(
      LatLngBounds(southwest: LatLng(1.0, 2.0), northeast: LatLng(3.0, 4.0)),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          cameraTargetBounds: bounds,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.mapUpdateCallCount, 0);

    // Rebuild with identical bounds — should NOT trigger a map update.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          cameraTargetBounds: bounds,
        ),
      ),
    );

    expect(platformAppleMap.mapUpdateCallCount, 0);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Equal unbounded cameraTargetBounds does not trigger update', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          cameraTargetBounds: CameraTargetBounds.unbounded,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.mapUpdateCallCount, 0);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          cameraTargetBounds: CameraTargetBounds.unbounded,
        ),
      ),
    );

    expect(platformAppleMap.mapUpdateCallCount, 0);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('onAnnotationDragEnd callback fires when drag completes', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    LatLng? dragEndPosition;
    final Annotation annotation = Annotation(
      annotationId: AnnotationId('ann_1'),
      draggable: true,
      position: const LatLng(10.0, 15.0),
      onDragEnd: (LatLng pos) => dragEndPosition = pos,
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(10.0, 15.0),
          ),
          annotations: {annotation},
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    const LatLng droppedAt = LatLng(11.0, 16.0);
    await platformAppleMap.sendFlutterApiEvent('onAnnotationDragEnd', <Object?>[
      'ann_1',
      PlatformLatLng(latitude: droppedAt.latitude, longitude: droppedAt.longitude),
    ]);

    expect(dragEndPosition, isNotNull);
    expect(dragEndPosition!.latitude, closeTo(11.0, 0.001));
    expect(dragEndPosition!.longitude, closeTo(16.0, 0.001));
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Can update trackingMode', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          trackingMode: TrackingMode.none,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.trackingMode, TrackingMode.none);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          trackingMode: TrackingMode.follow,
        ),
      ),
    );

    expect(platformAppleMap.trackingMode, TrackingMode.follow);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          trackingMode: TrackingMode.followWithHeading,
        ),
      ),
    );

    expect(platformAppleMap.trackingMode, TrackingMode.followWithHeading);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Default trackingMode is TrackingMode.none', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    // trackingMode defaults to TrackingMode.none; the fake records the value
    // sent over the channel, which is the none index (0).
    expect(platformAppleMap.trackingMode, TrackingMode.none);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Equal trackingMode does not trigger a redundant map update', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          trackingMode: TrackingMode.follow,
        ),
      ),
    );

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.mapUpdateCallCount, 0);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          trackingMode: TrackingMode.follow,
        ),
      ),
    );

    expect(platformAppleMap.mapUpdateCallCount, 0);
    debugDefaultTargetPlatformOverride = null;
  });
}
