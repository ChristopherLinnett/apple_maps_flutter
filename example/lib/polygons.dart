import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'color_swatch.dart' as cs;
import 'page.dart';

const _kInitial = CameraPosition(target: LatLng(51.507, -0.127), zoom: 13);

const _kOuterRing = [
  LatLng(51.524, -0.155),
  LatLng(51.524, -0.095),
  LatLng(51.490, -0.095),
  LatLng(51.490, -0.155),
];

class PolygonsPage extends ExamplePage {
  const PolygonsPage({super.key})
    : super(const Icon(Icons.crop_square), 'Polygons');

  @override
  Widget build(BuildContext context) => const _PolygonsBody();
}

class _PolygonsBody extends StatefulWidget {
  const _PolygonsBody();

  @override
  State<_PolygonsBody> createState() => _PolygonsBodyState();
}

class _PolygonsBodyState extends State<_PolygonsBody> {
  Color _fillColor = Colors.blue;
  double _fillAlpha = 0.4;
  Color _strokeColor = Colors.indigo;
  double _strokeWidth = 2;
  bool _visible = true;
  String? _lastTapId;

  @override
  Widget build(BuildContext context) {
    final polygon = Polygon(
      polygonId: const PolygonId('demo'),
      points: _kOuterRing,
      fillColor: _fillColor.withValues(alpha: _fillAlpha),
      strokeColor: _strokeColor,
      strokeWidth: _strokeWidth.toInt(),
      visible: _visible,
      consumeTapEvents: true,
      onTap: () => setState(() => _lastTapId = 'demo'),
    );

    final map = AppleMap(initialCameraPosition: _kInitial, polygons: {polygon});

    return MapScaffold(
      title: 'Polygons',
      map: map,
      controls: [
        const _SectionHeader('Fill'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: cs.ColorSwatch(
            selected: _fillColor,
            onChanged: (c) => setState(() => _fillColor = c),
          ),
        ),
        ListTile(
          title: Text('Fill alpha: ${(_fillAlpha * 100).toStringAsFixed(0)}%'),
          subtitle: Slider(
            value: _fillAlpha,
            divisions: 10,
            onChanged: (v) => setState(() => _fillAlpha = v),
          ),
        ),
        const _SectionHeader('Stroke'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: cs.ColorSwatch(
            selected: _strokeColor,
            onChanged: (c) => setState(() => _strokeColor = c),
          ),
        ),
        ListTile(
          title: Text('Width: ${_strokeWidth.toStringAsFixed(0)} pt'),
          subtitle: Slider(
            value: _strokeWidth,
            min: 1,
            max: 16,
            divisions: 15,
            onChanged: (v) => setState(() => _strokeWidth = v),
          ),
        ),
        const _SectionHeader('Options'),
        SwitchListTile(
          title: const Text('Visible'),
          value: _visible,
          onChanged: (v) => setState(() => _visible = v),
        ),
        if (_lastTapId != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text(
              'Tapped: $_lastTapId',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
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
