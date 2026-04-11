import 'dart:typed_data';

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'page.dart';

const _kInitial = CameraPosition(target: LatLng(-33.852, 151.211), zoom: 11);
const _kAnnotationId = AnnotationId('snapshot_annotation');
const _kCircleId = CircleId('snapshot_circle');

class SnapshotsPage extends ExamplePage {
  const SnapshotsPage({super.key})
    : super(const Icon(Icons.camera_alt), 'Snapshots');

  @override
  Widget build(BuildContext context) => const _SnapshotsBody();
}

class _SnapshotsBody extends StatefulWidget {
  const _SnapshotsBody();

  @override
  State<_SnapshotsBody> createState() => _SnapshotsBodyState();
}

class _SnapshotsBodyState extends State<_SnapshotsBody> {
  AppleMapController? _controller;
  Uint8List? _imageBytes;
  bool _busy = false;

  bool _showBuildings = true;
  bool _showPointsOfInterest = true;
  bool _showAnnotations = true;
  bool _showOverlays = true;

  SnapshotOptions get _snapshotOptions => SnapshotOptions(
    showBuildings: _showBuildings,
    showPointsOfInterest: _showPointsOfInterest,
    showAnnotations: _showAnnotations,
    showOverlays: _showOverlays,
  );

  Future<void> _takeSnapshot() async {
    if (_controller == null) return;
    setState(() => _busy = true);
    try {
      final bytes = await _controller!.takeSnapshot(_snapshotOptions);
      if (mounted) setState(() => _imageBytes = bytes);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final annotation = Annotation(
      annotationId: _kAnnotationId,
      position: const LatLng(-33.83, 151.18),
      infoWindow: const InfoWindow(title: 'Snapshot annotation'),
    );

    final circle = Circle(
      circleId: _kCircleId,
      center: const LatLng(-33.87, 151.23),
      radius: 3000,
      fillColor: Colors.blue.withValues(alpha: 0.3),
      strokeColor: Colors.blue,
      strokeWidth: 2,
    );

    final map = AppleMap(
      initialCameraPosition: _kInitial,
      onMapCreated: (c) => setState(() => _controller = c),
      annotations: _showAnnotations ? {annotation} : {},
      circles: _showOverlays ? {circle} : {},
    );

    return MapScaffold(
      title: 'Snapshots',
      map: map,
      initialSheetSize: 0.40,
      controls: [
        const _SectionHeader('Snapshot Options'),
        SwitchListTile(
          title: const Text('Show buildings'),
          value: _showBuildings,
          onChanged: (v) => setState(() => _showBuildings = v),
        ),
        SwitchListTile(
          title: const Text('Show points of interest'),
          value: _showPointsOfInterest,
          onChanged: (v) => setState(() => _showPointsOfInterest = v),
        ),
        SwitchListTile(
          title: const Text('Include annotation'),
          subtitle: const Text('Places a pin annotation on the map first'),
          value: _showAnnotations,
          onChanged: (v) => setState(() => _showAnnotations = v),
        ),
        SwitchListTile(
          title: const Text('Include circle overlay'),
          value: _showOverlays,
          onChanged: (v) => setState(() => _showOverlays = v),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: FilledButton.icon(
            onPressed: _busy ? null : _takeSnapshot,
            icon: const Icon(Icons.camera_alt),
            label: Text(_busy ? 'Taking snapshot…' : 'Take snapshot'),
          ),
        ),
        if (_imageBytes != null) ...[
          const _SectionHeader('Result'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(_imageBytes!, fit: BoxFit.cover),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
