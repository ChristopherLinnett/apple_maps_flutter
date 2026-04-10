// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
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

  // test('testGetVisibleRegion', () async {
  //   final Key key = GlobalKey();
  //   final LatLngBounds zeroLatLngBounds = LatLngBounds(
  //       southwest: const LatLng(0, 0), northeast: const LatLng(0, 0));

  //   final Completer<AppleMapController> mapControllerCompleter =
  //       Completer<AppleMapController>();

  //   await pumpWidget(Directionality(
  //     textDirection: TextDirection.ltr,
  //     child: AppleMap(
  //       key: key,
  //       initialCameraPosition: _kInitialCameraPosition,
  //       onMapCreated: (AppleMapController controller) {
  //         mapControllerCompleter.complete(controller);
  //       },
  //     ),
  //   ));
  //   final AppleMapController mapController =
  //       await mapControllerCompleter.future;

  //   await Future<dynamic>.delayed(const Duration(seconds: 3));

  //   final LatLngBounds firstVisibleRegion =
  //       await mapController.getVisibleRegion();

  //   expect(firstVisibleRegion, isNotNull);
  //   expect(firstVisibleRegion.southwest, isNotNull);
  //   expect(firstVisibleRegion.northeast, isNotNull);
  //   expect(firstVisibleRegion, isNot(zeroLatLngBounds));
  //   expect(firstVisibleRegion.contains(_kInitialMapCenter), isTrue);

  //   const LatLng southWest = LatLng(60, 75);
  //   const LatLng northEast = LatLng(65, 80);
  //   final LatLng newCenter = LatLng(
  //     (northEast.latitude + southWest.latitude) / 2,
  //     (northEast.longitude + southWest.longitude) / 2,
  //   );

  //   expect(firstVisibleRegion.contains(northEast), isFalse);
  //   expect(firstVisibleRegion.contains(southWest), isFalse);

  //   final LatLngBounds latLngBounds =
  //       LatLngBounds(southwest: southWest, northeast: northEast);

  //   // TODO(iskakaushik): non-zero padding is needed for some device configurations
  //   // https://github.com/flutter/flutter/issues/30575
  //   final double padding = 0;
  //   await mapController
  //       .moveCamera(CameraUpdate.newLatLngBounds(latLngBounds, padding));

  //   final LatLngBounds secondVisibleRegion =
  //       await mapController.getVisibleRegion();

  //   expect(secondVisibleRegion, isNotNull);
  //   expect(secondVisibleRegion.southwest, isNotNull);
  //   expect(secondVisibleRegion.northeast, isNotNull);
  //   expect(secondVisibleRegion, isNot(zeroLatLngBounds));

  //   expect(firstVisibleRegion, isNot(secondVisibleRegion));
  //   expect(secondVisibleRegion.contains(newCenter), isTrue);
  // });

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
}
