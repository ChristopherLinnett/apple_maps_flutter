import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'event_log.dart';
import 'page.dart';

const _kInitial = CameraPosition(target: LatLng(48.8566, 2.3522), zoom: 12);

class MapEventsPage extends ExamplePage {
  const MapEventsPage({super.key})
    : super(const Icon(Icons.notifications_none), 'Map Events');

  @override
  Widget build(BuildContext context) => const _MapEventsBody();
}

class _MapEventsBody extends StatefulWidget {
  const _MapEventsBody();

  @override
  State<_MapEventsBody> createState() => _MapEventsBodyState();
}

class _MapEventsBodyState extends State<_MapEventsBody> {
  final _logKey = GlobalKey<EventLogState>();
  CameraPosition _position = _kInitial;
  int _moveStartedCount = 0;
  int _idleCount = 0;

  @override
  Widget build(BuildContext context) {
    return MapScaffold(
      title: 'Map Events',
      mapBuilder: (mapPadding) => AppleMap(
        initialCameraPosition: _kInitial,
        onTap: (pos) => _logKey.currentState?.add(
          'Tap  lat=${pos.latitude.toStringAsFixed(5)}  lng=${pos.longitude.toStringAsFixed(5)}',
        ),
        onLongPress: (pos) => _logKey.currentState?.add(
          'LongPress  lat=${pos.latitude.toStringAsFixed(5)}  lng=${pos.longitude.toStringAsFixed(5)}',
        ),
        onCameraMoveStarted: () {
          setState(() => _moveStartedCount++);
          _logKey.currentState?.add('Camera move started (#$_moveStartedCount)');
        },
        onCameraMove: (pos) => setState(() => _position = pos),
        onCameraIdle: () {
          setState(() => _idleCount++);
          _logKey.currentState?.add('Camera idle (#$_idleCount)');
        },
        padding: mapPadding,
      ),
      initialSheetSize: 0.38,
      controls: [
        const _SectionHeader('Camera'),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: DefaultTextStyle(
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(fontFamily: 'monospace'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'lat: ${_position.target.latitude.toStringAsFixed(5)}  '
                  'lng: ${_position.target.longitude.toStringAsFixed(5)}',
                ),
                Text(
                  'zoom: ${_position.zoom.toStringAsFixed(2)}  '
                  'heading: ${_position.heading.toStringAsFixed(1)}°  '
                  'pitch: ${_position.pitch.toStringAsFixed(1)}°',
                ),
              ],
            ),
          ),
        ),
        const _SectionHeader('Event Log'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tap or drag the map to generate events',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextButton(
                onPressed: () => _logKey.currentState?.clear(),
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
        EventLog(key: _logKey, height: 160),
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
