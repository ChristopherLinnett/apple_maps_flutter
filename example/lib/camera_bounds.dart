import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'page.dart';

const _kInitial = CameraPosition(target: LatLng(51.506, -0.119), zoom: 10);

final LatLngBounds _kLondonBounds = LatLngBounds(
  southwest: const LatLng(51.28, -0.51),
  northeast: const LatLng(51.69, 0.33),
);

class CameraBoundsPage extends ExamplePage {
  const CameraBoundsPage({super.key})
    : super(const Icon(Icons.crop_free), 'Camera Bounds');

  @override
  Widget build(BuildContext context) => const _CameraBoundsBody();
}

class _CameraBoundsBody extends StatefulWidget {
  const _CameraBoundsBody();

  @override
  State<_CameraBoundsBody> createState() => _CameraBoundsBodyState();
}

class _CameraBoundsBodyState extends State<_CameraBoundsBody> {
  bool _zoomRestricted = false;
  bool _boundsRestricted = false;

  MinMaxZoomPreference get _zoom => _zoomRestricted
      ? const MinMaxZoomPreference(10, 14)
      : MinMaxZoomPreference.unbounded;

  CameraTargetBounds get _bounds => _boundsRestricted
      ? CameraTargetBounds(_kLondonBounds)
      : CameraTargetBounds.unbounded;

  @override
  Widget build(BuildContext context) {
    final map = AppleMap(
      initialCameraPosition: _kInitial,
      minMaxZoomPreference: _zoom,
      cameraTargetBounds: _bounds,
    );

    return MapScaffold(
      title: 'Camera Bounds',
      map: map,
      controls: [
        const _SectionHeader('Zoom Restrictions'),
        SwitchListTile(
          title: const Text('Restrict zoom (10–14)'),
          subtitle: _zoomRestricted
              ? const Text('Try pinching — zoom won\'t go below 10 or above 14')
              : null,
          value: _zoomRestricted,
          onChanged: (v) => setState(() => _zoomRestricted = v),
        ),
        const _SectionHeader('Geographic Bounds'),
        SwitchListTile(
          title: const Text('Lock camera to Greater London'),
          subtitle: _boundsRestricted
              ? const Text('Try panning outside Greater London')
              : null,
          value: _boundsRestricted,
          onChanged: (v) => setState(() => _boundsRestricted = v),
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
