// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../apple_maps_flutter.dart';

/// Controller for a single AppleMap instance running on the host platform.
class AppleMapController implements AppleMapFlutterApi {
  AppleMapController._(
    this.mapId,
    this._hostApi,
    this._appleMapState,
    this._binaryMessenger,
  ) {
    AppleMapFlutterApi.setUp(
      this,
      binaryMessenger: _binaryMessenger,
      messageChannelSuffix: '$mapId',
    );
  }

  static AppleMapController init(
    int id,
    CameraPosition initialCameraPosition,
    // ignore: library_private_types_in_public_api
    _AppleMapState appleMapState,
  ) {
    // initialCameraPosition is passed natively via creation params; the
    // Dart controller does not need to store it.
    return AppleMapController._(
      id,
      AppleMapHostApi(messageChannelSuffix: '$id'),
      appleMapState,
      null,
    );
  }

  @visibleForTesting
  final int mapId;

  final AppleMapHostApi _hostApi;

  final _AppleMapState _appleMapState;

  final BinaryMessenger? _binaryMessenger;

  bool _disposed = false;

  void _throwIfDisposed() {
    if (_disposed) {
      throw StateError(
        'AppleMapController methods must not be called after dispose.',
      );
    }
  }

  // ── AppleMapFlutterApi ────────────────────────────────────────────────────

  @override
  void onCameraMoveStarted() {
    _appleMapState.widget.onCameraMoveStarted?.call();
  }

  @override
  void onCameraMove(PlatformCameraPosition position) {
    _appleMapState.widget.onCameraMove?.call(
      CameraPosition(
        target: LatLng(position.target.latitude, position.target.longitude),
        heading: position.heading,
        pitch: position.pitch,
        zoom: position.zoom,
      ),
    );
  }

  @override
  void onCameraIdle() {
    _appleMapState.widget.onCameraIdle?.call();
  }

  @override
  void onMapTap(PlatformLatLng position) {
    _appleMapState.onTap(LatLng(position.latitude, position.longitude));
  }

  @override
  void onMapLongPress(PlatformLatLng position) {
    _appleMapState.onLongPress(LatLng(position.latitude, position.longitude));
  }

  @override
  void onAnnotationTap(String annotationId) {
    _appleMapState.onAnnotationTap(annotationId);
  }

  @override
  void onAnnotationDragEnd(String annotationId, PlatformLatLng position) {
    _appleMapState.onAnnotationDragEnd(
      annotationId,
      LatLng(position.latitude, position.longitude),
    );
  }

  @override
  void onAnnotationZIndexChanged(String annotationId, double zIndex) {
    _appleMapState.onAnnotationZIndexChanged(annotationId, zIndex);
  }

  @override
  void onInfoWindowTap(String annotationId) {
    _appleMapState.onInfoWindowTap(annotationId);
  }

  @override
  void onPolylineTap(String polylineId) {
    _appleMapState.onPolylineTap(polylineId);
  }

  @override
  void onPolygonTap(String polygonId) {
    _appleMapState.onPolygonTap(polygonId);
  }

  @override
  void onCircleTap(String circleId) {
    _appleMapState.onCircleTap(circleId);
  }

  @override
  void onPermissionDenied() {
    _appleMapState.onPermissionDenied();
  }

  @override
  void onMapFeatureTapped(PlatformMapFeature feature) {
    final MapFeature mapFeature = MapFeature(
      coordinate: LatLng(
        feature.coordinate.latitude,
        feature.coordinate.longitude,
      ),
      featureType: _mapFeatureType(feature.featureType),
      title: feature.title,
      pointOfInterestCategory: feature.pointOfInterestCategory,
    );
    _appleMapState.onMapFeatureTapped(mapFeature);
  }

  static MapFeatureType _mapFeatureType(PlatformMapFeatureType type) {
    switch (type) {
      case PlatformMapFeatureType.pointOfInterest:
        return MapFeatureType.pointOfInterest;
      case PlatformMapFeatureType.territory:
        return MapFeatureType.territory;
      case PlatformMapFeatureType.physicalFeature:
        return MapFeatureType.physicalFeature;
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
    _throwIfDisposed();
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
    _throwIfDisposed();
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
    _throwIfDisposed();
    return _hostApi.hideMarkerInfoWindow(annotationId.value);
  }

  /// Deselects the currently selected annotation, if any, with the native
  /// shrink animation.
  ///
  /// Has no effect when no annotation is selected.
  Future<void> deselectSelectedAnnotation() {
    _throwIfDisposed();
    return _hostApi.deselectSelectedAnnotation();
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
    _throwIfDisposed();
    return _hostApi.isMarkerInfoWindowShown(annotationId.value);
  }

  /// Changes the map camera position without animating the transition.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> moveCamera(CameraUpdate cameraUpdate) async {
    _throwIfDisposed();
    await _hostApi.moveCamera(
      _platformCameraUpdateFromCameraUpdate(cameraUpdate),
    );
  }

  /// Returns the current zoomLevel.
  Future<double?> getZoomLevel() async {
    _throwIfDisposed();
    return _hostApi.getZoomLevel();
  }

  /// Return [LatLngBounds] defining the region that is visible in a map.
  Future<LatLngBounds> getVisibleRegion() async {
    _throwIfDisposed();
    return _latLngBoundsFromPlatform(await _hostApi.getVisibleRegion());
  }

  /// A projection is used to translate between on screen location and geographic coordinates.
  /// Screen location is in screen pixels (not display pixels) with respect to the top left corner
  /// of the map, not necessarily of the whole screen.
  Future<Offset?> getScreenCoordinate(LatLng latLng) async {
    _throwIfDisposed();
    final PlatformScreenCoordinate? point = await _hostApi.getScreenCoordinate(
      _platformLatLngFromLatLng(latLng),
    );
    if (point == null) {
      return null;
    }
    return Offset(point.x, point.y);
  }

  /// Converts a screen coordinate to a geographical [LatLng].
  ///
  /// The screen coordinate is in logical pixels relative to the top-left corner
  /// of the map view. Returns `null` if the coordinate does not correspond to a
  /// valid geographical location.
  Future<LatLng?> getLatLng(Offset screenCoordinate) async {
    _throwIfDisposed();
    final PlatformLatLng? latLng = await _hostApi.getLatLng(
      PlatformScreenCoordinate(x: screenCoordinate.dx, y: screenCoordinate.dy),
    );
    if (latLng == null) {
      return null;
    }
    return LatLng(latLng.latitude, latLng.longitude);
  }

  /// Returns the image bytes of the map
  Future<Uint8List?> takeSnapshot([
    SnapshotOptions snapshotOptions = const SnapshotOptions(),
  ]) {
    _throwIfDisposed();
    return _hostApi.takeSnapshot(
      _platformSnapshotOptionsFromSnapshotOptions(snapshotOptions),
    );
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    AppleMapFlutterApi.setUp(
      null,
      binaryMessenger: _binaryMessenger,
      messageChannelSuffix: '$mapId',
    );
    try {
      await _hostApi.dispose();
    } on PlatformException {
      // The native platform view may already have been torn down.
    }
  }
}
