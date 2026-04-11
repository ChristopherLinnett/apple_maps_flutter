import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'color_swatch.dart' as cs;
import 'page.dart';

const _kInitial = CameraPosition(target: LatLng(51.507, -0.127), zoom: 13);

const _kPoints = [
  LatLng(51.521, -0.151),
  LatLng(51.512, -0.133),
  LatLng(51.502, -0.114),
  LatLng(51.509, -0.093),
  LatLng(51.522, -0.080),
];

class PolylinesPage extends ExamplePage {
  const PolylinesPage({super.key})
    : super(const Icon(Icons.timeline), 'Polylines');

  @override
  Widget build(BuildContext context) => const _PolylinesBody();
}

class _PolylinesBody extends StatefulWidget {
  const _PolylinesBody();

  @override
  State<_PolylinesBody> createState() => _PolylinesBodyState();
}

class _PolylinesBodyState extends State<_PolylinesBody> {
  int _width = 4;
  double _alpha = 1.0;
  Color _color = Colors.blue;
  Cap _cap = Cap.roundCap;
  JointType _jointType = JointType.round;
  bool _dashed = false;
  bool _visible = true;
  String? _lastTapId;

  Color get _effectiveColor => _color.withValues(alpha: _alpha);

  List<PatternItem> get _pattern =>
      _dashed ? [PatternItem.dash(20), PatternItem.gap(10)] : [];

  @override
  Widget build(BuildContext context) {
    final polyline = Polyline(
      polylineId: const PolylineId('demo'),
      points: _kPoints,
      width: _width,
      color: _effectiveColor,
      polylineCap: _cap,
      jointType: _jointType,
      patterns: _pattern,
      visible: _visible,
      consumeTapEvents: true,
      onTap: () => setState(() => _lastTapId = 'demo'),
    );

    final map = AppleMap(
      initialCameraPosition: _kInitial,
      polylines: {polyline},
    );

    return MapScaffold(
      title: 'Polylines',
      map: map,
      controls: [
        const _SectionHeader('Stroke'),
        ListTile(
          title: Text('Width: $_width pt'),
          subtitle: Slider(
            value: _width.toDouble(),
            min: 1,
            max: 20,
            divisions: 19,
            onChanged: (v) => setState(() => _width = v.toInt()),
          ),
        ),
        ListTile(
          title: Text('Alpha: ${(_alpha * 100).toStringAsFixed(0)}%'),
          subtitle: Slider(
            value: _alpha,
            divisions: 10,
            onChanged: (v) => setState(() => _alpha = v),
          ),
        ),
        const _SectionHeader('Color'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: cs.ColorSwatch(
            selected: _color,
            onChanged: (c) => setState(() => _color = c),
          ),
        ),
        const _SectionHeader('Cap & Joint'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cap'),
              const SizedBox(height: 4),
              SegmentedButton<Cap>(
                segments: const [
                  ButtonSegment(value: Cap.buttCap, label: Text('Butt')),
                  ButtonSegment(value: Cap.roundCap, label: Text('Round')),
                  ButtonSegment(value: Cap.squareCap, label: Text('Square')),
                ],
                selected: {_cap},
                onSelectionChanged: (s) => setState(() => _cap = s.first),
              ),
              const SizedBox(height: 8),
              const Text('Joint type'),
              const SizedBox(height: 4),
              SegmentedButton<JointType>(
                segments: const [
                  ButtonSegment(value: JointType.round, label: Text('Round')),
                  ButtonSegment(value: JointType.bevel, label: Text('Bevel')),
                  ButtonSegment(
                    value: JointType.mitered,
                    label: Text('Mitered'),
                  ),
                ],
                selected: {_jointType},
                onSelectionChanged: (s) => setState(() => _jointType = s.first),
              ),
            ],
          ),
        ),
        const _SectionHeader('Pattern & Visibility'),
        SwitchListTile(
          title: const Text('Dashed pattern'),
          value: _dashed,
          onChanged: (v) => setState(() => _dashed = v),
        ),
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

