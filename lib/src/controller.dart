// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of apple_maps_flutter;

/// Controller for a single AppleMap instance running on the host platform.
class AppleMapController {
  AppleMapController._(
    this.channel,
    this._hostApi,
    CameraPosition initialCameraPosition,
    this._appleMapState,
  ) {
    channel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<AppleMapController> init(
    int id,
    CameraPosition initialCameraPosition,
    _AppleMapState appleMapState,
  ) async {
    final MethodChannel channel = MethodChannel(
      'apple_maps_plugin.luisthein.de/apple_maps_$id',
    );
    return AppleMapController._(
      channel,
      AppleMapHostApi(messageChannelSuffix: '$id'),
      initialCameraPosition,
      appleMapState,
    );
  }

  @visibleForTesting
  final MethodChannel channel;

  final AppleMapHostApi _hostApi;

  final _AppleMapState _appleMapState;

  bool _disposed = false;

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'camera#onMoveStarted':
        _appleMapState.widget.onCameraMoveStarted?.call();
        break;
      case 'camera#onMove':
        _appleMapState.widget.onCameraMove?.call(
          CameraPosition.fromMap(call.arguments['position'])!,
        );
        break;
      case 'camera#onIdle':
        _appleMapState.widget.onCameraIdle?.call();
        break;
      case 'annotation#onTap':
        _appleMapState.onAnnotationTap(call.arguments['annotationId']);
        break;
      case 'polyline#onTap':
        _appleMapState.onPolylineTap(call.arguments['polylineId']);
        break;
      case 'polygon#onTap':
        _appleMapState.onPolygonTap(call.arguments['polygonId']);
        break;
      case 'circle#onTap':
        _appleMapState.onCircleTap(call.arguments['circleId']);
        break;
      case 'annotation#onDragEnd':
        _appleMapState.onAnnotationDragEnd(
          call.arguments['annotationId'],
          LatLng._fromJson(call.arguments['position'])!,
        );
        break;
      case 'infoWindow#onTap':
        _appleMapState.onInfoWindowTap(call.arguments['annotationId']);
        break;
      case 'annotation#onZIndexChanged':
        _appleMapState.onAnnotationZIndexChanged(
          call.arguments['annotationId'],
          call.arguments['zIndex'],
        );
        break;
      case 'map#onTap':
        _appleMapState.onTap(LatLng._fromJson(call.arguments['position'])!);
        break;
      case 'map#onLongPress':
        _appleMapState.onLongPress(
          LatLng._fromJson(call.arguments['position'])!,
        );
        break;
      default:
        throw MissingPluginException();
    }
  }

  /// Updates configuration options of the map user interface.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateMapOptions(Map<String, dynamic> optionsUpdate) async {
    await _hostApi.updateMapOptions(_platformMapOptionsFromMap(optionsUpdate));
  }

  /// Updates annotation configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateAnnotations(_AnnotationUpdates annotationUpdates) async {
    await _hostApi.updateAnnotations(
      _platformAnnotationUpdatesFromAnnotationUpdates(annotationUpdates),
    );
  }

  /// Updates polyline configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updatePolylines(_PolylineUpdates polylineUpdates) async {
    await _hostApi.updatePolylines(
      _platformPolylineUpdatesFromPolylineUpdates(polylineUpdates),
    );
  }

  /// Updates polygon configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updatePolygons(_PolygonUpdates polygonUpdates) async {
    await _hostApi.updatePolygons(
      _platformPolygonUpdatesFromPolygonUpdates(polygonUpdates),
    );
  }

  /// Updates circle configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateCircles(_CircleUpdates circleUpdates) async {
    await _hostApi.updateCircles(
      _platformCircleUpdatesFromCircleUpdates(circleUpdates),
    );
  }

  /// Starts an animated change of the map camera position.
  ///
  /// The returned [Future] completes after the change has been started on the
  /// platform side.
  Future<void> animateCamera(CameraUpdate cameraUpdate) async {
    await _hostApi.animateCamera(
      _platformCameraUpdateFromCameraUpdate(cameraUpdate),
    );
  }

  /// Programmatically show the Info Window for a [Marker].
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [hideMarkerInfoWindow] to hide the Info Window.
  ///   * [isMarkerInfoWindowShown] to check if the Info Window is showing.
  Future<void> showMarkerInfoWindow(AnnotationId annotationId) {
    return _hostApi.showMarkerInfoWindow(annotationId.value);
  }

  /// Programmatically hide the Info Window for a [Marker].
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [showMarkerInfoWindow] to show the Info Window.
  ///   * [isMarkerInfoWindowShown] to check if the Info Window is showing.
  Future<void> hideMarkerInfoWindow(AnnotationId annotationId) {
    return _hostApi.hideMarkerInfoWindow(annotationId.value);
  }

  /// Returns `true` when the [InfoWindow] is showing, `false` otherwise.
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [showMarkerInfoWindow] to show the Info Window.
  ///   * [hideMarkerInfoWindow] to hide the Info Window.
  Future<bool?> isMarkerInfoWindowShown(AnnotationId annotationId) {
    return _hostApi.isMarkerInfoWindowShown(annotationId.value);
  }

  /// Changes the map camera position without animating the transition.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> moveCamera(CameraUpdate cameraUpdate) async {
    await _hostApi.moveCamera(
      _platformCameraUpdateFromCameraUpdate(cameraUpdate),
    );
  }

  /// Returns the current zoomLevel.
  Future<double?> getZoomLevel() async {
    return _hostApi.getZoomLevel();
  }

  /// Return [LatLngBounds] defining the region that is visible in a map.
  Future<LatLngBounds> getVisibleRegion() async {
    return _latLngBoundsFromPlatform(await _hostApi.getVisibleRegion());
  }

  /// A projection is used to translate between on screen location and geographic coordinates.
  /// Screen location is in screen pixels (not display pixels) with respect to the top left corner
  /// of the map, not necessarily of the whole screen.
  Future<Offset?> getScreenCoordinate(LatLng latLng) async {
    final PlatformScreenCoordinate? point = await _hostApi.getScreenCoordinate(
      _platformLatLngFromLatLng(latLng),
    );
    if (point == null) {
      return null;
    }
    return Offset(point.x, point.y);
  }

  /// Returns the image bytes of the map
  Future<Uint8List?> takeSnapshot([
    SnapshotOptions snapshotOptions = const SnapshotOptions(),
  ]) {
    return _hostApi.takeSnapshot(
      _platformSnapshotOptionsFromSnapshotOptions(snapshotOptions),
    );
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    channel.setMethodCallHandler(null);
    try {
      await _hostApi.dispose();
    } on PlatformException {
      // The native platform view may already have been torn down.
    }
  }
}
