// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../apple_maps_flutter.dart';

typedef MapCreatedCallback = void Function(AppleMapController controller);

/// Callback that receives updates to the camera position.
///
/// This callback is triggered when the platform Apple Map
/// registers a camera movement.
///
/// This is used in [AppleMap.onCameraMove].
typedef CameraPositionCallback = void Function(CameraPosition position);

class AppleMap extends StatefulWidget {
  const AppleMap({
    super.key,
    required this.initialCameraPosition,
    this.onMapCreated,
    this.gestureRecognizers,
    this.compassEnabled = true,
    this.trafficEnabled = false,
    this.mapType = MapType.standard,
    this.minMaxZoomPreference = MinMaxZoomPreference.unbounded,
    this.cameraTargetBounds = CameraTargetBounds.unbounded,
    this.trackingMode = TrackingMode.none,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.zoomGesturesEnabled = true,
    this.pitchGesturesEnabled = true,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = false,
    this.buildingsEnabled = true,
    this.pointsOfInterestEnabled = true,
    this.scaleEnabled = false,
    this.emphasisStyle = MapEmphasisStyle.defaultStyle,
    this.selectableFeatures = const {MapSelectableFeature.pointsOfInterest},
    this.padding = EdgeInsets.zero,
    this.annotations,
    this.polylines,
    this.circles,
    this.polygons,
    this.onCameraMoveStarted,
    this.onCameraMove,
    this.onCameraIdle,
    this.onTap,
    this.onLongPress,
    this.onPermissionDenied,
    this.onFeatureTapped,
    this.snapshotOptions,
    this.insetsLayoutMarginsFromSafeArea = true,
  });

  final MapCreatedCallback? onMapCreated;

  /// The initial position of the map's camera.
  final CameraPosition initialCameraPosition;

  /// True if the map should show a compass when rotated.
  final bool compassEnabled;

  /// True if the map should display the current traffic.
  final bool trafficEnabled;

  /// Type of map tiles to be rendered.
  final MapType mapType;

  /// The mode used to track the user location.
  final TrackingMode trackingMode;

  /// Preferred bounds for the camera zoom level.
  ///
  /// Actual bounds depend on map data and device.
  final MinMaxZoomPreference minMaxZoomPreference;

  /// Geographical bounding box for the camera target.
  ///
  /// When set, the map camera will be constrained to the specified region.
  /// Use [CameraTargetBounds.unbounded] to remove the constraint.
  final CameraTargetBounds cameraTargetBounds;

  /// True if the map view should respond to rotate gestures.
  final bool rotateGesturesEnabled;

  /// True if the map view should respond to scroll gestures.
  final bool scrollGesturesEnabled;

  /// True if the map view should respond to zoom gestures.
  final bool zoomGesturesEnabled;

  /// True if the map view should respond to tilt gestures.
  final bool pitchGesturesEnabled;

  /// Annotations to be placed on the map.
  final Set<Annotation>? annotations;

  /// Polylines to be placed on the map.
  final Set<Polyline>? polylines;

  /// Circles to be placed on the map.
  final Set<Circle>? circles;

  /// Polygons to be placed on the map.
  final Set<Polygon>? polygons;

  /// Called when the camera starts moving.
  ///
  /// This can be initiated by the following:
  /// 1. Non-gesture animation initiated in response to user actions.
  ///    For example: zoom buttons, my location button, or annotation clicks.
  /// 2. Programmatically initiated animation.
  /// 3. Camera motion initiated in response to user gestures on the map.
  ///    For example: pan, tilt, pinch to zoom, or rotate.
  final VoidCallback? onCameraMoveStarted;

  /// Called repeatedly as the camera continues to move after an
  /// onCameraMoveStarted call.
  ///
  /// This may be called as often as once every frame and should
  /// not perform expensive operations.
  final CameraPositionCallback? onCameraMove;

  /// Called when camera movement has ended, there are no pending
  /// animations and the user has stopped interacting with the map.
  final VoidCallback? onCameraIdle;

  /// Called every time a [AppleMap] is tapped.
  final ArgumentCallback<LatLng>? onTap;

  /// Called every time a [AppleMap] is long pressed.
  final ArgumentCallback<LatLng>? onLongPress;

  /// Called when the user denies or revokes location permission.
  ///
  /// Fires when the platform reports [CLAuthorizationStatus.denied] or
  /// [CLAuthorizationStatus.restricted] after a permission request triggered
  /// by enabling [myLocationEnabled].
  final VoidCallback? onPermissionDenied;

  /// Called when the user taps a built-in map feature (iOS 16+).
  ///
  /// Fires for points of interest, landmarks, and other native map elements
  /// depending on [selectableFeatures]. This is separate from tapping a
  /// user-defined [Annotation].
  ///
  /// Only called on iOS 16 and later; ignored on earlier OS versions.
  final ArgumentCallback<MapFeature>? onFeatureTapped;

  /// True if a "My Location" layer should be shown on the map.
  ///
  /// This layer includes a location indicator at the current device location,
  /// as well as a My Location button.
  /// * The indicator is a small blue dot if the device is stationary, or a
  /// chevron if the device is moving.
  /// * The My Location button animates to focus on the user's current location
  /// if the user's location is currently known.
  ///
  /// Enabling this feature requires adding location permissions to both native
  /// platforms of your app.
  /// * On iOS add a `NSLocationWhenInUseUsageDescription` key to your
  /// `Info.plist` file. This will automatically prompt the user for permissions
  /// when the map tries to turn on the My Location layer.
  final bool myLocationEnabled;

  /// True if 3D buildings should be shown on the map.
  final bool buildingsEnabled;

  /// True if points of interest should be shown on the map.
  final bool pointsOfInterestEnabled;

  /// True if the map scale indicator should be shown.
  final bool scaleEnabled;

  /// The visual emphasis style for the standard map (iOS 16+).
  ///
  /// Only applies when [mapType] is [MapType.standard]. Ignored on satellite
  /// and hybrid map types, and silently ignored on iOS versions below 16.
  final MapEmphasisStyle emphasisStyle;

  /// The set of built-in map features that can be tapped (iOS 16+).
  ///
  /// Controls which native map elements fire [onFeatureTapped] when tapped.
  /// On iOS versions below 16 this field is ignored and all points of interest
  /// remain tappable by default.
  ///
  /// Defaults to `{MapSelectableFeature.pointsOfInterest}`, which matches the
  /// iOS platform default.
  final Set<MapSelectableFeature> selectableFeatures;

  /// Enables or disables the my-location button.
  ///
  /// The my-location button causes the camera to move such that the user's
  /// location is in the center of the map. If the button is enabled, it is
  /// only shown when the my-location layer is enabled.
  ///
  /// By default, the my-location button is enabled (and hence shown when the
  /// my-location layer is enabled).
  ///
  /// See also:
  ///   * [myLocationEnabled] parameter.
  final bool myLocationButtonEnabled;

  /// Which gestures should be consumed by the map.
  ///
  /// It is possible for other gesture recognizers to be competing with the map on pointer
  /// events, e.g if the map is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The map will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the map will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  /// The padding used on the map
  ///
  /// The amount of additional space (measured in screen points) used for padding for the
  /// native controls.
  final EdgeInsets padding;

  final SnapshotOptions? snapshotOptions;

  /// A Boolean value indicating whether the view's layout margins are updated
  /// automatically to reflect the safe area.
  final bool insetsLayoutMarginsFromSafeArea;

  @override
  State createState() => _AppleMapState();
}

class _AppleMapState extends State<AppleMap> {
  final Completer<AppleMapController?> _controller =
      Completer<AppleMapController?>();
  Future<void> _platformSyncQueue = Future<void>.value();

  Map<AnnotationId, Annotation> _annotations = <AnnotationId, Annotation>{};
  Map<PolylineId, Polyline> _polylines = <PolylineId, Polyline>{};
  Map<PolygonId, Polygon> _polygons = <PolygonId, Polygon>{};
  Map<CircleId, Circle> _circles = <CircleId, Circle>{};
  late _AppleMapOptions _appleMapOptions;
  bool _isDisposed = false;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'initialCameraPosition': widget.initialCameraPosition._toMap(),
      'options': _appleMapOptions.toMap(),
      'annotationsToAdd': _serializeAnnotationSet(widget.annotations),
      'polylinesToAdd': _serializePolylineSet(widget.polylines),
      'polygonsToAdd': _serializePolygonSet(widget.polygons),
      'circlesToAdd': _serializeCircleSet(widget.circles),
    };
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'apple_maps_plugin.luisthein.de/apple_maps',
        onPlatformViewCreated: onPlatformViewCreated,
        gestureRecognizers: widget.gestureRecognizers,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text(
      '$defaultTargetPlatform is not yet supported by the apple maps plugin',
    );
  }

  @override
  void initState() {
    super.initState();
    _appleMapOptions = _AppleMapOptions.fromWidget(widget);
    _annotations = _keyByAnnotationId(widget.annotations);
    _polylines = _keyByPolylineId(widget.polylines);
    _polygons = _keyByPolygonId(widget.polygons);
    _circles = _keyByCircleId(widget.circles);
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (_controller.isCompleted) {
      unawaited(
        _controller.future.then((AppleMapController? controller) {
          return controller?.dispose();
        }),
      );
    } else {
      _controller.complete(null);
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(AppleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _schedulePlatformSync();
  }

  void _schedulePlatformSync() {
    _platformSyncQueue = _platformSyncQueue.then((_) async {
      if (_isDisposed) {
        return;
      }
      try {
        await _synchronizePlatformState();
      } catch (error, stackTrace) {
        if (_isDisposed) {
          return;
        }
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'apple_maps_flutter',
            context: ErrorDescription(
              'while synchronizing map state to the platform view',
            ),
          ),
        );
      }
    });
  }

  Future<void> _synchronizePlatformState() async {
    final AppleMapController? controller = await _controller.future;
    if (_isDisposed || !mounted || controller == null) {
      return;
    }
    await _updateOptions(controller);
    await _updateAnnotations(controller);
    await _updatePolylines(controller);
    await _updatePolygons(controller);
    await _updateCircles(controller);
  }

  Future<void> _updateOptions(AppleMapController controller) async {
    final _AppleMapOptions newOptions = _AppleMapOptions.fromWidget(widget);
    final Map<String, dynamic> updates = _appleMapOptions.updatesMap(
      newOptions,
    );
    if (updates.isEmpty) {
      return;
    }
    await controller._updateMapOptions(updates);
    _appleMapOptions = newOptions;
  }

  Future<void> _updateAnnotations(AppleMapController controller) async {
    await controller._updateAnnotations(
      _AnnotationUpdates.from(_annotations.values.toSet(), widget.annotations),
    );
    _annotations = _keyByAnnotationId(widget.annotations);
  }

  Future<void> _updatePolylines(AppleMapController controller) async {
    await controller._updatePolylines(
      _PolylineUpdates.from(_polylines.values.toSet(), widget.polylines),
    );
    _polylines = _keyByPolylineId(widget.polylines);
  }

  Future<void> _updatePolygons(AppleMapController controller) async {
    await controller._updatePolygons(
      _PolygonUpdates.from(_polygons.values.toSet(), widget.polygons),
    );
    _polygons = _keyByPolygonId(widget.polygons);
  }

  Future<void> _updateCircles(AppleMapController controller) async {
    await controller._updateCircles(
      _CircleUpdates.from(_circles.values.toSet(), widget.circles),
    );
    _circles = _keyByCircleId(widget.circles);
  }

  Future<void> onPlatformViewCreated(int id) async {
    final AppleMapController controller = AppleMapController.init(
      id,
      widget.initialCameraPosition,
      this,
    );
    if (_isDisposed || !mounted || _controller.isCompleted) {
      await controller.dispose();
      return;
    }
    _controller.complete(controller);
    widget.onMapCreated?.call(controller);
  }

  void onAnnotationTap(String annotationIdParam) {
    final AnnotationId annotationId = AnnotationId(annotationIdParam);
    _annotations[annotationId]?.onTap?.call();
  }

  void onAnnotationDragEnd(String annotationIdParam, LatLng position) {
    final AnnotationId annotationId = AnnotationId(annotationIdParam);
    _annotations[annotationId]?.onDragEnd?.call(position);
  }

  void onPolylineTap(String polylineIdParam) {
    final PolylineId polylineId = PolylineId(polylineIdParam);
    _polylines[polylineId]?.onTap?.call();
  }

  void onPolygonTap(String polygonIdParam) {
    final PolygonId polygonId = PolygonId(polygonIdParam);
    _polygons[polygonId]?.onTap?.call();
  }

  void onCircleTap(String circleIdParam) {
    final CircleId circleId = CircleId(circleIdParam);
    _circles[circleId]?.onTap?.call();
  }

  void onInfoWindowTap(String annotationIdParam) {
    final AnnotationId annotationId = AnnotationId(annotationIdParam);
    _annotations[annotationId]?.infoWindow.onTap?.call();
  }

  void onAnnotationZIndexChanged(String annotationIdParam, double zIndex) {
    final AnnotationId annotationId = AnnotationId(annotationIdParam);
    final Annotation? annotation = _annotations[annotationId];
    if (annotation == null) {
      return;
    }
    _annotations[annotationId] = annotation.copyWith(zIndexParam: zIndex);
  }

  void onTap(LatLng position) {
    widget.onTap?.call(position);
  }

  void onLongPress(LatLng position) {
    widget.onLongPress?.call(position);
  }

  void onPermissionDenied() {
    widget.onPermissionDenied?.call();
  }

  void onMapFeatureTapped(MapFeature feature) {
    widget.onFeatureTapped?.call(feature);
  }
}

/// Configuration options for the AppleMaps user interface.
///
/// When used to change configuration, null values will be interpreted as
/// "do not change this configuration option".
class _AppleMapOptions {
  _AppleMapOptions({
    this.compassEnabled,
    this.trafficEnabled,
    this.mapType,
    this.minMaxZoomPreference,
    this.cameraTargetBounds,
    this.rotateGesturesEnabled,
    this.scrollGesturesEnabled,
    this.pitchGesturesEnabled,
    this.trackingMode,
    this.zoomGesturesEnabled,
    this.myLocationEnabled,
    this.myLocationButtonEnabled,
    this.buildingsEnabled,
    this.pointsOfInterestEnabled,
    this.scaleEnabled,
    this.emphasisStyle,
    this.selectableFeatures,
    this.padding,
    this.insetsLayoutMarginsFromSafeArea,
  });

  static _AppleMapOptions fromWidget(AppleMap map) {
    return _AppleMapOptions(
      compassEnabled: map.compassEnabled,
      trafficEnabled: map.trafficEnabled,
      mapType: map.mapType,
      minMaxZoomPreference: map.minMaxZoomPreference,
      cameraTargetBounds: map.cameraTargetBounds,
      rotateGesturesEnabled: map.rotateGesturesEnabled,
      scrollGesturesEnabled: map.scrollGesturesEnabled,
      pitchGesturesEnabled: map.pitchGesturesEnabled,
      trackingMode: map.trackingMode,
      zoomGesturesEnabled: map.zoomGesturesEnabled,
      myLocationEnabled: map.myLocationEnabled,
      myLocationButtonEnabled: map.myLocationButtonEnabled,
      buildingsEnabled: map.buildingsEnabled,
      pointsOfInterestEnabled: map.pointsOfInterestEnabled,
      scaleEnabled: map.scaleEnabled,
      emphasisStyle: map.emphasisStyle,
      selectableFeatures: map.selectableFeatures,
      padding: map.padding,
      insetsLayoutMarginsFromSafeArea: map.insetsLayoutMarginsFromSafeArea,
    );
  }

  final bool? compassEnabled;
  final bool? trafficEnabled;
  final MapType? mapType;
  final MinMaxZoomPreference? minMaxZoomPreference;
  final CameraTargetBounds? cameraTargetBounds;
  final bool? rotateGesturesEnabled;
  final bool? scrollGesturesEnabled;
  final bool? pitchGesturesEnabled;
  final TrackingMode? trackingMode;
  final bool? zoomGesturesEnabled;
  final bool? myLocationEnabled;
  final bool? myLocationButtonEnabled;
  final bool? buildingsEnabled;
  final bool? pointsOfInterestEnabled;
  final bool? scaleEnabled;
  final MapEmphasisStyle? emphasisStyle;
  final Set<MapSelectableFeature>? selectableFeatures;
  final EdgeInsets? padding;
  final bool? insetsLayoutMarginsFromSafeArea;

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> optionsMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        optionsMap[fieldName] = value;
      }
    }

    addIfNonNull('compassEnabled', compassEnabled);
    addIfNonNull('trafficEnabled', trafficEnabled);
    addIfNonNull('mapType', mapType?.index);
    addIfNonNull('minMaxZoomPreference', minMaxZoomPreference?._toJson());
    addIfNonNull('rotateGesturesEnabled', rotateGesturesEnabled);
    addIfNonNull('scrollGesturesEnabled', scrollGesturesEnabled);
    addIfNonNull('pitchGesturesEnabled', pitchGesturesEnabled);
    addIfNonNull('zoomGesturesEnabled', zoomGesturesEnabled);
    addIfNonNull('trackingMode', trackingMode?.index);
    addIfNonNull('myLocationEnabled', myLocationEnabled);
    addIfNonNull('myLocationButtonEnabled', myLocationButtonEnabled);
    addIfNonNull('buildingsEnabled', buildingsEnabled);
    addIfNonNull('pointsOfInterestEnabled', pointsOfInterestEnabled);
    addIfNonNull('scaleEnabled', scaleEnabled);
    addIfNonNull('emphasisStyle', emphasisStyle?.index);
    // Encode selectableFeatures as a bitmask:
    // bit 0 = pointsOfInterest, bit 1 = territories, bit 2 = physicalFeatures.
    if (selectableFeatures != null) {
      int mask = 0;
      if (selectableFeatures!.contains(MapSelectableFeature.pointsOfInterest)) {
        mask |= 1;
      }
      if (selectableFeatures!.contains(MapSelectableFeature.territories)) {
        mask |= 2;
      }
      if (selectableFeatures!.contains(MapSelectableFeature.physicalFeatures)) {
        mask |= 4;
      }
      addIfNonNull('selectableFeatures', mask);
    }
    // CameraTargetBounds is always included so that unbounded (null) is
    // distinguishable from "no change" (key absent) in the diff.
    // Serialized as a flat list [swLat, swLng, neLat, neLng] so that
    // updatesMap()'s listEquals comparison works correctly.
    final LatLngBounds? bounds = cameraTargetBounds?.bounds;
    optionsMap['cameraTargetBounds'] = bounds == null
        ? null
        : <double>[
            bounds.southwest.latitude,
            bounds.southwest.longitude,
            bounds.northeast.latitude,
            bounds.northeast.longitude,
          ];
    addIfNonNull('padding', _serializePadding(padding));
    addIfNonNull(
      'insetsLayoutMarginsFromSafeArea',
      insetsLayoutMarginsFromSafeArea,
    );
    return optionsMap;
  }

  Map<String, dynamic> updatesMap(_AppleMapOptions newOptions) {
    final Map<String, dynamic> prevOptionsMap = toMap();

    // `toMap()` serialises some options (e.g. `minMaxZoomPreference`,
    // `padding`) as `List<dynamic>`. Dart's default `List.==` is identity-
    // based, so two lists with identical content are considered unequal.
    // This caused the diff to always include those keys, triggering a
    // redundant native update on every widget rebuild. Using `listEquals`
    // for `List` values produces a correct element-wise comparison.
    return newOptions.toMap()..removeWhere((String key, dynamic value) {
      final prev = prevOptionsMap[key];
      if (prev is List && value is List) return listEquals(prev, value);
      return prev == value;
    });
  }

  List<double>? _serializePadding(EdgeInsets? insets) {
    if (insets == null) return null;

    return [insets.top, insets.left, insets.bottom, insets.right];
  }
}
