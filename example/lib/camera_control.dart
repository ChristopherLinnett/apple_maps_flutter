import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'page.dart';

const _kInitial = CameraPosition(target: LatLng(51.5074, -0.1278), zoom: 11);

const _kLocations = <String, CameraPosition>{
  'London': CameraPosition(target: LatLng(51.5074, -0.1278), zoom: 11),
  'Sydney': CameraPosition(target: LatLng(-33.852, 151.211), zoom: 11),
  'Tokyo': CameraPosition(target: LatLng(35.6762, 139.6503), zoom: 11),
  'New York': CameraPosition(target: LatLng(40.7128, -74.0060), zoom: 11),
  'San Francisco': CameraPosition(target: LatLng(37.7749, -122.4194), zoom: 11),
};

class CameraControlPage extends ExamplePage {
  const CameraControlPage({super.key})
    : super(const Icon(Icons.videocam), 'Camera Control');

  @override
  Widget build(BuildContext context) => const _CameraControlBody();
}

class _CameraControlBody extends StatefulWidget {
  const _CameraControlBody();

  @override
  State<_CameraControlBody> createState() => _CameraControlBodyState();
}

class _CameraControlBodyState extends State<_CameraControlBody> {
  AppleMapController? _controller;
  CameraPosition _position = _kInitial;
  String _selectedLocation = 'London';

  void _onMapCreated(AppleMapController c) => setState(() => _controller = c);
  void _onCameraMove(CameraPosition p) => setState(() => _position = p);

  Future<void> _animateTo(String name) async {
    setState(() => _selectedLocation = name);
    await _controller?.animateCamera(
      CameraUpdate.newCameraPosition(_kLocations[name]!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final map = AppleMap(
      initialCameraPosition: _kInitial,
      onMapCreated: _onMapCreated,
      onCameraMove: _onCameraMove,
    );

    return MapScaffold(
      title: 'Camera Control',
      map: map,
      controls: [
        const _SectionHeader('Target Location'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kLocations.keys.map((name) {
              final selected = _selectedLocation == name;
              return ChoiceChip(
                label: Text(name),
                selected: selected,
                onSelected: (_) => _animateTo(name),
              );
            }).toList(),
          ),
        ),
        const _SectionHeader('Zoom'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton.tonal(
                onPressed: () =>
                    _controller?.animateCamera(CameraUpdate.zoomIn()),
                child: const Text('Zoom in'),
              ),
              FilledButton.tonal(
                onPressed: () =>
                    _controller?.animateCamera(CameraUpdate.zoomOut()),
                child: const Text('Zoom out'),
              ),
              FilledButton.tonal(
                onPressed: () =>
                    _controller?.animateCamera(CameraUpdate.zoomTo(16)),
                child: const Text('Zoom to 16'),
              ),
            ],
          ),
        ),
        const _SectionHeader('Animate vs Move'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton.tonal(
                onPressed: () => _controller?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    const CameraPosition(
                      target: LatLng(51.5074, -0.1278),
                      heading: 45,
                      pitch: 30,
                      zoom: 15,
                    ),
                  ),
                ),
                child: const Text('Animate (pitch + heading)'),
              ),
              FilledButton.tonal(
                onPressed: () => _controller?.moveCamera(
                  CameraUpdate.newCameraPosition(
                    const CameraPosition(
                      target: LatLng(51.5074, -0.1278),
                      zoom: 11,
                    ),
                  ),
                ),
                child: const Text('Move (instant)'),
              ),
            ],
          ),
        ),
        const _SectionHeader('Fit Bounds'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: FilledButton.tonal(
            onPressed: () => _controller?.animateCamera(
              CameraUpdate.newLatLngBounds(
                LatLngBounds(
                  southwest: const LatLng(51.28, -0.51),
                  northeast: const LatLng(51.69, 0.33),
                ),
                50,
              ),
            ),
            child: const Text('Fit Greater London'),
          ),
        ),
        const _SectionHeader('Current Position'),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
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
