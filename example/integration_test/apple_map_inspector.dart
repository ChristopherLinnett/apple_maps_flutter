// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:apple_maps_flutter/src/messages.g.dart';

/// Inspect Apple Maps state using the platform SDK.
///
/// This class is primarily used for testing. The methods on this
/// class should call "getters" on the AppleMap object or equivalent
/// on the platform side.
class AppleMapInspector {
  AppleMapInspector(int mapId)
      : _hostApi = AppleMapHostApi(messageChannelSuffix: '$mapId');

  final AppleMapHostApi _hostApi;

  Future<bool> isCompassEnabled() async {
    return _hostApi.isCompassEnabled();
  }

  Future<MinMaxZoomPreference> getMinMaxZoomLevels() async {
    final PlatformMinMaxZoomPreference result =
        await _hostApi.getMinMaxZoomLevels();
    return MinMaxZoomPreference(result.minZoom, result.maxZoom);
  }

  Future<bool> isZoomGesturesEnabled() async {
    return _hostApi.isZoomGesturesEnabled();
  }

  Future<bool> isRotateGesturesEnabled() async {
    return _hostApi.isRotateGesturesEnabled();
  }

  Future<bool> isPitchGesturesEnabled() async {
    return _hostApi.isPitchGesturesEnabled();
  }

  Future<bool> isScrollGesturesEnabled() async {
    return _hostApi.isScrollGesturesEnabled();
  }

  Future<bool> isMyLocationButtonEnabled() async {
    return _hostApi.isMyLocationButtonEnabled();
  }

  Future<bool> isBuildingsEnabled() async {
    return _hostApi.isBuildingsEnabled();
  }

  Future<bool> isPointsOfInterestEnabled() async {
    return _hostApi.isPointsOfInterestEnabled();
  }

  Future<bool> isScaleEnabled() async {
    return _hostApi.isScaleEnabled();
  }
}
