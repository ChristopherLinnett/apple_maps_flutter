import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'event_log.dart';
import 'page.dart';

const _kInitial = CameraPosition(target: LatLng(51.507, -0.127), zoom: 13);

class ProjectionPage extends ExamplePage {
  const ProjectionPage({super.key})
    : super(const Icon(Icons.grid_on), 'Projection & Coordinates');

  @override
  Widget build(BuildContext context) => const _ProjectionBody();
}

class _ProjectionBody extends StatefulWidget {
  const _ProjectionBody();

  @override
  State<_ProjectionBody> createState() => _ProjectionBodyState();
}

class _ProjectionBodyState extends State<_ProjectionBody> {
  final _logKey = GlobalKey<EventLogState>();
  AppleMapController? _controller;
  LatLngBounds? _visibleRegion;

  void _onMapCreated(AppleMapController c) async {
    _controller = c;
    final region = await c.getVisibleRegion();
    if (mounted) setState(() => _visibleRegion = region);
  }

  Future<void> _refreshRegion() async {
    final region = await _controller?.getVisibleRegion();
    if (mounted && region != null) setState(() => _visibleRegion = region);
  }

  Future<void> _onTap(LatLng latLng) async {
    final controller = _controller;
    if (controller == null) return;

    final Offset? screenCoord =
        await controller.getScreenCoordinate(latLng);
    if (screenCoord == null) {
      _logKey.currentState?.add('getScreenCoordinate returned null');
      return;
    }
    final LatLng? roundTrip = await controller.getLatLng(screenCoord);

    _logKey.currentState?.add(
      'Tap  lat=${latLng.latitude.toStringAsFixed(5)}  lng=${latLng.longitude.toStringAsFixed(5)}',
    );
    _logKey.currentState?.add(
      '→ screen  x=${screenCoord.dx.toStringAsFixed(1)}  y=${screenCoord.dy.toStringAsFixed(1)}',
    );
    if (roundTrip != null) {
      final deltaLat = (roundTrip.latitude - latLng.latitude).abs();
      final deltaLng = (roundTrip.longitude - latLng.longitude).abs();
      _logKey.currentState?.add(
        '→ back  Δlat=${deltaLat.toStringAsExponential(2)}  Δlng=${deltaLng.toStringAsExponential(2)}',
      );
    } else {
      _logKey.currentState?.add('→ getLatLng returned null');
    }
  }

  @override
  Widget build(BuildContext context) {
    final map = AppleMap(
      initialCameraPosition: _kInitial,
      onMapCreated: _onMapCreated,
      onTap: _onTap,
    );

    return MapScaffold(
      title: 'Projection & Coordinates',
      map: map,
      initialSheetSize: 0.40,
      controls: [
        const _SectionHeader('Visible Region'),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: _visibleRegion == null
              ? const Text('Loading…')
              : DefaultTextStyle(
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(fontFamily: 'monospace'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NE: ${_visibleRegion!.northeast.latitude.toStringAsFixed(5)}, '
                        '${_visibleRegion!.northeast.longitude.toStringAsFixed(5)}',
                      ),
                      Text(
                        'SW: ${_visibleRegion!.southwest.latitude.toStringAsFixed(5)}, '
                        '${_visibleRegion!.southwest.longitude.toStringAsFixed(5)}',
                      ),
                    ],
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: FilledButton.tonal(
            onPressed: _refreshRegion,
            child: const Text('Refresh visible region'),
          ),
        ),
        const _SectionHeader('Round-trip: getScreenCoordinate → getLatLng'),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Tap the map. The tap LatLng will be converted to a screen '
            'coordinate via getScreenCoordinate, then back via getLatLng. '
            'The round-trip error is logged below.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Event log'),
              TextButton(
                onPressed: () => _logKey.currentState?.clear(),
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
        EventLog(key: _logKey, height: 140),
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
