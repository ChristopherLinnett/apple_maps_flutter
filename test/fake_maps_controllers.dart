// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:apple_maps_flutter/src/messages.g.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class FakePlatformAppleMap {
  FakePlatformAppleMap(this.id, Map<dynamic, dynamic> params) {
    cameraPosition = CameraPosition.fromMap(params['initialCameraPosition']);
    channel = MethodChannel(
      'apple_maps_plugin.luisthein.de/apple_maps_$id',
      const StandardMethodCodec(),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, onMethodCall);
    _registerTypedHandlers();
    updateOptions(params['options']);
    updatePolylines(params);
    updateAnnotations(params);
    updatePolygons(params);
    updateCircles(params);
  }

  final int id;

  late MethodChannel channel;

  final List<BasicMessageChannel<Object?>> _typedChannels =
      <BasicMessageChannel<Object?>>[];

  bool disposed = false;
  bool infoWindowShown = false;
  String? lastShownInfoWindowAnnotationId;
  String? lastHiddenInfoWindowAnnotationId;
  CameraUpdate? lastAnimatedCameraUpdate;
  CameraUpdate? lastMovedCameraUpdate;
  PlatformCameraUpdate? lastAnimatedPlatformCameraUpdate;
  PlatformCameraUpdate? lastMovedPlatformCameraUpdate;
  Uint8List? snapshotBytes;
  int disposeCallCount = 0;
  Offset? lastScreenCoordinateTarget;
  List<int> takenSnapshotFlags = <int>[];

  CameraPosition? cameraPosition;

  bool? compassEnabled;

  MapType? mapType;

  MinMaxZoomPreference? minMaxZoomPreference;

  EdgeInsets? padding;

  int mapUpdateCallCount = 0;

  bool? rotateGesturesEnabled;

  bool? scrollGesturesEnabled;

  bool? pitchGesturesEnabled;

  bool? zoomGesturesEnabled;

  bool? myLocationEnabled;

  bool? myLocationButtonEnabled;

  Set<AnnotationId>? annotationIdsToRemove;

  Set<Annotation>? annotationsToAdd;

  Set<Annotation>? annotationsToChange;

  PlatformAnnotationUpdates? lastPlatformAnnotationUpdates;

  Set<PolylineId>? polylineIdsToRemove;

  Set<Polyline>? polylinesToAdd;

  Set<Polyline>? polylinesToChange;

  PlatformPolylineUpdates? lastPlatformPolylineUpdates;

  Set<PolygonId>? polygonIdsToRemove;

  Set<Polygon>? polygonsToAdd;

  Set<Polygon>? polygonsToChange;

  PlatformPolygonUpdates? lastPlatformPolygonUpdates;

  Set<CircleId>? circleIdsToRemove;

  Set<Circle>? circlesToAdd;

  Set<Circle>? circlesToChange;

  PlatformCircleUpdates? lastPlatformCircleUpdates;

  bool delayDisposeResponses = false;
  Completer<void>? pendingDisposeCompleter;

  Future<dynamic> onMethodCall(MethodCall call) {
    return Future<void>.sync(() {});
  }

  void updateAnnotations(Map<dynamic, dynamic>? annotationUpdates) {
    if (annotationUpdates == null) {
      return;
    }
    annotationsToAdd = _deserializeAnnotations(
      annotationUpdates['annotationsToAdd'],
    );
    annotationIdsToRemove = _deserializeAnnotationIds(
      annotationUpdates['annotationIdsToRemove'],
    );
    annotationsToChange = _deserializeAnnotations(
      annotationUpdates['annotationsToChange'],
    );
  }

  Set<AnnotationId> _deserializeAnnotationIds(List<dynamic>? annotationIds) {
    if (annotationIds == null) {
      return Set<AnnotationId>();
    }
    return annotationIds
        .map((dynamic annotationId) => AnnotationId(annotationId))
        .toSet();
  }

  Set<Annotation> _deserializeAnnotations(dynamic annotations) {
    if (annotations == null) {
      return Set<Annotation>();
    }
    final List<dynamic> annotationsData = annotations;
    final Set<Annotation> result = Set<Annotation>();
    for (Map<dynamic, dynamic> annotationData in annotationsData) {
      final String annotationId = annotationData['annotationId'];
      final bool draggable = annotationData['draggable'];
      final bool visible = annotationData['visible'];
      final double alpha = annotationData['alpha'];

      final dynamic infoWindowData = annotationData['infoWindow'];
      InfoWindow infoWindow = InfoWindow.noText;
      if (infoWindowData != null) {
        final Map<dynamic, dynamic> infoWindowMap = infoWindowData;
        infoWindow = InfoWindow(
          title: infoWindowMap['title'],
          snippet: infoWindowMap['snippet'],
        );
      }

      result.add(
        Annotation(
          annotationId: AnnotationId(annotationId),
          draggable: draggable,
          visible: visible,
          infoWindow: infoWindow,
          alpha: alpha,
        ),
      );
    }

    return result;
  }

  void updatePolylines(Map<dynamic, dynamic>? polylineUpdates) {
    if (polylineUpdates == null) {
      return;
    }
    polylinesToAdd = _deserializePolylines(polylineUpdates['polylinesToAdd']);
    polylineIdsToRemove = _deserializePolylineIds(
      polylineUpdates['polylineIdsToRemove'],
    );
    polylinesToChange = _deserializePolylines(
      polylineUpdates['polylinesToChange'],
    );
  }

  Set<PolylineId> _deserializePolylineIds(List<dynamic>? polylineIds) {
    if (polylineIds == null) {
      return Set<PolylineId>();
    }
    return polylineIds
        .map((dynamic polylineId) => PolylineId(polylineId))
        .toSet();
  }

  Set<Polyline> _deserializePolylines(dynamic polylines) {
    if (polylines == null) {
      return Set<Polyline>();
    }
    final List<dynamic> polylinesData = polylines;
    final Set<Polyline> result = Set<Polyline>();
    for (Map<dynamic, dynamic> polylineData in polylinesData) {
      final String polylineId = polylineData['polylineId'];
      final bool visible = polylineData['visible'];
      // final bool geodesic = polylineData['geodesic'];

      result.add(
        Polyline(
          polylineId: PolylineId(polylineId),
          visible: visible,
          // geodesic: geodesic,
        ),
      );
    }

    return result;
  }

  void updatePolygons(Map<dynamic, dynamic>? polygonUpdates) {
    if (polygonUpdates == null) {
      return;
    }
    polygonsToAdd = _deserializePolygons(polygonUpdates['polygonsToAdd']);
    polygonIdsToRemove = _deserializePolygonIds(
      polygonUpdates['polygonIdsToRemove'],
    );
    polygonsToChange = _deserializePolygons(polygonUpdates['polygonsToChange']);
  }

  Set<PolygonId> _deserializePolygonIds(List<dynamic>? polygonIds) {
    if (polygonIds == null) {
      return Set<PolygonId>();
    }
    return polygonIds.map((dynamic polygonId) => PolygonId(polygonId)).toSet();
  }

  Set<Polygon> _deserializePolygons(dynamic polygons) {
    if (polygons == null) {
      return Set<Polygon>();
    }
    final List<dynamic> polygonsData = polygons;
    final Set<Polygon> result = Set<Polygon>();
    for (Map<dynamic, dynamic> polygonData in polygonsData) {
      final String polygonId = polygonData['polygonId'];
      final bool visible = polygonData['visible'];
      final bool consumeTapEvent = polygonData['consumeTapEvents'];
      final List<LatLng> points = _deserializePoints(polygonData['points']);

      result.add(
        Polygon(
          polygonId: PolygonId(polygonId),
          visible: visible,
          points: points,
          consumeTapEvents: consumeTapEvent,
        ),
      );
    }

    return result;
  }

  List<LatLng> _deserializePoints(List<dynamic> points) {
    return points.map<LatLng>((dynamic list) {
      return LatLng(list[0], list[1]);
    }).toList();
  }

  void updateCircles(Map<dynamic, dynamic>? circleUpdates) {
    if (circleUpdates == null) {
      return;
    }
    circlesToAdd = _deserializeCircles(circleUpdates['circlesToAdd']);
    circleIdsToRemove = _deserializeCircleIds(
      circleUpdates['circleIdsToRemove'],
    );
    circlesToChange = _deserializeCircles(circleUpdates['circlesToChange']);
  }

  Set<CircleId>? _deserializeCircleIds(List<dynamic>? circleIds) {
    if (circleIds == null) {
      return Set<CircleId>();
    }
    return circleIds.map((dynamic circleId) => CircleId(circleId)).toSet();
  }

  Set<Circle> _deserializeCircles(dynamic circles) {
    if (circles == null) {
      return Set<Circle>();
    }
    final List<dynamic> circlesData = circles;
    final Set<Circle> result = Set<Circle>();
    for (Map<dynamic, dynamic> circleData in circlesData) {
      final String circleId = circleData['circleId'];
      final bool visible = circleData['visible'];
      final double radius = circleData['radius'];

      result.add(
        Circle(circleId: CircleId(circleId), visible: visible, radius: radius),
      );
    }

    return result;
  }

  void updateOptions(Map<dynamic, dynamic> options) {
    if (options.containsKey('compassEnabled')) {
      compassEnabled = options['compassEnabled'];
    }
    if (options.containsKey('mapType')) {
      mapType = MapType.values[options['mapType']];
    }
    if (options.containsKey('minMaxZoomPreference')) {
      final List<dynamic> minMaxZoomList = options['minMaxZoomPreference'];
      minMaxZoomPreference = MinMaxZoomPreference(
        minMaxZoomList[0],
        minMaxZoomList[1],
      );
    }
    if (options.containsKey('rotateGesturesEnabled')) {
      rotateGesturesEnabled = options['rotateGesturesEnabled'];
    }
    if (options.containsKey('scrollGesturesEnabled')) {
      scrollGesturesEnabled = options['scrollGesturesEnabled'];
    }
    if (options.containsKey('pitchGesturesEnabled')) {
      pitchGesturesEnabled = options['pitchGesturesEnabled'];
    }
    if (options.containsKey('zoomGesturesEnabled')) {
      zoomGesturesEnabled = options['zoomGesturesEnabled'];
    }
    if (options.containsKey('myLocationEnabled')) {
      myLocationEnabled = options['myLocationEnabled'];
    }
    if (options.containsKey('myLocationButtonEnabled')) {
      myLocationButtonEnabled = options['myLocationButtonEnabled'];
    }
    if (options.containsKey('padding')) {
      final List<dynamic> paddingList = options['padding'];
      padding = EdgeInsets.fromLTRB(
        paddingList[1] as double,
        paddingList[0] as double,
        paddingList[3] as double,
        paddingList[2] as double,
      );
    }
  }

  void updateOptionsFromPlatform(PlatformMapOptions options) {
    if (options.compassEnabled != null) {
      compassEnabled = options.compassEnabled;
    }
    if (options.mapType != null) {
      mapType = MapType.values[options.mapType!];
    }
    if (options.minMaxZoomPreference != null) {
      minMaxZoomPreference = MinMaxZoomPreference(
        options.minMaxZoomPreference!.minZoom,
        options.minMaxZoomPreference!.maxZoom,
      );
    }
    if (options.rotateGesturesEnabled != null) {
      rotateGesturesEnabled = options.rotateGesturesEnabled;
    }
    if (options.scrollGesturesEnabled != null) {
      scrollGesturesEnabled = options.scrollGesturesEnabled;
    }
    if (options.pitchGesturesEnabled != null) {
      pitchGesturesEnabled = options.pitchGesturesEnabled;
    }
    if (options.zoomGesturesEnabled != null) {
      zoomGesturesEnabled = options.zoomGesturesEnabled;
    }
    if (options.myLocationEnabled != null) {
      myLocationEnabled = options.myLocationEnabled;
    }
    if (options.myLocationButtonEnabled != null) {
      myLocationButtonEnabled = options.myLocationButtonEnabled;
    }
    if (options.padding != null) {
      padding = EdgeInsets.fromLTRB(
        options.padding!.left,
        options.padding!.top,
        options.padding!.right,
        options.padding!.bottom,
      );
    }
  }

  void updateAnnotationsFromPlatform(PlatformAnnotationUpdates updates) {
    lastPlatformAnnotationUpdates = updates;
    annotationsToAdd = _deserializePlatformAnnotations(
      updates.annotationsToAdd,
    );
    annotationIdsToRemove = (updates.annotationIdsToRemove ?? <String>[])
        .map(AnnotationId.new)
        .toSet();
    annotationsToChange = _deserializePlatformAnnotations(
      updates.annotationsToChange,
    );
  }

  Set<Annotation> _deserializePlatformAnnotations(
    List<PlatformAnnotation>? annotations,
  ) {
    if (annotations == null) {
      return <Annotation>{};
    }
    return annotations
        .map(
          (PlatformAnnotation annotation) => Annotation(
            annotationId: AnnotationId(annotation.annotationId),
            anchor: Offset(annotation.anchor.x, annotation.anchor.y),
            draggable: annotation.draggable,
            visible: annotation.visible,
            icon: _bitmapDescriptorFromPlatform(annotation.icon),
            infoWindow: InfoWindow(
              title: annotation.infoWindow.title,
              snippet: annotation.infoWindow.snippet,
              anchor: annotation.infoWindow.anchor == null
                  ? const Offset(0.5, 0.0)
                  : Offset(
                      annotation.infoWindow.anchor!.x,
                      annotation.infoWindow.anchor!.y,
                    ),
              onTap: annotation.infoWindow.consumesTapEvents ? () {} : null,
            ),
            position: LatLng(
              annotation.position.latitude,
              annotation.position.longitude,
            ),
            alpha: annotation.alpha,
            zIndex: annotation.zIndex,
          ),
        )
        .toSet();
  }

  void updatePolylinesFromPlatform(PlatformPolylineUpdates updates) {
    lastPlatformPolylineUpdates = updates;
    polylinesToAdd = _deserializePlatformPolylines(updates.polylinesToAdd);
    polylineIdsToRemove = (updates.polylineIdsToRemove ?? <String>[])
        .map(PolylineId.new)
        .toSet();
    polylinesToChange = _deserializePlatformPolylines(
      updates.polylinesToChange,
    );
  }

  Set<Polyline> _deserializePlatformPolylines(
    List<PlatformPolyline>? polylines,
  ) {
    if (polylines == null) {
      return <Polyline>{};
    }
    return polylines
        .map(
          (PlatformPolyline polyline) => Polyline(
            polylineId: PolylineId(polyline.polylineId),
            consumeTapEvents: polyline.consumeTapEvents,
            color: Color(polyline.color),
            polylineCap: _capFromPlatform(polyline.polylineCap),
            jointType: _jointTypeFromPlatform(polyline.jointType),
            visible: polyline.visible,
            width: polyline.width,
            zIndex: polyline.zIndex,
            points: polyline.points
                .map(
                  (PlatformLatLng point) =>
                      LatLng(point.latitude, point.longitude),
                )
                .toList(),
            patterns: polyline.patterns.map(_patternItemFromPlatform).toList(),
          ),
        )
        .toSet();
  }

  void updatePolygonsFromPlatform(PlatformPolygonUpdates updates) {
    lastPlatformPolygonUpdates = updates;
    polygonsToAdd = _deserializePlatformPolygons(updates.polygonsToAdd);
    polygonIdsToRemove = (updates.polygonIdsToRemove ?? <String>[])
        .map(PolygonId.new)
        .toSet();
    polygonsToChange = _deserializePlatformPolygons(updates.polygonsToChange);
  }

  Set<Polygon> _deserializePlatformPolygons(List<PlatformPolygon>? polygons) {
    if (polygons == null) {
      return <Polygon>{};
    }
    return polygons
        .map(
          (PlatformPolygon polygon) => Polygon(
            polygonId: PolygonId(polygon.polygonId),
            fillColor: Color(polygon.fillColor),
            visible: polygon.visible,
            points: polygon.points
                .map(
                  (PlatformLatLng point) =>
                      LatLng(point.latitude, point.longitude),
                )
                .toList(),
            consumeTapEvents: polygon.consumeTapEvents,
            strokeColor: Color(polygon.strokeColor),
            strokeWidth: polygon.strokeWidth,
            zIndex: polygon.zIndex,
          ),
        )
        .toSet();
  }

  void updateCirclesFromPlatform(PlatformCircleUpdates updates) {
    lastPlatformCircleUpdates = updates;
    circlesToAdd = _deserializePlatformCircles(updates.circlesToAdd);
    circleIdsToRemove = (updates.circleIdsToRemove ?? <String>[])
        .map(CircleId.new)
        .toSet();
    circlesToChange = _deserializePlatformCircles(updates.circlesToChange);
  }

  Set<Circle> _deserializePlatformCircles(List<PlatformCircle>? circles) {
    if (circles == null) {
      return <Circle>{};
    }
    return circles
        .map(
          (PlatformCircle circle) => Circle(
            circleId: CircleId(circle.circleId),
            consumeTapEvents: circle.consumeTapEvents,
            fillColor: Color(circle.fillColor),
            center: LatLng(circle.center.latitude, circle.center.longitude),
            visible: circle.visible,
            radius: circle.radius,
            strokeColor: Color(circle.strokeColor),
            strokeWidth: circle.strokeWidth,
            zIndex: circle.zIndex,
          ),
        )
        .toSet();
  }

  BitmapDescriptor _bitmapDescriptorFromPlatform(
    PlatformBitmapDescriptor icon,
  ) {
    switch (icon.type) {
      case BitmapDescriptorType.defaultAnnotation:
        if (icon.hue != null) {
          return BitmapDescriptor.defaultAnnotationWithHue(icon.hue! * 360.0);
        }
        return BitmapDescriptor.defaultAnnotation;
      case BitmapDescriptorType.markerAnnotation:
        if (icon.hue != null) {
          return BitmapDescriptor.markerAnnotationWithHue(icon.hue! * 360.0);
        }
        return BitmapDescriptor.markerAnnotation;
      case BitmapDescriptorType.fromAssetImage:
        return BitmapDescriptor.defaultAnnotation;
      case BitmapDescriptorType.fromBytes:
        return BitmapDescriptor.fromBytes(icon.bytes!);
    }
  }

  JointType _jointTypeFromPlatform(int jointType) {
    switch (jointType) {
      case 0:
        return JointType.mitered;
      case 1:
        return JointType.bevel;
      case 2:
        return JointType.round;
      default:
        return JointType.round;
    }
  }

  Cap _capFromPlatform(CapType capType) {
    switch (capType) {
      case CapType.buttCap:
        return Cap.buttCap;
      case CapType.roundCap:
        return Cap.roundCap;
      case CapType.squareCap:
        return Cap.squareCap;
    }
  }

  PatternItem _patternItemFromPlatform(PlatformPatternItem item) {
    switch (item.type) {
      case PatternItemType.dot:
        return PatternItem.dot;
      case PatternItemType.dash:
        return PatternItem.dash(item.length!);
      case PatternItemType.gap:
        return PatternItem.gap(item.length!);
    }
  }

  void disposeMockHandlers() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    for (final BasicMessageChannel<Object?> typedChannel in _typedChannels) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(typedChannel, null);
    }
    _typedChannels.clear();
  }

  void _registerTypedHandlers() {
    _registerTypedHandler('updateMapOptions', (Object? message) async {
      final PlatformMapOptions options =
          (message as List<Object?>)[0]! as PlatformMapOptions;
      mapUpdateCallCount += 1;
      updateOptionsFromPlatform(options);
      return <Object?>[null];
    });
    _registerTypedHandler('updateAnnotations', (Object? message) async {
      final PlatformAnnotationUpdates updates =
          (message as List<Object?>)[0]! as PlatformAnnotationUpdates;
      updateAnnotationsFromPlatform(updates);
      return <Object?>[null];
    });
    _registerTypedHandler('updatePolylines', (Object? message) async {
      final PlatformPolylineUpdates updates =
          (message as List<Object?>)[0]! as PlatformPolylineUpdates;
      updatePolylinesFromPlatform(updates);
      return <Object?>[null];
    });
    _registerTypedHandler('updatePolygons', (Object? message) async {
      final PlatformPolygonUpdates updates =
          (message as List<Object?>)[0]! as PlatformPolygonUpdates;
      updatePolygonsFromPlatform(updates);
      return <Object?>[null];
    });
    _registerTypedHandler('updateCircles', (Object? message) async {
      final PlatformCircleUpdates updates =
          (message as List<Object?>)[0]! as PlatformCircleUpdates;
      updateCirclesFromPlatform(updates);
      return <Object?>[null];
    });
    _registerTypedHandler('dispose', (Object? message) async {
      disposeCallCount += 1;
      disposed = true;
      if (delayDisposeResponses) {
        pendingDisposeCompleter ??= Completer<void>();
        await pendingDisposeCompleter!.future;
      }
      return <Object?>[null];
    });
    _registerTypedHandler('getZoomLevel', (Object? message) async {
      return <Object?>[cameraPosition?.zoom];
    });
    _registerTypedHandler('getVisibleRegion', (Object? message) async {
      final LatLng target = cameraPosition?.target ?? const LatLng(0, 0);
      return <Object?>[
        PlatformLatLngBounds(
          southwest: PlatformLatLng(
            latitude: target.latitude,
            longitude: target.longitude,
          ),
          northeast: PlatformLatLng(
            latitude: target.latitude,
            longitude: target.longitude,
          ),
        ),
      ];
    });
    _registerTypedHandler('getScreenCoordinate', (Object? message) async {
      final PlatformLatLng latLng =
          (message as List<Object?>)[0]! as PlatformLatLng;
      lastScreenCoordinateTarget = Offset(latLng.latitude, latLng.longitude);
      return <Object?>[
        PlatformScreenCoordinate(x: latLng.latitude, y: latLng.longitude),
      ];
    });
    _registerTypedHandler('isMarkerInfoWindowShown', (Object? message) async {
      return <Object?>[infoWindowShown];
    });
    _registerTypedHandler('showMarkerInfoWindow', (Object? message) async {
      final String annotationId = (message as List<Object?>)[0]! as String;
      infoWindowShown = true;
      lastShownInfoWindowAnnotationId = annotationId;
      return <Object?>[null];
    });
    _registerTypedHandler('hideMarkerInfoWindow', (Object? message) async {
      final String annotationId = (message as List<Object?>)[0]! as String;
      infoWindowShown = false;
      lastHiddenInfoWindowAnnotationId = annotationId;
      return <Object?>[null];
    });
    _registerTypedHandler('animateCamera', (Object? message) async {
      final PlatformCameraUpdate update =
          (message as List<Object?>)[0]! as PlatformCameraUpdate;
      lastAnimatedPlatformCameraUpdate = update;
      lastAnimatedCameraUpdate = _cameraUpdateFromPlatform(update);
      return <Object?>[null];
    });
    _registerTypedHandler('moveCamera', (Object? message) async {
      final PlatformCameraUpdate update =
          (message as List<Object?>)[0]! as PlatformCameraUpdate;
      lastMovedPlatformCameraUpdate = update;
      lastMovedCameraUpdate = _cameraUpdateFromPlatform(update);
      return <Object?>[null];
    });
    _registerTypedHandler('takeSnapshot', (Object? message) async {
      final PlatformSnapshotOptions options =
          (message as List<Object?>)[0]! as PlatformSnapshotOptions;
      takenSnapshotFlags = <int>[
        options.showBuildings ? 1 : 0,
        options.showPointsOfInterest ? 1 : 0,
        options.showAnnotations ? 1 : 0,
        options.showOverlays ? 1 : 0,
      ];
      return <Object?>[snapshotBytes];
    });
  }

  CameraUpdate _cameraUpdateFromPlatform(PlatformCameraUpdate update) {
    switch (update.type) {
      case CameraUpdateType.newCameraPosition:
        return CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              update.cameraPosition!.target.latitude,
              update.cameraPosition!.target.longitude,
            ),
            heading: update.cameraPosition!.heading,
            pitch: update.cameraPosition!.pitch,
            zoom: update.cameraPosition!.zoom,
          ),
        );
      case CameraUpdateType.newLatLng:
        return CameraUpdate.newLatLng(
          LatLng(update.latLng!.latitude, update.latLng!.longitude),
        );
      case CameraUpdateType.newLatLngZoom:
        return CameraUpdate.newLatLngZoom(
          LatLng(update.latLng!.latitude, update.latLng!.longitude),
          update.zoom!,
        );
      case CameraUpdateType.newLatLngBounds:
        return CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              update.bounds!.southwest.latitude,
              update.bounds!.southwest.longitude,
            ),
            northeast: LatLng(
              update.bounds!.northeast.latitude,
              update.bounds!.northeast.longitude,
            ),
          ),
          update.padding!,
        );
      case CameraUpdateType.zoomBy:
        return CameraUpdate.zoomBy(
          update.zoom!,
          update.focus == null
              ? null
              : Offset(update.focus!.x, update.focus!.y),
        );
      case CameraUpdateType.zoomTo:
        return CameraUpdate.zoomTo(update.zoom!);
      case CameraUpdateType.zoomIn:
        return CameraUpdate.zoomIn();
      case CameraUpdateType.zoomOut:
        return CameraUpdate.zoomOut();
    }
  }

  void completePendingDispose() {
    pendingDisposeCompleter?.complete();
    pendingDisposeCompleter = null;
  }

  void _registerTypedHandler(
    String method,
    Future<Object?> Function(Object? message) handler,
  ) {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
      _typedChannelName(method),
      AppleMapHostApi.pigeonChannelCodec,
    );
    _typedChannels.add(channel);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(channel, handler);
  }

  String _typedChannelName(String method) {
    return 'dev.flutter.pigeon.apple_maps_flutter.AppleMapHostApi.$method.$id';
  }
}

class FakePlatformViewsController {
  FakePlatformAppleMap? lastCreatedView;
  bool delayCreate = false;
  final List<Completer<int>> _pendingCreateCompleters = <Completer<int>>[];

  Future<dynamic> fakePlatformViewsMethodHandler(MethodCall call) {
    switch (call.method) {
      case 'create':
        final Map<dynamic, dynamic> args = call.arguments;
        final Map<dynamic, dynamic> params = _decodeParams(args['params']);
        lastCreatedView = FakePlatformAppleMap(args['id'], params);
        if (delayCreate) {
          final Completer<int> completer = Completer<int>();
          _pendingCreateCompleters.add(completer);
          return completer.future;
        }
        return Future<int>.sync(() => 1);
      default:
        return Future<void>.sync(() {});
    }
  }

  void completePendingCreates([int viewId = 1]) {
    while (_pendingCreateCompleters.isNotEmpty) {
      _pendingCreateCompleters.removeAt(0).complete(viewId);
    }
  }

  void reset() {
    completePendingCreates();
    delayCreate = false;
    lastCreatedView?.disposeMockHandlers();
    lastCreatedView = null;
  }
}

Map<dynamic, dynamic> _decodeParams(Uint8List paramsMessage) {
  final ByteBuffer buffer = paramsMessage.buffer;
  final ByteData messageBytes = buffer.asByteData(
    paramsMessage.offsetInBytes,
    paramsMessage.lengthInBytes,
  );
  return const StandardMessageCodec().decodeMessage(messageBytes);
}
