// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:apple_maps_flutter/src/messages.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:integration_test/integration_test.dart';

import 'apple_map_inspector.dart';

const LatLng _kInitialMapCenter = LatLng(0, 0);
const CameraPosition _kInitialCameraPosition = CameraPosition(
  target: _kInitialMapCenter,
);

Future<void> _pumpMap(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(widget);
  await tester.pump(const Duration(milliseconds: 250));
}

Future<T> _waitForValue<T>({
  required Future<T> Function() read,
  required bool Function(T value) matches,
  Duration timeout = const Duration(seconds: 5),
  Duration interval = const Duration(milliseconds: 100),
}) async {
  final Stopwatch stopwatch = Stopwatch()..start();
  late T value;

  do {
    value = await read();
    if (matches(value)) {
      return value;
    }
    await Future<void>.delayed(interval);
  } while (stopwatch.elapsed < timeout);

  return value;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('testCompassToggle', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          compassEnabled: false,
          onMapCreated: (AppleMapController controller) {
            // ignore: invalid_use_of_visible_for_testing_member
            final AppleMapInspector inspector = AppleMapInspector(controller.mapId);
            inspectorCompleter.complete(inspector);
          },
        ),
      ),
    );

    final AppleMapInspector inspector = await inspectorCompleter.future;
    bool compassEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isCompassEnabled(),
      matches: (bool value) => value == false,
    );
    expect(compassEnabled, false);

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          compassEnabled: true,
          onMapCreated: (AppleMapController controller) {
            fail("OnMapCreated should get called only once.");
          },
        ),
      ),
    );

    compassEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isCompassEnabled(),
      matches: (bool value) => value,
    );
    expect(compassEnabled, true);
  });

  testWidgets('updateMinMaxZoomLevels', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    const MinMaxZoomPreference initialZoomLevel = MinMaxZoomPreference(2, 4);
    const MinMaxZoomPreference finalZoomLevel = MinMaxZoomPreference(3, 8);

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          minMaxZoomPreference: initialZoomLevel,
          onMapCreated: (AppleMapController controller) {
            // ignore: invalid_use_of_visible_for_testing_member
            final AppleMapInspector inspector = AppleMapInspector(controller.mapId);
            inspectorCompleter.complete(inspector);
          },
        ),
      ),
    );

    final AppleMapInspector inspector = await inspectorCompleter.future;
    MinMaxZoomPreference zoomLevel = await _waitForValue<MinMaxZoomPreference>(
      read: inspector.getMinMaxZoomLevels,
      matches: (MinMaxZoomPreference value) => value == initialZoomLevel,
    );
    expect(zoomLevel, equals(initialZoomLevel));

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          minMaxZoomPreference: finalZoomLevel,
          onMapCreated: (AppleMapController controller) {
            fail("OnMapCreated should get called only once.");
          },
        ),
      ),
    );

    zoomLevel = await _waitForValue<MinMaxZoomPreference>(
      read: inspector.getMinMaxZoomLevels,
      matches: (MinMaxZoomPreference value) => value == finalZoomLevel,
    );
    expect(zoomLevel, equals(finalZoomLevel));
  });

  testWidgets('testZoomGesturesEnabled', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          zoomGesturesEnabled: false,
          onMapCreated: (AppleMapController controller) {
            // ignore: invalid_use_of_visible_for_testing_member
            final AppleMapInspector inspector = AppleMapInspector(controller.mapId);
            inspectorCompleter.complete(inspector);
          },
        ),
      ),
    );

    final AppleMapInspector inspector = await inspectorCompleter.future;
    bool zoomGesturesEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isZoomGesturesEnabled(),
      matches: (bool value) => value == false,
    );
    expect(zoomGesturesEnabled, false);

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          zoomGesturesEnabled: true,
          onMapCreated: (AppleMapController controller) {
            fail("OnMapCreated should get called only once.");
          },
        ),
      ),
    );

    zoomGesturesEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isZoomGesturesEnabled(),
      matches: (bool value) => value,
    );
    expect(zoomGesturesEnabled, true);
  });

  testWidgets('testRotateGesturesEnabled', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          rotateGesturesEnabled: false,
          onMapCreated: (AppleMapController controller) {
            // ignore: invalid_use_of_visible_for_testing_member
            final AppleMapInspector inspector = AppleMapInspector(controller.mapId);
            inspectorCompleter.complete(inspector);
          },
        ),
      ),
    );

    final AppleMapInspector inspector = await inspectorCompleter.future;
    bool rotateGesturesEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isRotateGesturesEnabled(),
      matches: (bool value) => value == false,
    );
    expect(rotateGesturesEnabled, false);

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          rotateGesturesEnabled: true,
          onMapCreated: (AppleMapController controller) {
            fail("OnMapCreated should get called only once.");
          },
        ),
      ),
    );

    rotateGesturesEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isRotateGesturesEnabled(),
      matches: (bool value) => value,
    );
    expect(rotateGesturesEnabled, true);
  });

  testWidgets('testTiltGesturesEnabled', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          pitchGesturesEnabled: false,
          onMapCreated: (AppleMapController controller) {
            // ignore: invalid_use_of_visible_for_testing_member
            final AppleMapInspector inspector = AppleMapInspector(controller.mapId);
            inspectorCompleter.complete(inspector);
          },
        ),
      ),
    );

    final AppleMapInspector inspector = await inspectorCompleter.future;
    bool pitchGesturesEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isPitchGesturesEnabled(),
      matches: (bool value) => value == false,
    );
    expect(pitchGesturesEnabled, false);

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          pitchGesturesEnabled: true,
          onMapCreated: (AppleMapController controller) {
            fail("OnMapCreated should get called only once.");
          },
        ),
      ),
    );

    pitchGesturesEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isPitchGesturesEnabled(),
      matches: (bool value) => value,
    );
    expect(pitchGesturesEnabled, true);
  });

  testWidgets('testScrollGesturesEnabled', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          scrollGesturesEnabled: false,
          onMapCreated: (AppleMapController controller) {
            // ignore: invalid_use_of_visible_for_testing_member
            final AppleMapInspector inspector = AppleMapInspector(controller.mapId);
            inspectorCompleter.complete(inspector);
          },
        ),
      ),
    );

    final AppleMapInspector inspector = await inspectorCompleter.future;
    bool scrollGesturesEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isScrollGesturesEnabled(),
      matches: (bool value) => value == false,
    );
    expect(scrollGesturesEnabled, false);

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          scrollGesturesEnabled: true,
          onMapCreated: (AppleMapController controller) {
            fail("OnMapCreated should get called only once.");
          },
        ),
      ),
    );

    scrollGesturesEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isScrollGesturesEnabled(),
      matches: (bool value) => value,
    );
    expect(scrollGesturesEnabled, true);
  });

  testWidgets('testBuildingsToggle', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          buildingsEnabled: false,
          onMapCreated: (AppleMapController controller) {
            // ignore: invalid_use_of_visible_for_testing_member
            final AppleMapInspector inspector = AppleMapInspector(controller.mapId);
            inspectorCompleter.complete(inspector);
          },
        ),
      ),
    );

    final AppleMapInspector inspector = await inspectorCompleter.future;
    bool buildingsEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isBuildingsEnabled(),
      matches: (bool value) => value == false,
    );
    expect(buildingsEnabled, false);

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          buildingsEnabled: true,
          onMapCreated: (AppleMapController controller) {
            fail("OnMapCreated should get called only once.");
          },
        ),
      ),
    );

    buildingsEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isBuildingsEnabled(),
      matches: (bool value) => value,
    );
    expect(buildingsEnabled, true);
  });

  testWidgets('testScaleToggle', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          scaleEnabled: true,
          onMapCreated: (AppleMapController controller) {
            // ignore: invalid_use_of_visible_for_testing_member
            final AppleMapInspector inspector = AppleMapInspector(controller.mapId);
            inspectorCompleter.complete(inspector);
          },
        ),
      ),
    );

    final AppleMapInspector inspector = await inspectorCompleter.future;
    bool scaleEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isScaleEnabled(),
      matches: (bool value) => value,
    );
    expect(scaleEnabled, true);

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          scaleEnabled: false,
          onMapCreated: (AppleMapController controller) {
            fail("OnMapCreated should get called only once.");
          },
        ),
      ),
    );

    scaleEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isScaleEnabled(),
      matches: (bool value) => value == false,
    );
    expect(scaleEnabled, false);
  });

  testWidgets('testTrafficToggle', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          trafficEnabled: true,
          onMapCreated: (AppleMapController controller) {
            // ignore: invalid_use_of_visible_for_testing_member
            final AppleMapInspector inspector = AppleMapInspector(controller.mapId);
            inspectorCompleter.complete(inspector);
          },
        ),
      ),
    );

    final AppleMapInspector inspector = await inspectorCompleter.future;
    bool trafficEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isTrafficEnabled(),
      matches: (bool value) => value,
    );
    expect(trafficEnabled, true);

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          trafficEnabled: false,
          onMapCreated: (AppleMapController controller) {
            fail("OnMapCreated should get called only once.");
          },
        ),
      ),
    );

    trafficEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isTrafficEnabled(),
      matches: (bool value) => value == false,
    );
    expect(trafficEnabled, false);
  });

  testWidgets('testCameraTargetBounds', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          cameraTargetBounds: CameraTargetBounds(
            LatLngBounds(
              southwest: const LatLng(-10.0, -10.0),
              northeast: const LatLng(10.0, 10.0),
            ),
          ),
          onMapCreated: (AppleMapController controller) {
            // ignore: invalid_use_of_visible_for_testing_member
            final AppleMapInspector inspector = AppleMapInspector(controller.mapId);
            inspectorCompleter.complete(inspector);
          },
        ),
      ),
    );

    final AppleMapInspector inspector = await inspectorCompleter.future;
    final PlatformCameraTargetBounds? bounds = await _waitForValue(
      read: () async => await inspector.getCameraTargetBounds(),
      matches: (PlatformCameraTargetBounds? value) => value != null,
    );
    expect(bounds, isNotNull);
    expect(bounds!.bounds, isNotNull);

    // Set to unbounded.
    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          cameraTargetBounds: CameraTargetBounds.unbounded,
          onMapCreated: (AppleMapController controller) {
            fail("OnMapCreated should get called only once.");
          },
        ),
      ),
    );

    final PlatformCameraTargetBounds? unbounded = await _waitForValue(
      read: () async => await inspector.getCameraTargetBounds(),
      matches: (PlatformCameraTargetBounds? value) => value == null,
    );
    expect(unbounded, isNull);
  });

  testWidgets('testPointsOfInterestToggle', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          pointsOfInterestEnabled: false,
          onMapCreated: (AppleMapController controller) {
            // ignore: invalid_use_of_visible_for_testing_member
            final AppleMapInspector inspector = AppleMapInspector(controller.mapId);
            inspectorCompleter.complete(inspector);
          },
        ),
      ),
    );

    final AppleMapInspector inspector = await inspectorCompleter.future;
    bool poiEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isPointsOfInterestEnabled(),
      matches: (bool value) => value == false,
    );
    expect(poiEnabled, false);

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          pointsOfInterestEnabled: true,
          onMapCreated: (AppleMapController controller) {
            fail("OnMapCreated should get called only once.");
          },
        ),
      ),
    );

    poiEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isPointsOfInterestEnabled(),
      matches: (bool value) => value,
    );
    expect(poiEnabled, true);
  });

  testWidgets('testGetVisibleRegion', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<AppleMapController> controllerCompleter =
        Completer<AppleMapController>();

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          onMapCreated: controllerCompleter.complete,
        ),
      ),
    );

    final AppleMapController controller = await controllerCompleter.future;
    await Future<void>.delayed(const Duration(seconds: 1));

    final LatLngBounds region = await controller.getVisibleRegion();
    expect(region.southwest, isNotNull);
    expect(region.northeast, isNotNull);
    expect(region.contains(_kInitialMapCenter), isTrue);
  });

  testWidgets('testMyLocationButtonToggle', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          myLocationButtonEnabled: true,
          myLocationEnabled: false,
          onMapCreated: (AppleMapController controller) {
            // ignore: invalid_use_of_visible_for_testing_member
            final AppleMapInspector inspector = AppleMapInspector(controller.mapId);
            inspectorCompleter.complete(inspector);
          },
        ),
      ),
    );

    final AppleMapInspector inspector = await inspectorCompleter.future;
    bool myLocationButtonEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isMyLocationButtonEnabled(),
      matches: (bool value) => value,
    );
    expect(myLocationButtonEnabled, true);

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          myLocationButtonEnabled: false,
          myLocationEnabled: false,
          onMapCreated: (AppleMapController controller) {
            fail("OnMapCreated should get called only once.");
          },
        ),
      ),
    );

    myLocationButtonEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isMyLocationButtonEnabled(),
      matches: (bool value) => value == false,
    );
    expect(myLocationButtonEnabled, false);
  });

  testWidgets('testMyLocationButton initial value false', (
    WidgetTester tester,
  ) async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          myLocationButtonEnabled: false,
          myLocationEnabled: false,
          onMapCreated: (AppleMapController controller) {
            // ignore: invalid_use_of_visible_for_testing_member
            final AppleMapInspector inspector = AppleMapInspector(controller.mapId);
            inspectorCompleter.complete(inspector);
          },
        ),
      ),
    );

    final AppleMapInspector inspector = await inspectorCompleter.future;
    final bool myLocationButtonEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isMyLocationButtonEnabled(),
      matches: (bool value) => value == false,
    );
    expect(myLocationButtonEnabled, false);
  });

  testWidgets('testMyLocationButton initial value true', (
    WidgetTester tester,
  ) async {
    final Key key = GlobalKey();
    final Completer<AppleMapInspector> inspectorCompleter =
        Completer<AppleMapInspector>();

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          myLocationButtonEnabled: true,
          myLocationEnabled: false,
          onMapCreated: (AppleMapController controller) {
            // ignore: invalid_use_of_visible_for_testing_member
            final AppleMapInspector inspector = AppleMapInspector(controller.mapId);
            inspectorCompleter.complete(inspector);
          },
        ),
      ),
    );

    final AppleMapInspector inspector = await inspectorCompleter.future;
    final bool myLocationButtonEnabled = await _waitForValue<bool>(
      read: () async => await inspector.isMyLocationButtonEnabled(),
      matches: (bool value) => value == false,
    );
    expect(myLocationButtonEnabled, false);
  });

  testWidgets('testGetLatLngRoundTrip', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<AppleMapController> controllerCompleter =
        Completer<AppleMapController>();

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          onMapCreated: controllerCompleter.complete,
        ),
      ),
    );

    final AppleMapController controller = await controllerCompleter.future;
    await Future<void>.delayed(const Duration(seconds: 1));

    final Offset? screenPoint = await controller.getScreenCoordinate(
      _kInitialMapCenter,
    );
    expect(screenPoint, isNotNull);

    final LatLng? latLng = await controller.getLatLng(screenPoint!);
    expect(latLng, isNotNull);
    expect(latLng!.latitude, closeTo(_kInitialMapCenter.latitude, 0.01));
    expect(latLng.longitude, closeTo(_kInitialMapCenter.longitude, 0.01));
  });

  testWidgets('testCameraEventSequence', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<AppleMapController> controllerCompleter =
        Completer<AppleMapController>();
    final List<String> events = <String>[];
    final Completer<void> idleCompleter = Completer<void>();

    await _pumpMap(
      tester,
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          onMapCreated: controllerCompleter.complete,
          onCameraMoveStarted: () {
            events.add('moveStarted');
          },
          onCameraMove: (CameraPosition position) {
            events.add('move');
          },
          onCameraIdle: () {
            events.add('idle');
            if (!idleCompleter.isCompleted) {
              idleCompleter.complete();
            }
          },
        ),
      ),
    );

    final AppleMapController controller = await controllerCompleter.future;
    await Future<void>.delayed(const Duration(seconds: 1));
    events.clear();

    await controller.moveCamera(
      CameraUpdate.newLatLng(const LatLng(10.0, 20.0)),
    );

    await idleCompleter.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {},
    );

    expect(events, contains('moveStarted'));
    expect(events, contains('idle'));
    final int moveStartedIndex = events.indexOf('moveStarted');
    final int idleIndex = events.indexOf('idle');
    expect(moveStartedIndex, lessThan(idleIndex));
  });
}
