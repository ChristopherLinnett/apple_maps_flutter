import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'page.dart';

const _kInitial = CameraPosition(target: LatLng(51.507, -0.127), zoom: 13);

class MapPaddingPage extends ExamplePage {
  const MapPaddingPage({super.key})
    : super(const Icon(Icons.padding), 'Map Padding');

  @override
  Widget build(BuildContext context) => const _MapPaddingBody();
}

class _MapPaddingBody extends StatefulWidget {
  const _MapPaddingBody();

  @override
  State<_MapPaddingBody> createState() => _MapPaddingBodyState();
}

class _MapPaddingBodyState extends State<_MapPaddingBody> {
  double _top = 0;
  double _right = 0;
  double _bottom = 0;
  double _left = 0;
  bool _insetsFromSafeArea = true;

  @override
  Widget build(BuildContext context) {
    return MapScaffold(
      title: 'Map Padding',
      // Ignore the injected mapPadding: this page exclusively controls padding
      // through its own sliders, which is the point of the demo.
      mapBuilder: (_) => AppleMap(
        initialCameraPosition: _kInitial,
        padding: EdgeInsets.fromLTRB(_left, _top, _right, _bottom),
        insetsLayoutMarginsFromSafeArea: _insetsFromSafeArea,
      ),
      controls: [
        const _SectionHeader('Padding (pts)'),
        _PaddingSlider(
          label: 'Top',
          value: _top,
          onChanged: (v) => setState(() => _top = v),
        ),
        _PaddingSlider(
          label: 'Right',
          value: _right,
          onChanged: (v) => setState(() => _right = v),
        ),
        _PaddingSlider(
          label: 'Bottom',
          value: _bottom,
          onChanged: (v) => setState(() => _bottom = v),
        ),
        _PaddingSlider(
          label: 'Left',
          value: _left,
          onChanged: (v) => setState(() => _left = v),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Text(
            'Current: T=${_top.toStringAsFixed(0)}  '
            'R=${_right.toStringAsFixed(0)}  '
            'B=${_bottom.toStringAsFixed(0)}  '
            'L=${_left.toStringAsFixed(0)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
          ),
        ),
        const _SectionHeader('Safe Area'),
        SwitchListTile(
          title: const Text('Insets from safe area'),
          subtitle: const Text(
            'When on, the map respects the device safe-area insets in addition to the explicit padding.',
          ),
          value: _insetsFromSafeArea,
          onChanged: (v) => setState(() => _insetsFromSafeArea = v),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            'Watch the compass and scale indicator move as you adjust padding. '
            'The visible-region center tracks with the padded viewport.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _PaddingSlider extends StatelessWidget {
  const _PaddingSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('$label: ${value.toStringAsFixed(0)} pt'),
      subtitle: Slider(
        value: value,
        max: 120,
        divisions: 24,
        onChanged: onChanged,
      ),
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
