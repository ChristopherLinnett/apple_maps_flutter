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

Set<Annotation> _toSet({Annotation? m1, Annotation? m2, Annotation? m3}) {
  final Set<Annotation> res = Set<Annotation>.identity();
  if (m1 != null) {
    res.add(m1);
  }
  if (m2 != null) {
    res.add(m2);
  }
  if (m3 != null) {
    res.add(m3);
  }
  return res;
}

Widget _mapWithAnnotations(Set<Annotation>? annotations) {
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  return Directionality(
    textDirection: TextDirection.ltr,
    child: AppleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
      annotations: annotations,
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

  testWidgets('Initializing an annotation', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Annotation m1 = Annotation(
      annotationId: AnnotationId("annotation_1"),
    );
    await tester.pumpWidget(_mapWithAnnotations(_toSet(m1: m1)));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.annotationsToAdd!.length, 1);

    final Annotation initializedAnnotation =
        platformAppleMap.annotationsToAdd!.first;
    expect(initializedAnnotation, equals(m1));
    expect(platformAppleMap.annotationIdsToRemove!.isEmpty, true);
    expect(platformAppleMap.annotationsToChange!.isEmpty, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets("Adding an annotation", (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Annotation m1 = Annotation(
      annotationId: AnnotationId("annotation_1"),
    );
    final Annotation m2 = Annotation(
      annotationId: AnnotationId("annotation_2"),
    );

    await tester.pumpWidget(_mapWithAnnotations(_toSet(m1: m1)));
    await tester.pumpWidget(_mapWithAnnotations(_toSet(m1: m1, m2: m2)));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.annotationsToAdd!.length, 1);

    final Annotation addedAnnotation = platformAppleMap.annotationsToAdd!.first;
    expect(addedAnnotation, equals(m2));
    expect(platformAppleMap.annotationIdsToRemove!.isEmpty, true);

    // m1 has not changed, so it must not appear in annotationsToChange.
    expect(platformAppleMap.annotationsToChange!.isEmpty, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets("Removing an annotation", (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Annotation m1 = Annotation(
      annotationId: AnnotationId("annotation_1"),
    );

    await tester.pumpWidget(_mapWithAnnotations(_toSet(m1: m1)));
    await tester.pumpWidget(_mapWithAnnotations(null));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.annotationIdsToRemove!.length, 1);
    expect(
      platformAppleMap.annotationIdsToRemove!.first,
      equals(m1.annotationId),
    );

    expect(platformAppleMap.annotationsToChange!.isEmpty, true);
    expect(platformAppleMap.annotationsToAdd!.isEmpty, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets("Updating an annotation — alpha", (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Annotation m1 = Annotation(
      annotationId: AnnotationId("annotation_1"),
    );
    final Annotation m2 = Annotation(
      annotationId: AnnotationId("annotation_1"),
      alpha: 0.5,
    );

    await tester.pumpWidget(_mapWithAnnotations(_toSet(m1: m1)));
    await tester.pumpWidget(_mapWithAnnotations(_toSet(m1: m2)));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.annotationsToChange!.length, 1);
    expect(platformAppleMap.annotationsToChange!.first, equals(m2));

    expect(platformAppleMap.annotationIdsToRemove!.isEmpty, true);
    expect(platformAppleMap.annotationsToAdd!.isEmpty, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets("Updating an annotation — infoWindow snippet", (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Annotation m1 = Annotation(
      annotationId: AnnotationId("annotation_1"),
    );
    final Annotation m2 = Annotation(
      annotationId: AnnotationId("annotation_1"),
      infoWindow: const InfoWindow(snippet: 'changed'),
    );

    await tester.pumpWidget(_mapWithAnnotations(_toSet(m1: m1)));
    await tester.pumpWidget(_mapWithAnnotations(_toSet(m1: m2)));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    expect(platformAppleMap.annotationsToChange!.length, 1);

    final Annotation update = platformAppleMap.annotationsToChange!.first;
    expect(update, equals(m2));
    expect(update.infoWindow.snippet, 'changed');
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets("Multi Update — all annotations changed", (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    Annotation m1 = Annotation(annotationId: AnnotationId("annotation_1"));
    Annotation m2 = Annotation(annotationId: AnnotationId("annotation_2"));
    final Set<Annotation> prev = _toSet(m1: m1, m2: m2);
    m1 = Annotation(annotationId: AnnotationId("annotation_1"), alpha: 0.5);
    m2 = Annotation(
      annotationId: AnnotationId("annotation_2"),
      draggable: true,
    );
    final Set<Annotation> cur = _toSet(m1: m1, m2: m2);

    await tester.pumpWidget(_mapWithAnnotations(prev));
    await tester.pumpWidget(_mapWithAnnotations(cur));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.annotationsToChange, cur);
    expect(platformAppleMap.annotationIdsToRemove!.isEmpty, true);
    expect(platformAppleMap.annotationsToAdd!.isEmpty, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets("Multi Update — add, update, and remove combined", (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    Annotation m2 = Annotation(annotationId: AnnotationId("annotation_2"));
    final Annotation m3 = Annotation(
      annotationId: AnnotationId("annotation_3"),
    );
    final Set<Annotation> prev = _toSet(m2: m2, m3: m3);

    // m1 is added, m2 is updated, m3 is removed.
    final Annotation m1 = Annotation(
      annotationId: AnnotationId("annotation_1"),
    );
    m2 = Annotation(
      annotationId: AnnotationId("annotation_2"),
      draggable: true,
    );
    final Set<Annotation> cur = _toSet(m1: m1, m2: m2);

    await tester.pumpWidget(_mapWithAnnotations(prev));
    await tester.pumpWidget(_mapWithAnnotations(cur));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.annotationsToChange!.length, 1);
    expect(platformAppleMap.annotationsToAdd!.length, 1);
    expect(platformAppleMap.annotationIdsToRemove!.length, 1);

    expect(platformAppleMap.annotationsToChange!.first, equals(m2));
    expect(platformAppleMap.annotationsToAdd!.first, equals(m1));
    expect(
      platformAppleMap.annotationIdsToRemove!.first,
      equals(m3.annotationId),
    );
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets("Partial Update", (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Annotation m1 = Annotation(
      annotationId: AnnotationId("annotation_1"),
    );
    Annotation m2 = Annotation(annotationId: AnnotationId("annotation_2"));
    final Set<Annotation> prev = _toSet(m1: m1, m2: m2);
    m2 = Annotation(
      annotationId: AnnotationId("annotation_2"),
      draggable: true,
    );
    final Set<Annotation> cur = _toSet(m1: m1, m2: m2);

    await tester.pumpWidget(_mapWithAnnotations(prev));
    await tester.pumpWidget(_mapWithAnnotations(cur));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.annotationsToChange, _toSet(m2: m2));
    expect(platformAppleMap.annotationIdsToRemove!.isEmpty, true);
    expect(platformAppleMap.annotationsToAdd!.isEmpty, true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Typed annotation payload preserves fields', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Annotation annotation = Annotation(
      annotationId: AnnotationId('annotation_1'),
      alpha: 0.7,
      anchor: const Offset(0.25, 0.75),
      draggable: true,
      icon: BitmapDescriptor.markerAnnotationWithHue(BitmapDescriptor.hueCyan),
      infoWindow: InfoWindow(
        title: 'title',
        snippet: 'snippet',
        anchor: const Offset(0.1, 0.2),
        onTap: () {},
      ),
      position: const LatLng(1.0, 2.0),
      visible: false,
      zIndex: 4,
    );

    await tester.pumpWidget(_mapWithAnnotations(null));
    await tester.pumpWidget(_mapWithAnnotations(_toSet(m1: annotation)));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    final PlatformAnnotation payload = platformAppleMap
        .lastPlatformAnnotationUpdates!
        .annotationsToAdd!
        .single;

    expect(payload.annotationId, 'annotation_1');
    expect(payload.alpha, 0.7);
    expect(payload.anchor.x, 0.25);
    expect(payload.anchor.y, 0.75);
    expect(payload.draggable, true);
    expect(payload.icon.type, BitmapDescriptorType.markerAnnotation);
    expect(payload.icon.hue, BitmapDescriptor.hueCyan / 360.0);
    expect(payload.infoWindow.title, 'title');
    expect(payload.infoWindow.snippet, 'snippet');
    expect(payload.infoWindow.anchor!.x, 0.1);
    expect(payload.infoWindow.anchor!.y, 0.2);
    expect(payload.infoWindow.consumesTapEvents, true);
    expect(payload.visible, false);
    expect(payload.position.latitude, 1.0);
    expect(payload.position.longitude, 2.0);
    expect(payload.zIndex, 4.0);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Unchanged annotation is not resent as a change', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Annotation m1 = Annotation(
      annotationId: AnnotationId('annotation_1'),
      alpha: 0.5,
    );

    await tester.pumpWidget(_mapWithAnnotations(_toSet(m1: m1)));
    // Pump the exact same annotation again — no field changed.
    await tester.pumpWidget(_mapWithAnnotations(_toSet(m1: m1)));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(
      platformAppleMap.annotationsToChange!.isEmpty,
      true,
      reason: 'Unchanged annotations must not be sent as changes',
    );
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('clusteringIdentifier is forwarded through Pigeon payload', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Annotation m1 = Annotation(
      annotationId: AnnotationId('annotation_1'),
      clusteringIdentifier: 'group_a',
    );

    await tester.pumpWidget(_mapWithAnnotations(null));
    await tester.pumpWidget(_mapWithAnnotations(_toSet(m1: m1)));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    final PlatformAnnotation payload = platformAppleMap
        .lastPlatformAnnotationUpdates!
        .annotationsToAdd!
        .single;

    expect(payload.clusteringIdentifier, 'group_a');
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Null clusteringIdentifier is forwarded as null', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Annotation m1 = Annotation(
      annotationId: AnnotationId('annotation_1'),
    );

    await tester.pumpWidget(_mapWithAnnotations(null));
    await tester.pumpWidget(_mapWithAnnotations(_toSet(m1: m1)));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;
    final PlatformAnnotation payload = platformAppleMap
        .lastPlatformAnnotationUpdates!
        .annotationsToAdd!
        .single;

    expect(payload.clusteringIdentifier, isNull);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Changing clusteringIdentifier triggers an annotation change', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final Annotation m1 = Annotation(
      annotationId: AnnotationId('annotation_1'),
    );
    final Annotation m1Clustered = Annotation(
      annotationId: AnnotationId('annotation_1'),
      clusteringIdentifier: 'group_b',
    );

    await tester.pumpWidget(_mapWithAnnotations(_toSet(m1: m1)));
    await tester.pumpWidget(_mapWithAnnotations(_toSet(m1: m1Clustered)));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(platformAppleMap.annotationsToChange!.length, 1);
    expect(
      platformAppleMap.annotationsToChange!.first.clusteringIdentifier,
      'group_b',
    );
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('copyWith can clear clusteringIdentifier to null', (
    WidgetTester tester,
  ) async {
    final Annotation original = Annotation(
      annotationId: AnnotationId('ann1'),
      clusteringIdentifier: 'group_a',
    );
    final Annotation cleared = original.copyWith(
      clusteringIdentifierParam: null,
    );
    expect(cleared.clusteringIdentifier, isNull);
  });

  testWidgets('Annotation with InfoWindow(onTap:) is not resent when unchanged', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    // InfoWindow carries a tap callback; rebuild with equal model state must
    // not be misidentified as a change (InfoWindow.== must not compare onTap).
    final Annotation m1 = Annotation(
      annotationId: AnnotationId('annotation_1'),
      infoWindow: InfoWindow(title: 'Hello', onTap: () {}),
    );

    await tester.pumpWidget(_mapWithAnnotations(_toSet(m1: m1)));
    // Rebuild with an annotation whose model fields are identical. The lambda
    // is a different object but should not trigger a diff.
    final Annotation m1Same = Annotation(
      annotationId: AnnotationId('annotation_1'),
      infoWindow: InfoWindow(title: 'Hello', onTap: () {}),
    );
    await tester.pumpWidget(_mapWithAnnotations(_toSet(m1: m1Same)));

    final FakePlatformAppleMap platformAppleMap =
        fakePlatformViewsController.lastCreatedView!;

    expect(
      platformAppleMap.annotationsToChange!.isEmpty,
      true,
      reason:
          'Callback-field differences must not produce annotation change events',
    );
    debugDefaultTargetPlatformOverride = null;
  });
}
