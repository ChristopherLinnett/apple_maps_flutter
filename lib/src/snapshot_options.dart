part of '../apple_maps_flutter.dart';

class SnapshotOptions {
  const SnapshotOptions({
    this.showBuildings = true,
    this.showPointsOfInterest = true,
    this.showAnnotations = true,
    this.showOverlays = true,
  });

  final bool showBuildings;
  final bool showPointsOfInterest;
  final bool showAnnotations;
  final bool showOverlays;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SnapshotOptions) return false;
    final SnapshotOptions typedOther = other;
    return showBuildings == typedOther.showBuildings &&
        showPointsOfInterest == typedOther.showPointsOfInterest &&
        showAnnotations == typedOther.showAnnotations &&
        showOverlays == typedOther.showOverlays;
  }

  @override
  int get hashCode => Object.hash(
    showBuildings,
    showPointsOfInterest,
    showAnnotations,
    showOverlays,
  );

  @override
  String toString() =>
      'SnapshotOptions(showBuildings: $showBuildings, showPointsOfInterest: $showPointsOfInterest, showAnnotations: $showAnnotations, showOverlays: $showOverlays)';
}
