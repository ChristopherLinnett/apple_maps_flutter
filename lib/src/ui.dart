// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../apple_maps_flutter.dart';

/// Type of map tiles to display.
enum MapType {
  /// Normal tiles (traffic and labels, subtle terrain information).
  standard,

  /// Satellite imaging tiles (aerial photos)
  satellite,

  /// Hybrid tiles (satellite images with some labels/overlays)
  hybrid,
}

enum TrackingMode {
  // the user's location is not followed
  none,

  // the map follows the user's location
  follow,

  // the map follows the user's location and heading
  followWithHeading,
}

/// Controls the visual emphasis of the standard map style (iOS 16+).
///
/// Only applies when [AppleMap.mapType] is [MapType.standard]. Ignored on
/// satellite and hybrid map types.
enum MapEmphasisStyle {
  /// The default map appearance with full label and icon prominence.
  defaultStyle,

  /// A muted appearance that reduces the visual weight of labels and icons,
  /// useful for apps that overlay their own content on the map.
  muted,
}

/// A type of built-in map feature that the user can tap (iOS 16+).
///
/// Returned in [MapFeature.featureType] when the user taps a built-in map
/// element such as a labelled point of interest or a geographic territory.
enum MapFeatureType {
  /// A point-of-interest such as a restaurant, park, or transit station.
  pointOfInterest,

  /// A named territory such as a country, state, or city area.
  territory,

  /// A physical geographic feature such as a mountain or body of water.
  physicalFeature,
}

/// Controls which built-in map features are selectable (iOS 16+).
///
/// Used with [AppleMap.selectableFeatures] to enable tap callbacks for
/// specific categories of native map content. Defaults to
/// [MapSelectableFeature.pointsOfInterest] when not set.
enum MapSelectableFeature {
  /// Enable tapping on point-of-interest labels and icons.
  pointsOfInterest,

  /// Enable tapping on named territory labels (countries, states, cities).
  territories,

  /// Enable tapping on physical feature labels (mountains, bodies of water).
  physicalFeatures,
}

/// A built-in map feature selected by the user (iOS 16+).
///
/// Delivered via [AppleMap.onFeatureTapped] when the user taps a native
/// map element. Feature taps are separate from [Annotation] taps.
class MapFeature {
  const MapFeature({
    required this.coordinate,
    required this.featureType,
    this.title,
    this.pointOfInterestCategory,
  });

  /// The geographic coordinate of the tapped feature.
  final LatLng coordinate;

  /// The category of the tapped feature.
  final MapFeatureType featureType;

  /// The display title of the feature, if available.
  final String? title;

  /// The raw `MKPointOfInterestCategory` value for [MapFeatureType.pointOfInterest]
  /// features (e.g. `"MKPOICategoryRestaurant"`). Null for other feature types.
  final String? pointOfInterestCategory;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MapFeature) return false;
    return other.coordinate == coordinate &&
        other.featureType == featureType &&
        other.title == title &&
        other.pointOfInterestCategory == pointOfInterestCategory;
  }

  @override
  int get hashCode =>
      Object.hash(coordinate, featureType, title, pointOfInterestCategory);
}

/// Bounds for the map camera target.
// Used with [AppleMapOptions] to wrap a [LatLngBounds] value. This allows
// distinguishing between specifying an unbounded target (null `LatLngBounds`)
// from not specifying anything (null `CameraTargetBounds`).
class CameraTargetBounds {
  /// Creates a camera target bounds with the specified bounding box, or null
  /// to indicate that the camera target is not bounded.
  const CameraTargetBounds(this.bounds);

  /// The geographical bounding box for the map camera target.
  ///
  /// A null value means the camera target is unbounded.
  final LatLngBounds? bounds;

  /// Unbounded camera target.
  static const CameraTargetBounds unbounded = CameraTargetBounds(null);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CameraTargetBounds) return false;
    final CameraTargetBounds typedOther = other;
    return bounds == typedOther.bounds;
  }

  @override
  int get hashCode => bounds.hashCode;

  @override
  String toString() {
    return 'CameraTargetBounds(bounds: $bounds)';
  }
}

class MinMaxZoomPreference {
  const MinMaxZoomPreference(this.minZoom, this.maxZoom)
    : assert(minZoom == null || maxZoom == null || minZoom <= maxZoom);

  /// The preferred minimum zoom level or null, if unbounded from below.
  final double? minZoom;

  /// The preferred maximum zoom level or null, if unbounded from above.
  final double? maxZoom;

  /// Unbounded zooming.
  static const MinMaxZoomPreference unbounded = MinMaxZoomPreference(
    null,
    null,
  );

  dynamic _toJson() => <dynamic>[minZoom, maxZoom];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MinMaxZoomPreference) return false;
    final MinMaxZoomPreference typedOther = other;
    return minZoom == typedOther.minZoom && maxZoom == typedOther.maxZoom;
  }

  @override
  int get hashCode => Object.hash(minZoom, maxZoom);

  @override
  String toString() {
    return 'MinMaxZoomPreference(minZoom: $minZoom, maxZoom: $maxZoom)';
  }
}
