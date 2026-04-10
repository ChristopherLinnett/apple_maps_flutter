part of apple_maps_flutter;

PlatformMapOptions _platformMapOptionsFromMap(Map<String, dynamic> map) {
  return PlatformMapOptions(
    compassEnabled: map['compassEnabled'] as bool?,
    trafficEnabled: map['trafficEnabled'] as bool?,
    mapType: map['mapType'] as int?,
    minMaxZoomPreference: _platformMinMaxZoomPreferenceFromDynamic(
      map['minMaxZoomPreference'],
    ),
    cameraTargetBounds: map.containsKey('cameraTargetBounds')
        ? PlatformCameraTargetBounds(
            bounds: _platformLatLngBoundsFromFlatList(
              map['cameraTargetBounds'],
            ),
          )
        : null,
    rotateGesturesEnabled: map['rotateGesturesEnabled'] as bool?,
    scrollGesturesEnabled: map['scrollGesturesEnabled'] as bool?,
    pitchGesturesEnabled: map['pitchGesturesEnabled'] as bool?,
    trackingMode: map['trackingMode'] as int?,
    zoomGesturesEnabled: map['zoomGesturesEnabled'] as bool?,
    myLocationEnabled: map['myLocationEnabled'] as bool?,
    myLocationButtonEnabled: map['myLocationButtonEnabled'] as bool?,
    buildingsEnabled: map['buildingsEnabled'] as bool?,
    pointsOfInterestEnabled: map['pointsOfInterestEnabled'] as bool?,
    scaleEnabled: map['scaleEnabled'] as bool?,
    padding: _platformPaddingFromDynamic(map['padding']),
    insetsLayoutMarginsFromSafeArea:
        map['insetsLayoutMarginsFromSafeArea'] as bool?,
  );
}

PlatformAnnotationUpdates _platformAnnotationUpdatesFromAnnotationUpdates(
  _AnnotationUpdates updates,
) {
  return PlatformAnnotationUpdates(
    annotationsToAdd: updates.annotationsToAdd
        .map(_platformAnnotationFromAnnotation)
        .toList(),
    annotationsToChange: updates.annotationsToChange
        .map(_platformAnnotationFromAnnotation)
        .toList(),
    annotationIdsToRemove: updates.annotationIdsToRemove
        .map((AnnotationId id) => id.value)
        .toList(),
  );
}

PlatformPolylineUpdates _platformPolylineUpdatesFromPolylineUpdates(
  _PolylineUpdates updates,
) {
  return PlatformPolylineUpdates(
    polylinesToAdd: updates.polylinesToAdd
        .map(_platformPolylineFromPolyline)
        .toList(),
    polylinesToChange: updates.polylinesToChange
        .map(_platformPolylineFromPolyline)
        .toList(),
    polylineIdsToRemove: updates.polylineIdsToRemove
        .map((PolylineId id) => id.value)
        .toList(),
  );
}

PlatformPolygonUpdates _platformPolygonUpdatesFromPolygonUpdates(
  _PolygonUpdates updates,
) {
  return PlatformPolygonUpdates(
    polygonsToAdd: updates.polygonsToAdd
        .map(_platformPolygonFromPolygon)
        .toList(),
    polygonsToChange: updates.polygonsToChange
        .map(_platformPolygonFromPolygon)
        .toList(),
    polygonIdsToRemove: updates.polygonIdsToRemove
        .map((PolygonId id) => id.value)
        .toList(),
  );
}

PlatformCircleUpdates _platformCircleUpdatesFromCircleUpdates(
  _CircleUpdates updates,
) {
  return PlatformCircleUpdates(
    circlesToAdd: updates.circlesToAdd.map(_platformCircleFromCircle).toList(),
    circlesToChange: updates.circlesToChange
        .map(_platformCircleFromCircle)
        .toList(),
    circleIdsToRemove: updates.circleIdsToRemove
        .map((CircleId id) => id.value)
        .toList(),
  );
}

PlatformCameraUpdate _platformCameraUpdateFromCameraUpdate(
  CameraUpdate cameraUpdate,
) {
  final List<dynamic> json = cameraUpdate._toJson() as List<dynamic>;
  final String updateType = json[0] as String;

  switch (updateType) {
    case 'newCameraPosition':
      return PlatformCameraUpdate(
        type: CameraUpdateType.newCameraPosition,
        cameraPosition: _platformCameraPositionFromCameraPosition(
          CameraPosition.fromMap(json[1])!,
        ),
      );
    case 'newLatLng':
      return PlatformCameraUpdate(
        type: CameraUpdateType.newLatLng,
        latLng: _platformLatLngFromLatLng(LatLng._fromJson(json[1])!),
      );
    case 'newLatLngZoom':
      return PlatformCameraUpdate(
        type: CameraUpdateType.newLatLngZoom,
        latLng: _platformLatLngFromLatLng(LatLng._fromJson(json[1])!),
        zoom: (json[2] as num).toDouble(),
      );
    case 'newLatLngBounds':
      return PlatformCameraUpdate(
        type: CameraUpdateType.newLatLngBounds,
        bounds: _platformLatLngBoundsFromLatLngBounds(
          LatLngBounds.fromList(json[1])!,
        ),
        padding: (json[2] as num).toDouble(),
      );
    case 'zoomBy':
      return PlatformCameraUpdate(
        type: CameraUpdateType.zoomBy,
        zoom: (json[1] as num).toDouble(),
        focus: json.length > 2
            ? _platformOffsetFromDynamic(json[2] as List<dynamic>)
            : null,
      );
    case 'zoomTo':
      return PlatformCameraUpdate(
        type: CameraUpdateType.zoomTo,
        zoom: (json[1] as num).toDouble(),
      );
    case 'zoomIn':
      return PlatformCameraUpdate(type: CameraUpdateType.zoomIn);
    case 'zoomOut':
      return PlatformCameraUpdate(type: CameraUpdateType.zoomOut);
  }

  throw ArgumentError.value(updateType, 'cameraUpdate', 'Unsupported update');
}

PlatformSnapshotOptions _platformSnapshotOptionsFromSnapshotOptions(
  SnapshotOptions options,
) {
  return PlatformSnapshotOptions(
    showBuildings: options.showBuildings,
    showPointsOfInterest: options.showPointsOfInterest,
    showAnnotations: options.showAnnotations,
    showOverlays: options.showOverlays,
  );
}

PlatformLatLng _platformLatLngFromLatLng(LatLng latLng) {
  return PlatformLatLng(latitude: latLng.latitude, longitude: latLng.longitude);
}

PlatformLatLngBounds _platformLatLngBoundsFromLatLngBounds(
  LatLngBounds bounds,
) {
  return PlatformLatLngBounds(
    southwest: _platformLatLngFromLatLng(bounds.southwest),
    northeast: _platformLatLngFromLatLng(bounds.northeast),
  );
}

LatLngBounds _latLngBoundsFromPlatform(PlatformLatLngBounds bounds) {
  return LatLngBounds(
    southwest: LatLng(bounds.southwest.latitude, bounds.southwest.longitude),
    northeast: LatLng(bounds.northeast.latitude, bounds.northeast.longitude),
  );
}

PlatformCameraPosition _platformCameraPositionFromCameraPosition(
  CameraPosition position,
) {
  return PlatformCameraPosition(
    target: _platformLatLngFromLatLng(position.target),
    heading: position.heading,
    pitch: position.pitch,
    zoom: position.zoom,
  );
}

PlatformMinMaxZoomPreference? _platformMinMaxZoomPreferenceFromDynamic(
  dynamic value,
) {
  if (value == null) {
    return null;
  }
  final List<dynamic> zoomRange = value as List<dynamic>;
  return PlatformMinMaxZoomPreference(
    minZoom: (zoomRange[0] as num?)?.toDouble(),
    maxZoom: (zoomRange[1] as num?)?.toDouble(),
  );
}

PlatformLatLngBounds? _platformLatLngBoundsFromFlatList(dynamic value) {
  if (value == null) {
    return null;
  }
  final List<dynamic> flat = value as List<dynamic>;
  return PlatformLatLngBounds(
    southwest: PlatformLatLng(
      latitude: (flat[0] as num).toDouble(),
      longitude: (flat[1] as num).toDouble(),
    ),
    northeast: PlatformLatLng(
      latitude: (flat[2] as num).toDouble(),
      longitude: (flat[3] as num).toDouble(),
    ),
  );
}

PlatformPadding? _platformPaddingFromDynamic(dynamic value) {
  if (value == null) {
    return null;
  }
  final List<dynamic> padding = value as List<dynamic>;
  return PlatformPadding(
    top: (padding[0] as num).toDouble(),
    left: (padding[1] as num).toDouble(),
    bottom: (padding[2] as num).toDouble(),
    right: (padding[3] as num).toDouble(),
  );
}

PlatformOffset _platformOffsetFromOffset(Offset offset) {
  return PlatformOffset(x: offset.dx, y: offset.dy);
}

PlatformOffset _platformOffsetFromDynamic(List<dynamic> value) {
  return PlatformOffset(
    x: (value[0] as num).toDouble(),
    y: (value[1] as num).toDouble(),
  );
}

PlatformAnnotation _platformAnnotationFromAnnotation(Annotation annotation) {
  return PlatformAnnotation(
    annotationId: annotation.annotationId.value,
    alpha: annotation.alpha,
    anchor: _platformOffsetFromOffset(annotation.anchor),
    clusteringIdentifier: annotation.clusteringIdentifier,
    draggable: annotation.draggable,
    icon: _platformBitmapDescriptorFromBitmapDescriptor(annotation.icon),
    infoWindow: _platformInfoWindowFromInfoWindow(annotation.infoWindow),
    visible: annotation.visible,
    position: _platformLatLngFromLatLng(annotation.position),
    zIndex: annotation.zIndex,
  );
}

PlatformInfoWindow _platformInfoWindowFromInfoWindow(InfoWindow infoWindow) {
  return PlatformInfoWindow(
    title: infoWindow.title,
    snippet: infoWindow.snippet,
    anchor: _platformOffsetFromOffset(infoWindow.anchor),
    consumesTapEvents: infoWindow.onTap != null,
  );
}

PlatformBitmapDescriptor _platformBitmapDescriptorFromBitmapDescriptor(
  BitmapDescriptor descriptor,
) {
  final List<dynamic> json = descriptor._toJson() as List<dynamic>;
  final String type = json[0] as String;
  switch (type) {
    case 'defaultAnnotation':
      return PlatformBitmapDescriptor(
        type: BitmapDescriptorType.defaultAnnotation,
        hue: (json.elementAtOrNull(1) as num?)?.toDouble(),
      );
    case 'markerAnnotation':
      return PlatformBitmapDescriptor(
        type: BitmapDescriptorType.markerAnnotation,
        hue: (json.elementAtOrNull(1) as num?)?.toDouble(),
      );
    case 'fromAssetImage':
      return PlatformBitmapDescriptor(
        type: BitmapDescriptorType.fromAssetImage,
        assetName: json[1] as String,
        assetScale: (json[2] as num).toDouble(),
      );
    case 'fromBytes':
      return PlatformBitmapDescriptor(
        type: BitmapDescriptorType.fromBytes,
        bytes: json[1] as Uint8List,
      );
  }

  throw ArgumentError.value(type, 'bitmapDescriptor', 'Unsupported icon');
}

PlatformPolyline _platformPolylineFromPolyline(Polyline polyline) {
  return PlatformPolyline(
    polylineId: polyline.polylineId.value,
    consumeTapEvents: polyline.consumeTapEvents,
    color: polyline.color.toARGB32(),
    polylineCap: _platformCapTypeFromCap(polyline.polylineCap),
    jointType: polyline.jointType.value,
    visible: polyline.visible,
    width: polyline.width,
    zIndex: polyline.zIndex,
    points: polyline.points.map(_platformLatLngFromLatLng).toList(),
    patterns: polyline.patterns
        .map(_platformPatternItemFromPatternItem)
        .toList(),
  );
}

PlatformPatternItem _platformPatternItemFromPatternItem(PatternItem item) {
  final List<dynamic> json = item._toJson() as List<dynamic>;
  final String type = json[0] as String;
  switch (type) {
    case 'dot':
      return PlatformPatternItem(type: PatternItemType.dot);
    case 'dash':
      return PlatformPatternItem(
        type: PatternItemType.dash,
        length: (json[1] as num).toDouble(),
      );
    case 'gap':
      return PlatformPatternItem(
        type: PatternItemType.gap,
        length: (json[1] as num).toDouble(),
      );
  }

  throw ArgumentError.value(type, 'patternItem', 'Unsupported pattern');
}

CapType _platformCapTypeFromCap(Cap cap) {
  switch (cap._toJson() as String) {
    case 'buttCap':
      return CapType.buttCap;
    case 'roundCap':
      return CapType.roundCap;
    case 'squareCap':
      return CapType.squareCap;
  }

  throw ArgumentError.value(cap, 'cap', 'Unsupported line cap');
}

PlatformPolygon _platformPolygonFromPolygon(Polygon polygon) {
  return PlatformPolygon(
    polygonId: polygon.polygonId.value,
    consumeTapEvents: polygon.consumeTapEvents,
    fillColor: polygon.fillColor.toARGB32(),
    points: polygon.points.map(_platformLatLngFromLatLng).toList(),
    strokeColor: polygon.strokeColor.toARGB32(),
    strokeWidth: polygon.strokeWidth,
    visible: polygon.visible,
    zIndex: polygon.zIndex,
  );
}

PlatformCircle _platformCircleFromCircle(Circle circle) {
  return PlatformCircle(
    circleId: circle.circleId.value,
    consumeTapEvents: circle.consumeTapEvents,
    fillColor: circle.fillColor.toARGB32(),
    center: _platformLatLngFromLatLng(circle.center),
    radius: circle.radius,
    strokeColor: circle.strokeColor.toARGB32(),
    strokeWidth: circle.strokeWidth,
    visible: circle.visible,
    zIndex: circle.zIndex,
  );
}
