import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'page.dart';

const _kInitial = CameraPosition(target: LatLng(-33.852, 151.211), zoom: 11);

class MapAppearancePage extends ExamplePage {
  const MapAppearancePage({super.key})
    : super(const Icon(Icons.layers), 'Map Appearance');

  @override
  Widget build(BuildContext context) => const _MapAppearanceBody();
}

class _MapAppearanceBody extends StatefulWidget {
  const _MapAppearanceBody();

  @override
  State<_MapAppearanceBody> createState() => _MapAppearanceBodyState();
}

class _MapAppearanceBodyState extends State<_MapAppearanceBody> {
  MapType _mapType = MapType.standard;
  MapEmphasisStyle _emphasisStyle = MapEmphasisStyle.defaultStyle;
  bool _trafficEnabled = false;
  bool _compassEnabled = true;
  bool _scaleEnabled = true;
  bool _buildingsEnabled = true;
  bool _pointsOfInterestEnabled = true;

  @override
  Widget build(BuildContext context) {
    return MapScaffold(
      title: 'Map Appearance',
      mapBuilder: (mapPadding) => AppleMap(
        initialCameraPosition: _kInitial,
        mapType: _mapType,
        emphasisStyle: _emphasisStyle,
        trafficEnabled: _trafficEnabled,
        compassEnabled: _compassEnabled,
        scaleEnabled: _scaleEnabled,
        buildingsEnabled: _buildingsEnabled,
        pointsOfInterestEnabled: _pointsOfInterestEnabled,
        padding: mapPadding,
      ),
      controls: [
        const _SectionHeader('Map Type'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SegmentedButton<MapType>(
            segments: const [
              ButtonSegment(value: MapType.standard, label: Text('Standard')),
              ButtonSegment(value: MapType.satellite, label: Text('Satellite')),
              ButtonSegment(value: MapType.hybrid, label: Text('Hybrid')),
            ],
            selected: {_mapType},
            onSelectionChanged: (s) => setState(() => _mapType = s.first),
          ),
        ),
        const _SectionHeader('Style'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SegmentedButton<MapEmphasisStyle>(
            segments: const [
              ButtonSegment(
                value: MapEmphasisStyle.defaultStyle,
                label: Text('Default'),
              ),
              ButtonSegment(
                value: MapEmphasisStyle.muted,
                label: Text('Muted'),
              ),
            ],
            selected: {_emphasisStyle},
            onSelectionChanged: (s) => setState(() => _emphasisStyle = s.first),
          ),
        ),
        const _SectionHeader('Overlays & Controls'),
        SwitchListTile(
          title: const Text('Traffic'),
          subtitle: const Text(
            'Requires live traffic data for your region. '
            'May not be visible on the simulator or in areas without data.',
          ),
          value: _trafficEnabled,
          onChanged: (v) => setState(() => _trafficEnabled = v),
        ),
        SwitchListTile(
          title: const Text('Compass'),
          value: _compassEnabled,
          onChanged: (v) => setState(() => _compassEnabled = v),
        ),
        SwitchListTile(
          title: const Text('Scale indicator'),
          subtitle: const Text(
            'Briefly visible during and just after a zoom gesture.',
          ),
          value: _scaleEnabled,
          onChanged: (v) => setState(() => _scaleEnabled = v),
        ),
        SwitchListTile(
          title: const Text('Buildings'),
          subtitle: const Text(
            'On iOS 16+ this controls 3D building extrusion — tilt the map '
            'to see the effect. On older iOS it hides building footprints.',
          ),
          value: _buildingsEnabled,
          onChanged: (v) => setState(() => _buildingsEnabled = v),
        ),
        SwitchListTile(
          title: const Text('Points of interest'),
          value: _pointsOfInterestEnabled,
          onChanged: (v) => setState(() => _pointsOfInterestEnabled = v),
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
