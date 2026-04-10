// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:apple_maps_flutter/src/messages.g.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_maps_controllers.dart';

Set<Polyline> _toSet({Polyline? p1, Polyline? p2, Polyline? p3}) {
  final Set<Polyline> res = Set<Polyline>.identity();
  if (p1 != null) {
    res.add(p1);
  }
  if (p2 != null) {
    res.add(p2);
  }
  if (p3 != null) {
    res.add(p3);
  }
  return res;
}

Widget _mapWithPolylines(Set<Polyline>? polylines) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: AppleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
      polylines: polylines,
    ),
  );
}

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

  testWidgets('Initializing a polyline', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Polyline p1 = Polyline(polylineId: PolylineId("polyline_1"));
    await tester.pumpWidget(_mapWithPolylines(_toSet(p1: p1)));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.polylinesToAdd!.length, 1);

    final Polyline initializedPolyline = platformAppleMap.polylinesToAdd!.first;
    expect(initializedPolyline, equals(p1));
    expect(platformAppleMap.polylineIdsToRemove!.isEmpty, true);
    expect(platformAppleMap.polylinesToChange!.isEmpty, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets("Adding a polyline", (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Polyline p1 = Polyline(polylineId: PolylineId("polyline_1"));
    final Polyline p2 = Polyline(polylineId: PolylineId("polyline_2"));

    await tester.pumpWidget(_mapWithPolylines(_toSet(p1: p1)));
    await tester.pumpWidget(_mapWithPolylines(_toSet(p1: p1, p2: p2)));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.polylinesToAdd!.length, 1);

    final Polyline addedPolyline = platformAppleMap.polylinesToAdd!.first;
    expect(addedPolyline, equals(p2));
    expect(platformAppleMap.polylineIdsToRemove!.isEmpty, true);

    expect(platformAppleMap.polylinesToChange!.length, 1);
    expect(platformAppleMap.polylinesToChange!.first, equals(p1));
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets("Removing a polyline", (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Polyline p1 = Polyline(polylineId: PolylineId("polyline_1"));

    await tester.pumpWidget(_mapWithPolylines(_toSet(p1: p1)));
    await tester.pumpWidget(_mapWithPolylines(null));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.polylineIdsToRemove!.length, 1);
    expect(platformAppleMap.polylineIdsToRemove!.first, equals(p1.polylineId));

    expect(platformAppleMap.polylinesToChange!.isEmpty, true);
    expect(platformAppleMap.polylinesToAdd!.isEmpty, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets("Updating a polyline", (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Polyline p1 = Polyline(polylineId: PolylineId("polyline_1"));
    final Polyline p2 = Polyline(
      polylineId: PolylineId("polyline_1"),
      visible: true,
    );

    await tester.pumpWidget(_mapWithPolylines(_toSet(p1: p1)));
    await tester.pumpWidget(_mapWithPolylines(_toSet(p1: p2)));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.polylinesToChange!.length, 1);
    expect(platformAppleMap.polylinesToChange!.first, equals(p2));

    expect(platformAppleMap.polylineIdsToRemove!.isEmpty, true);
    expect(platformAppleMap.polylinesToAdd!.isEmpty, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets("Updating a polyline", (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Polyline p1 = Polyline(polylineId: PolylineId("polyline_1"));
    final Polyline p2 = Polyline(
      polylineId: PolylineId("polyline_1"),
      visible: true,
    );

    await tester.pumpWidget(_mapWithPolylines(_toSet(p1: p1)));
    await tester.pumpWidget(_mapWithPolylines(_toSet(p1: p2)));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.polylinesToChange!.length, 1);

    final Polyline update = platformAppleMap.polylinesToChange!.first;
    expect(update, equals(p2));
    expect(update.visible, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    Polyline p1 = Polyline(polylineId: PolylineId("polyline_1"));
    Polyline p2 = Polyline(polylineId: PolylineId("polyline_2"));
    final Set<Polyline> prev = _toSet(p1: p1, p2: p2);
    p1 = Polyline(polylineId: PolylineId("polyline_1"), visible: false);
    p2 = Polyline(polylineId: PolylineId("polyline_2"), consumeTapEvents: true);
    final Set<Polyline> cur = _toSet(p1: p1, p2: p2);

    await tester.pumpWidget(_mapWithPolylines(prev));
    await tester.pumpWidget(_mapWithPolylines(cur));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.polylinesToChange, cur);
    expect(platformAppleMap.polylineIdsToRemove!.isEmpty, true);
    expect(platformAppleMap.polylinesToAdd!.isEmpty, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets("Multi Update", (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    Polyline p2 = Polyline(polylineId: PolylineId("polyline_2"));
    final Polyline p3 = Polyline(polylineId: PolylineId("polyline_3"));
    final Set<Polyline> prev = _toSet(p2: p2, p3: p3);

    // p1 is added, p2 is updated, p3 is removed.
    final Polyline p1 = Polyline(polylineId: PolylineId("polyline_1"));
    p2 = Polyline(polylineId: PolylineId("polyline_2"), visible: true);
    final Set<Polyline> cur = _toSet(p1: p1, p2: p2);

    await tester.pumpWidget(_mapWithPolylines(prev));
    await tester.pumpWidget(_mapWithPolylines(cur));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.polylinesToChange!.length, 1);
    expect(platformAppleMap.polylinesToAdd!.length, 1);
    expect(platformAppleMap.polylineIdsToRemove!.length, 1);

    expect(platformAppleMap.polylinesToChange!.first, equals(p2));
    expect(platformAppleMap.polylinesToAdd!.first, equals(p1));
    expect(platformAppleMap.polylineIdsToRemove!.first, equals(p3.polylineId));
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets("Partial Update", (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Polyline p1 = Polyline(polylineId: PolylineId("polyline_1"));
    Polyline p2 = Polyline(polylineId: PolylineId("polyline_2"));
    final Set<Polyline> prev = _toSet(p1: p1, p2: p2);
    p2 = Polyline(polylineId: PolylineId("polyline_2"), visible: true);
    final Set<Polyline> cur = _toSet(p1: p1, p2: p2);

    await tester.pumpWidget(_mapWithPolylines(prev));
    await tester.pumpWidget(_mapWithPolylines(cur));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.polylinesToChange, _toSet(p2: p2));
    expect(platformAppleMap.polylineIdsToRemove!.isEmpty, true);
    expect(platformAppleMap.polylinesToAdd!.isEmpty, true);
    debugDefaultTargetPlatformOverride = null;
  }, skip: true);

  testWidgets('Typed polyline payload preserves fields', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Polyline polyline = Polyline(
      polylineId: PolylineId('polyline_1'),
      consumeTapEvents: true,
      color: const Color(0xFF123456),
      polylineCap: Cap.roundCap,
      jointType: JointType.bevel,
      visible: false,
      width: 7,
      zIndex: 9,
      points: const <LatLng>[LatLng(1.0, 2.0), LatLng(3.0, 4.0)],
      patterns: <PatternItem>[PatternItem.dash(5), PatternItem.gap(2)],
    );

    await tester.pumpWidget(_mapWithPolylines(null));
    await tester.pumpWidget(_mapWithPolylines(_toSet(p1: polyline)));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    final PlatformPolyline payload =
        platformAppleMap.lastPlatformPolylineUpdates!.polylinesToAdd!.single;

    expect(payload.polylineId, 'polyline_1');
    expect(payload.consumeTapEvents, true);
    expect(payload.color, const Color(0xFF123456).toARGB32());
    expect(payload.polylineCap, CapType.roundCap);
    expect(payload.jointType, JointType.bevel.value);
    expect(payload.visible, false);
    expect(payload.width, 7);
    expect(payload.zIndex, 9);
    expect(payload.points.length, 2);
    expect(payload.points.first.latitude, 1.0);
    expect(payload.points.first.longitude, 2.0);
    expect(payload.points.last.latitude, 3.0);
    expect(payload.points.last.longitude, 4.0);
    expect(payload.patterns.length, 2);
    expect(payload.patterns.first.type, PatternItemType.dash);
    expect(payload.patterns.first.length, 5.0);
    expect(payload.patterns.last.type, PatternItemType.gap);
    expect(payload.patterns.last.length, 2.0);
    debugDefaultTargetPlatformOverride = null;
  });
}
