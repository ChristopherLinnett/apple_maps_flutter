import 'package:pigeon/pigeon.dart';

enum CameraUpdateType {
  newCameraPosition,
  newLatLng,
  newLatLngZoom,
  newLatLngBounds,
  zoomBy,
  zoomTo,
  zoomIn,
  zoomOut,
}

enum BitmapDescriptorType {
  defaultAnnotation,
  markerAnnotation,
  fromAssetImage,
  fromBytes,
}

enum CapType { buttCap, roundCap, squareCap }

enum PatternItemType { dot, dash, gap }

/// Emphasis style for the standard map configuration (iOS 16+).
enum PlatformMapEmphasisStyle {
  /// The default map appearance.
  defaultStyle,

  /// A muted appearance that de-emphasises labels and icons.
  muted,
}

/// The type of a built-in map feature tapped by the user (iOS 16+).
enum PlatformMapFeatureType { pointOfInterest, territory, physicalFeature }

class PlatformOffset {
  PlatformOffset({required this.x, required this.y});

  double x;
  double y;
}

class PlatformLatLng {
  PlatformLatLng({required this.latitude, required this.longitude});

  double latitude;
  double longitude;
}

class PlatformLatLngBounds {
  PlatformLatLngBounds({required this.southwest, required this.northeast});

  PlatformLatLng southwest;
  PlatformLatLng northeast;
}

class PlatformScreenCoordinate {
  PlatformScreenCoordinate({required this.x, required this.y});

  double x;
  double y;
}

class PlatformCameraPosition {
  PlatformCameraPosition({
    required this.target,
    required this.heading,
    required this.pitch,
    required this.zoom,
  });

  PlatformLatLng target;
  double heading;
  double pitch;
  double zoom;
}

class PlatformMinMaxZoomPreference {
  PlatformMinMaxZoomPreference({this.minZoom, this.maxZoom});

  double? minZoom;
  double? maxZoom;
}

class PlatformPadding {
  PlatformPadding({
    required this.top,
    required this.left,
    required this.bottom,
    required this.right,
  });

  double top;
  double left;
  double bottom;
  double right;
}

class PlatformCameraTargetBounds {
  PlatformCameraTargetBounds({this.bounds});

  PlatformLatLngBounds? bounds;
}

/// A built-in map feature (e.g. POI, landmark) selected by the user (iOS 16+).
class PlatformMapFeature {
  PlatformMapFeature({
    required this.coordinate,
    required this.featureType,
    this.title,
    this.pointOfInterestCategory,
  });

  PlatformLatLng coordinate;
  PlatformMapFeatureType featureType;

  /// The display title of the feature, if available.
  String? title;

  /// The raw `MKPointOfInterestCategory` string value for `.pointOfInterest`
  /// features, e.g. `"MKPOICategoryRestaurant"`. Null for other feature types.
  String? pointOfInterestCategory;
}

class PlatformMapOptions {
  PlatformMapOptions({
    this.compassEnabled,
    this.trafficEnabled,
    this.mapType,
    this.minMaxZoomPreference,
    this.rotateGesturesEnabled,
    this.scrollGesturesEnabled,
    this.pitchGesturesEnabled,
    this.trackingMode,
    this.zoomGesturesEnabled,
    this.myLocationEnabled,
    this.myLocationButtonEnabled,
    this.padding,
    this.insetsLayoutMarginsFromSafeArea,
    this.cameraTargetBounds,
    this.buildingsEnabled,
    this.pointsOfInterestEnabled,
    this.scaleEnabled,
  });

  bool? compassEnabled;
  bool? trafficEnabled;
  int? mapType;
  PlatformMinMaxZoomPreference? minMaxZoomPreference;
  bool? rotateGesturesEnabled;
  bool? scrollGesturesEnabled;
  bool? pitchGesturesEnabled;
  int? trackingMode;
  bool? zoomGesturesEnabled;
  bool? myLocationEnabled;
  bool? myLocationButtonEnabled;
  PlatformPadding? padding;
  bool? insetsLayoutMarginsFromSafeArea;
  PlatformCameraTargetBounds? cameraTargetBounds;
  bool? buildingsEnabled;
  bool? pointsOfInterestEnabled;
  bool? scaleEnabled;

  /// Emphasis style for the standard map (iOS 16+, no-op on other map types).
  PlatformMapEmphasisStyle? emphasisStyle;

  /// Bitmask of selectable built-in map features (iOS 16+).
  /// Bit 0 = pointsOfInterest, bit 1 = territories, bit 2 = physicalFeatures.
  int? selectableFeatures;
}

class PlatformInfoWindow {
  PlatformInfoWindow({
    this.title,
    this.snippet,
    this.anchor,
    required this.consumesTapEvents,
  });

  String? title;
  String? snippet;
  PlatformOffset? anchor;
  bool consumesTapEvents;
}

class PlatformBitmapDescriptor {
  PlatformBitmapDescriptor({
    required this.type,
    this.hue,
    this.assetName,
    this.assetScale,
    this.bytes,
  });

  BitmapDescriptorType type;
  double? hue;
  String? assetName;
  double? assetScale;
  Uint8List? bytes;
}

class PlatformAnnotation {
  PlatformAnnotation({
    required this.annotationId,
    required this.alpha,
    required this.anchor,
    required this.draggable,
    required this.icon,
    required this.infoWindow,
    required this.visible,
    required this.position,
    required this.zIndex,
    this.clusteringIdentifier,
  });

  String annotationId;
  double alpha;
  PlatformOffset anchor;
  bool draggable;
  PlatformBitmapDescriptor icon;
  PlatformInfoWindow infoWindow;
  bool visible;
  PlatformLatLng position;
  double zIndex;

  /// When set, annotations with the same identifier are eligible for clustering.
  /// Maps to MKAnnotationView.clusteringIdentifier on iOS 11+.
  String? clusteringIdentifier;
}

class PlatformAnnotationUpdates {
  PlatformAnnotationUpdates({
    this.annotationsToAdd,
    this.annotationsToChange,
    this.annotationIdsToRemove,
  });

  List<PlatformAnnotation>? annotationsToAdd;
  List<PlatformAnnotation>? annotationsToChange;
  List<String>? annotationIdsToRemove;
}

class PlatformPatternItem {
  PlatformPatternItem({required this.type, this.length});

  PatternItemType type;
  double? length;
}

class PlatformPolyline {
  PlatformPolyline({
    required this.polylineId,
    required this.consumeTapEvents,
    required this.color,
    required this.polylineCap,
    required this.jointType,
    required this.visible,
    required this.width,
    this.zIndex,
    required this.points,
    required this.patterns,
  });

  String polylineId;
  bool consumeTapEvents;
  int color;
  CapType polylineCap;
  int jointType;
  bool visible;
  int width;
  int? zIndex;
  List<PlatformLatLng> points;
  List<PlatformPatternItem> patterns;
}

class PlatformPolylineUpdates {
  PlatformPolylineUpdates({
    this.polylinesToAdd,
    this.polylinesToChange,
    this.polylineIdsToRemove,
  });

  List<PlatformPolyline>? polylinesToAdd;
  List<PlatformPolyline>? polylinesToChange;
  List<String>? polylineIdsToRemove;
}

class PlatformPolygon {
  PlatformPolygon({
    required this.polygonId,
    required this.consumeTapEvents,
    required this.fillColor,
    required this.points,
    required this.strokeColor,
    required this.strokeWidth,
    required this.visible,
    this.zIndex,
  });

  String polygonId;
  bool consumeTapEvents;
  int fillColor;
  List<PlatformLatLng> points;
  int strokeColor;
  int strokeWidth;
  bool visible;
  int? zIndex;
}

class PlatformPolygonUpdates {
  PlatformPolygonUpdates({
    this.polygonsToAdd,
    this.polygonsToChange,
    this.polygonIdsToRemove,
  });

  List<PlatformPolygon>? polygonsToAdd;
  List<PlatformPolygon>? polygonsToChange;
  List<String>? polygonIdsToRemove;
}

class PlatformCircle {
  PlatformCircle({
    required this.circleId,
    required this.consumeTapEvents,
    required this.fillColor,
    required this.center,
    required this.radius,
    required this.strokeColor,
    required this.strokeWidth,
    required this.visible,
    this.zIndex,
  });

  String circleId;
  bool consumeTapEvents;
  int fillColor;
  PlatformLatLng center;
  double radius;
  int strokeColor;
  int strokeWidth;
  bool visible;
  int? zIndex;
}

class PlatformCircleUpdates {
  PlatformCircleUpdates({
    this.circlesToAdd,
    this.circlesToChange,
    this.circleIdsToRemove,
  });

  List<PlatformCircle>? circlesToAdd;
  List<PlatformCircle>? circlesToChange;
  List<String>? circleIdsToRemove;
}

class PlatformSnapshotOptions {
  PlatformSnapshotOptions({
    required this.showBuildings,
    required this.showPointsOfInterest,
    required this.showAnnotations,
    required this.showOverlays,
  });

  bool showBuildings;
  bool showPointsOfInterest;
  bool showAnnotations;
  bool showOverlays;
}

class PlatformCameraUpdate {
  PlatformCameraUpdate({
    required this.type,
    this.cameraPosition,
    this.latLng,
    this.zoom,
    this.bounds,
    this.padding,
    this.focus,
  });

  CameraUpdateType type;
  PlatformCameraPosition? cameraPosition;
  PlatformLatLng? latLng;
  double? zoom;
  PlatformLatLngBounds? bounds;
  double? padding;
  PlatformOffset? focus;
}

@HostApi()
abstract class AppleMapHostApi {
  void updateMapOptions(PlatformMapOptions options);

  void updateAnnotations(PlatformAnnotationUpdates updates);

  void updatePolylines(PlatformPolylineUpdates updates);

  void updatePolygons(PlatformPolygonUpdates updates);

  void updateCircles(PlatformCircleUpdates updates);

  void animateCamera(PlatformCameraUpdate cameraUpdate);

  void moveCamera(PlatformCameraUpdate cameraUpdate);

  void showMarkerInfoWindow(String annotationId);

  void hideMarkerInfoWindow(String annotationId);

  bool? isMarkerInfoWindowShown(String annotationId);

  double? getZoomLevel();

  PlatformLatLngBounds getVisibleRegion();

  PlatformScreenCoordinate? getScreenCoordinate(PlatformLatLng latLng);

  PlatformLatLng? getLatLng(PlatformScreenCoordinate screenCoordinate);

  @async
  Uint8List? takeSnapshot(PlatformSnapshotOptions options);

  void dispose();

  // Inspector methods for integration testing.
  bool isCompassEnabled();

  PlatformMinMaxZoomPreference getMinMaxZoomLevels();

  bool isZoomGesturesEnabled();

  bool isRotateGesturesEnabled();

  bool isPitchGesturesEnabled();

  bool isScrollGesturesEnabled();

  bool isMyLocationButtonEnabled();

  bool isBuildingsEnabled();

  bool isPointsOfInterestEnabled();

  bool isScaleEnabled();

  bool isTrafficEnabled();

  PlatformCameraTargetBounds? getCameraTargetBounds();
}

/// Callbacks from the native map to Flutter.
@FlutterApi()
abstract class AppleMapFlutterApi {
  void onCameraMoveStarted();

  void onCameraMove(PlatformCameraPosition position);

  void onCameraIdle();

  void onMapTap(PlatformLatLng position);

  void onMapLongPress(PlatformLatLng position);

  void onAnnotationTap(String annotationId);

  void onAnnotationDragEnd(String annotationId, PlatformLatLng position);

  void onAnnotationZIndexChanged(String annotationId, double zIndex);

  void onInfoWindowTap(String annotationId);

  void onPolylineTap(String polylineId);

  void onPolygonTap(String polygonId);

  void onCircleTap(String circleId);

  void onPermissionDenied();

  /// Called when the user taps a built-in map feature such as a POI or
  /// landmark. Only fires on iOS 16+; ignored on earlier OS versions.
  void onMapFeatureTapped(PlatformMapFeature feature);
}
