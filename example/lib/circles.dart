import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'color_swatch.dart' as cs;
import 'page.dart';

const _kInitial = CameraPosition(target: LatLng(51.507, -0.127), zoom: 11);
const _kCircleCenter = LatLng(51.507, -0.127);

class CirclesPage extends ExamplePage {
  const CirclesPage({super.key})
    : super(const Icon(Icons.radio_button_unchecked), 'Circles');

  @override
  Widget build(BuildContext context) => const _CirclesBody();
}

class _CirclesBody extends StatefulWidget {
  const _CirclesBody();

  @override
  State<_CirclesBody> createState() => _CirclesBodyState();
}

class _CirclesBodyState extends State<_CirclesBody> {
  double _radius = 5000;
  Color _fillColor = Colors.teal;
  double _fillAlpha = 0.3;
  Color _strokeColor = Colors.teal;
  double _strokeWidth = 2;
  bool _visible = true;
  String? _lastTapId;

  @override
  Widget build(BuildContext context) {
    final circle = Circle(
      circleId: const CircleId('demo'),
      center: _kCircleCenter,
      radius: _radius,
      fillColor: _fillColor.withValues(alpha: _fillAlpha),
      strokeColor: _strokeColor,
      strokeWidth: _strokeWidth.toInt(),
      visible: _visible,
      consumeTapEvents: true,
      onTap: () => setState(() => _lastTapId = 'demo'),
    );

    return MapScaffold(
      title: 'Circles',
      mapBuilder: (mapPadding) => AppleMap(
        initialCameraPosition: _kInitial,
        circles: {circle},
        padding: mapPadding,
      ),
      controls: [
        const _SectionHeader('Radius'),
        ListTile(
          title: Text('${(_radius / 1000).toStringAsFixed(1)} km'),
          subtitle: Slider(
            value: _radius,
            min: 500,
            max: 50000,
            divisions: 99,
            onChanged: (v) => setState(() => _radius = v),
          ),
        ),
        const _SectionHeader('Fill'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: cs.ColorSwatch(
            selected: _fillColor,
            onChanged: (c) => setState(() => _fillColor = c),
          ),
        ),
        ListTile(
          title: Text('Alpha: ${(_fillAlpha * 100).toStringAsFixed(0)}%'),
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
