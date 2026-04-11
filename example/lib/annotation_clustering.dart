import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'page.dart';

// 5×6 grid of annotations within a ~0.04° bounding box
const _kCenter = LatLng(51.507, -0.127);

List<Annotation> _buildGrid({required bool clustering}) {
  final annotations = <Annotation>[];
  for (var row = 0; row < 5; row++) {
    for (var col = 0; col < 6; col++) {
      final id = AnnotationId('cluster_${row}_$col');
      annotations.add(
        Annotation(
          annotationId: id,
          position: LatLng(
            _kCenter.latitude + (row - 2) * 0.005,
            _kCenter.longitude + (col - 2.5) * 0.005,
          ),
          clusteringIdentifier: clustering ? 'demo-cluster' : null,
          infoWindow: InfoWindow(title: 'R$row C$col'),
        ),
      );
    }
  }
  return annotations;
}

class AnnotationClusteringPage extends ExamplePage {
  const AnnotationClusteringPage({super.key})
    : super(const Icon(Icons.bubble_chart), 'Annotation Clustering');

  @override
  Widget build(BuildContext context) => const _AnnotationClusteringBody();
}

class _AnnotationClusteringBody extends StatefulWidget {
  const _AnnotationClusteringBody();

  @override
  State<_AnnotationClusteringBody> createState() =>
      _AnnotationClusteringBodyState();
}

class _AnnotationClusteringBodyState extends State<_AnnotationClusteringBody> {
  bool _clusteringEnabled = false;

  @override
  Widget build(BuildContext context) {
    final annotations = _buildGrid(clustering: _clusteringEnabled);
    final map = AppleMap(
      initialCameraPosition: const CameraPosition(target: _kCenter, zoom: 13),
      annotations: annotations.toSet(),
    );

    return MapScaffold(
      title: 'Annotation Clustering',
      map: map,
      controls: [
        SwitchListTile(
          title: const Text('Enable clustering'),
          subtitle: Text(
            _clusteringEnabled
                ? 'Zoom out to see the cluster collapse; zoom in to expand it'
                : '30 individual annotations — no clustering identifier set',
          ),
          value: _clusteringEnabled,
          onChanged: (v) => setState(() => _clusteringEnabled = v),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            '30 annotations are placed in a 5×6 grid within a ~0.04° '
            'bounding box. Toggle clustering to see MapKit merge them.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
