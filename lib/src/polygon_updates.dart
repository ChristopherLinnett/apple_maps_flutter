// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../apple_maps_flutter.dart';

/// [Polygon] update events to be applied to the [AppleMap].
///
/// Used in [AppleMapController] when the map is updated.
class _PolygonUpdates {
  /// Computes [_PolygonUpdates] given previous and current [Polygon]s.
  _PolygonUpdates.from(Set<Polygon>? previous, Set<Polygon>? current) {
    previous ??= Set<Polygon>.identity();

    current ??= Set<Polygon>.identity();

    final Map<PolygonId, Polygon> previousPolygons = _keyByPolygonId(previous);
    final Map<PolygonId, Polygon> currentPolygons = _keyByPolygonId(current);

    final Set<PolygonId> prevPolygonIds = previousPolygons.keys.toSet();
    final Set<PolygonId> currentPolygonIds = currentPolygons.keys.toSet();

    Polygon idToCurrentPolygon(PolygonId id) {
      return currentPolygons[id]!;
    }

    polygonIdsToRemove = prevPolygonIds.difference(currentPolygonIds);

    polygonsToAdd = currentPolygonIds
        .difference(prevPolygonIds)
        .map(idToCurrentPolygon)
        .toSet();

    /// Returns `true` if [current] is not equals to previous one with the
    /// same id.
    bool hasChanged(Polygon current) {
      final Polygon? previous = previousPolygons[current.polygonId];
      return current != previous;
    }

    polygonsToChange = currentPolygonIds
        .intersection(prevPolygonIds)
        .map(idToCurrentPolygon)
        .where(hasChanged)
        .toSet();
  }

  late Set<Polygon> polygonsToAdd;
  late Set<PolygonId> polygonIdsToRemove;
  late Set<Polygon> polygonsToChange;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _PolygonUpdates) return false;
    final _PolygonUpdates typedOther = other;
    return setEquals(polygonsToAdd, typedOther.polygonsToAdd) &&
        setEquals(polygonIdsToRemove, typedOther.polygonIdsToRemove) &&
        setEquals(polygonsToChange, typedOther.polygonsToChange);
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(polygonsToAdd),
    Object.hashAllUnordered(polygonIdsToRemove),
    Object.hashAllUnordered(polygonsToChange),
  );

  @override
  String toString() {
    return '_PolygonUpdates{polygonsToAdd: $polygonsToAdd, '
        'polygonIdsToRemove: $polygonIdsToRemove, '
        'polygonsToChange: $polygonsToChange}';
  }
}
