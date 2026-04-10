// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of apple_maps_flutter;

/// [Polyline] update events to be applied to the [AppleMap].
///
/// Used in [AppleMapController] when the map is updated.
class _PolylineUpdates {
  /// Computes [_PolylineUpdates] given previous and current [Polyline]s.
  _PolylineUpdates.from(Set<Polyline>? previous, Set<Polyline>? current) {
    if (previous == null) {
      previous = Set<Polyline>.identity();
    }

    if (current == null) {
      current = Set<Polyline>.identity();
    }

    final Map<PolylineId, Polyline> previousPolylines = _keyByPolylineId(
      previous,
    );
    final Map<PolylineId, Polyline> currentPolylines = _keyByPolylineId(
      current,
    );

    final Set<PolylineId> prevPolylineIds = previousPolylines.keys.toSet();
    final Set<PolylineId> currentPolylineIds = currentPolylines.keys.toSet();

    Polyline idToCurrentPolyline(PolylineId id) {
      return currentPolylines[id]!;
    }

    polylinesToAdd = currentPolylineIds
        .difference(prevPolylineIds)
        .map(idToCurrentPolyline)
        .toSet();
    polylineIdsToRemove = prevPolylineIds.difference(currentPolylineIds);
    polylinesToChange = currentPolylineIds
        .intersection(prevPolylineIds)
        .map(idToCurrentPolyline)
        .toSet();
  }

  late Set<Polyline> polylinesToAdd;
  late Set<PolylineId> polylineIdsToRemove;
  late Set<Polyline> polylinesToChange;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _PolylineUpdates) return false;
    final _PolylineUpdates typedOther = other;
    return setEquals(polylinesToAdd, typedOther.polylinesToAdd) &&
        setEquals(polylineIdsToRemove, typedOther.polylineIdsToRemove) &&
        setEquals(polylinesToChange, typedOther.polylinesToChange);
  }

  @override
  int get hashCode =>
      Object.hash(polylinesToAdd, polylineIdsToRemove, polylinesToChange);

  @override
  String toString() {
    return '_PolylineUpdates{polylinesToAdd: $polylinesToAdd, '
        'polylineIdsToRemove: $polylineIdsToRemove, '
        'polylinesToChange: $polylinesToChange}';
  }
}
