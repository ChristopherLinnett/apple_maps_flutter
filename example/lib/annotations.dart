import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'event_log.dart';
import 'page.dart';

const _kInitial = CameraPosition(target: LatLng(51.507, -0.127), zoom: 13);

class AnnotationsPage extends ExamplePage {
  const AnnotationsPage({super.key})
    : super(const Icon(Icons.place), 'Annotations');

  @override
  Widget build(BuildContext context) => const _AnnotationsBody();
}

class _AnnotationsBody extends StatefulWidget {
  const _AnnotationsBody();

  @override
  State<_AnnotationsBody> createState() => _AnnotationsBodyState();
}

class _AnnotationsBodyState extends State<_AnnotationsBody> {
  final _logKey = GlobalKey<EventLogState>();
  AppleMapController? _controller;
  final Map<AnnotationId, Annotation> _annotations = {};
  int _nextId = 0;
  AnnotationId? _selectedId;
  double _selectedAlpha = 1.0;
  bool _selectedVisible = true;

  Annotation? get _selected =>
      _selectedId != null ? _annotations[_selectedId] : null;

  void _onMapCreated(AppleMapController c) => setState(() => _controller = c);

  void _onAnnotationTap(AnnotationId id) {
    setState(() {
      _selectedId = id;
      _selectedAlpha = _annotations[id]?.alpha ?? 1.0;
      _selectedVisible = _annotations[id]?.visible ?? true;
    });
    _logKey.currentState?.add('Tapped: ${id.value}');
  }

  void _onDragEnd(AnnotationId id, LatLng pos) {
    _logKey.currentState?.add(
      'Drag ended: ${id.value} → ${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
    );
  }

  AnnotationId _newId() => AnnotationId('annotation_${_nextId++}');

  void _addAnnotation(Annotation a) {
    setState(() => _annotations[a.annotationId] = a);
  }

  void _updateSelected(Annotation Function(Annotation) update) {
    final id = _selectedId;
    if (id == null || !_annotations.containsKey(id)) return;
    setState(() => _annotations[id] = update(_annotations[id]!));
  }

  Future<void> _addDefault() async {
    final id = _newId();
    _addAnnotation(
      Annotation(
        annotationId: id,
        position: const LatLng(51.507, -0.127),
        icon: BitmapDescriptor.defaultAnnotation,
        infoWindow: const InfoWindow(
          title: 'Default pin',
          snippet: 'Tap to show callout',
        ),
        onTap: () => _onAnnotationTap(id),
      ),
    );
  }

  Future<void> _addMarker() async {
    final id = _newId();
    _addAnnotation(
      Annotation(
        annotationId: id,
        position: const LatLng(51.512, -0.115),
        icon: BitmapDescriptor.markerAnnotation,
        infoWindow: const InfoWindow(title: 'Marker style'),
        onTap: () => _onAnnotationTap(id),
      ),
    );
  }

  Future<void> _addHuePin() async {
    final id = _newId();
    _addAnnotation(
      Annotation(
        annotationId: id,
        position: const LatLng(51.502, -0.140),
        icon: BitmapDescriptor.defaultAnnotationWithHue(
          BitmapDescriptor.hueGreen,
        ),
        infoWindow: const InfoWindow(title: 'Hue pin (green)'),
        onTap: () => _onAnnotationTap(id),
      ),
    );
  }

  Future<void> _addHueMarker() async {
    final id = _newId();
    _addAnnotation(
      Annotation(
        annotationId: id,
        position: const LatLng(51.505, -0.105),
        icon: BitmapDescriptor.markerAnnotationWithHue(
          BitmapDescriptor.hueAzure,
        ),
        infoWindow: const InfoWindow(title: 'Hue marker (azure)'),
        onTap: () => _onAnnotationTap(id),
      ),
    );
  }

  Future<void> _addFromAsset() async {
    final config = ImageConfiguration(
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
    );
    final icon = await BitmapDescriptor.fromAssetImage(
      config,
      'assets/red_square.png',
    );
    if (!mounted) return;
    final id = _newId();
    _addAnnotation(
      Annotation(
        annotationId: id,
        position: const LatLng(51.516, -0.130),
        icon: icon,
        infoWindow: const InfoWindow(title: 'From asset (red_square)'),
        onTap: () => _onAnnotationTap(id),
      ),
    );
  }

  Future<void> _addFromBytes() async {
    final bytes = await _createColoredCircleBytes(Colors.deepPurple, 80);
    if (!mounted) return;
    final id = _newId();
    _addAnnotation(
      Annotation(
        annotationId: id,
        position: const LatLng(51.498, -0.118),
        icon: BitmapDescriptor.fromBytes(bytes),
        infoWindow: const InfoWindow(title: 'From bytes (purple circle)'),
        onTap: () => _onAnnotationTap(id),
      ),
    );
  }

  Future<void> _addDraggable() async {
    final id = _newId();
    _addAnnotation(
      Annotation(
        annotationId: id,
        position: const LatLng(51.510, -0.145),
        icon: BitmapDescriptor.defaultAnnotationWithHue(
          BitmapDescriptor.hueOrange,
        ),
        draggable: true,
        infoWindow: const InfoWindow(
          title: 'Draggable',
          snippet: 'Hold and drag me',
        ),
        onTap: () => _onAnnotationTap(id),
        onDragEnd: (pos) => _onDragEnd(id, pos),
      ),
    );
  }


  Future<Uint8List> _createColoredCircleBytes(Color color, int size) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);
    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final map = AppleMap(
      initialCameraPosition: _kInitial,
      onMapCreated: _onMapCreated,
      annotations: _annotations.values.toSet(),
    );

    return MapScaffold(
      title: 'Annotations',
      map: map,
      initialSheetSize: 0.35,
      controls: [
        const _SectionHeader('Add Annotation'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: _addDefault,
                child: const Text('Default pin'),
              ),
              FilledButton.tonal(
                onPressed: _addMarker,
                child: const Text('Marker'),
              ),
              FilledButton.tonal(
                onPressed: _addHuePin,
                child: const Text('Hue pin'),
              ),
              FilledButton.tonal(
                onPressed: _addHueMarker,
                child: const Text('Hue marker'),
              ),
              FilledButton.tonal(
                onPressed: _addFromAsset,
                child: const Text('From asset'),
              ),
              FilledButton.tonal(
                onPressed: _addFromBytes,
                child: const Text('From bytes'),
              ),
              FilledButton.tonal(
                onPressed: _addDraggable,
                child: const Text('Draggable'),
              ),
            ],
          ),
        ),
        if (_selected != null) ...[
          const _SectionHeader('Selected Annotation'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'ID: ${_selectedId!.value}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          ListTile(
            title: const Text('Alpha'),
            subtitle: Slider(
              value: _selectedAlpha,
              min: 0,
              max: 1,
              divisions: 10,
              label: _selectedAlpha.toStringAsFixed(1),
              onChanged: (v) {
                setState(() => _selectedAlpha = v);
                _updateSelected((a) => a.copyWith(alphaParam: v));
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Visible'),
            value: _selectedVisible,
            onChanged: (v) {
              setState(() => _selectedVisible = v);
              _updateSelected((a) => a.copyWith(visibleParam: v));
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                FilledButton.tonal(
                  onPressed: () {
                    if (_selectedId != null) {
                      _controller?.showMarkerInfoWindow(_selectedId!);
                    }
                  },
                  child: const Text('Show callout'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () {
                    if (_selectedId != null) {
                      _controller?.hideMarkerInfoWindow(_selectedId!);
                    }
                  },
                  child: const Text('Hide callout'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    final id = _selectedId;
                    if (id != null) {
                      setState(() {
                        _annotations.remove(id);
                        _selectedId = null;
                      });
                    }
                  },
                  child: const Text('Remove'),
                ),
              ],
            ),
          ),
        ],
        const _SectionHeader('Manage All'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: _annotations.isEmpty
                    ? null
                    : () => setState(() {
                        _annotations.clear();
                        _selectedId = null;
                      }),
                child: const Text('Clear all'),
              ),
              const SizedBox(width: 8),
              Text(
                '${_annotations.length} annotation(s)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const _SectionHeader('Event Log'),
        EventLog(key: _logKey, height: 100),
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
