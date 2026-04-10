// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of apple_maps_flutter;

/// [Annotation] update events to be applied to the [AppleMap].
///
/// Used in [AppleMapController] when the map is updated.
class _AnnotationUpdates {
  /// Computes [_AnnotationUpdates] given previous and current [Annotation]s.
  _AnnotationUpdates.from(Set<Annotation>? previous, Set<Annotation>? current) {
    if (previous == null) {
      previous = Set<Annotation>.identity();
    }

    if (current == null) {
      current = Set<Annotation>.identity();
    }

    final Map<AnnotationId, Annotation> previousAnnotations =
        _keyByAnnotationId(previous);
    final Map<AnnotationId, Annotation> currentAnnotations = _keyByAnnotationId(
      current,
    );

    final Set<AnnotationId> prevAnnotationIds = previousAnnotations.keys
        .toSet();
    final Set<AnnotationId> currentAnnotationIds = currentAnnotations.keys
        .toSet();

    Annotation idToCurrentAnnotation(AnnotationId id) {
      return currentAnnotations[id]!;
    }

    annotationsToAdd = currentAnnotationIds
        .difference(prevAnnotationIds)
        .map(idToCurrentAnnotation)
        .toSet();
    annotationIdsToRemove = prevAnnotationIds.difference(currentAnnotationIds);
    // Only include annotations whose model state has actually changed.
    // Callbacks (onTap, onDragEnd) are excluded from Annotation.== so they
    // cannot be compared; this reduces unnecessary channel traffic when the
    // widget rebuilds with the same annotation set.
    annotationsToChange = currentAnnotationIds
        .intersection(prevAnnotationIds)
        .where((AnnotationId id) => previousAnnotations[id] != currentAnnotations[id])
        .map(idToCurrentAnnotation)
        .toSet();
  }

  late Set<Annotation> annotationsToAdd;
  late Set<AnnotationId> annotationIdsToRemove;
  late Set<Annotation> annotationsToChange;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _AnnotationUpdates) return false;
    final _AnnotationUpdates typedOther = other;
    return setEquals(annotationsToAdd, typedOther.annotationsToAdd) &&
        setEquals(annotationIdsToRemove, typedOther.annotationIdsToRemove) &&
        setEquals(annotationsToChange, typedOther.annotationsToChange);
  }

  @override
  int get hashCode =>
      Object.hash(annotationsToAdd, annotationIdsToRemove, annotationsToChange);

  @override
  String toString() {
    return '_AnnotationUpdates{annotationsToAdd: $annotationsToAdd, '
        'annotationIdsToRemove: $annotationIdsToRemove, '
        'annotationsToChange: $annotationsToChange}';
  }
}
