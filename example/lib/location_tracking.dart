import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'page.dart';

const _kInitial = CameraPosition(target: LatLng(51.5074, -0.1278), zoom: 13);

class LocationTrackingPage extends ExamplePage {
  const LocationTrackingPage({super.key})
    : super(const Icon(Icons.my_location), 'Location & Tracking');

  @override
  Widget build(BuildContext context) => const _LocationTrackingBody();
}

class _LocationTrackingBody extends StatefulWidget {
  const _LocationTrackingBody();

  @override
  State<_LocationTrackingBody> createState() => _LocationTrackingBodyState();
}

class _LocationTrackingBodyState extends State<_LocationTrackingBody> {
  bool _myLocationEnabled = false;
  bool _myLocationButton = true;
  TrackingMode _trackingMode = TrackingMode.none;

  @override
  Widget build(BuildContext context) {
    final map = AppleMap(
      initialCameraPosition: _kInitial,
      myLocationEnabled: _myLocationEnabled,
      myLocationButtonEnabled: _myLocationButton,
      trackingMode: _trackingMode,
    );

    return MapScaffold(
      title: 'Location & Tracking',
      map: map,
      controls: [
        const _SectionHeader('Location'),
        SwitchListTile(
          title: const Text('Show my location'),
          subtitle: const Text(
            'Requires NSLocationWhenInUseUsageDescription in Info.plist',
          ),
          value: _myLocationEnabled,
          onChanged: (v) => setState(() => _myLocationEnabled = v),
        ),
        SwitchListTile(
          title: const Text('Location button'),
          value: _myLocationButton,
          onChanged: (v) => setState(() => _myLocationButton = v),
        ),
        const _SectionHeader('Tracking Mode'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SegmentedButton<TrackingMode>(
            segments: const [
              ButtonSegment(value: TrackingMode.none, label: Text('None')),
              ButtonSegment(value: TrackingMode.follow, label: Text('Follow')),
              ButtonSegment(
                value: TrackingMode.followWithHeading,
                label: Text('Heading'),
              ),
            ],
            selected: {_trackingMode},
            onSelectionChanged: (s) => setState(() => _trackingMode = s.first),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            '"Follow" and "Heading" modes only take effect when '
            '"Show my location" is enabled and a location fix is available.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
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
