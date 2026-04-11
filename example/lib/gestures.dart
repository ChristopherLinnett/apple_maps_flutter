import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'page.dart';

const _kInitial = CameraPosition(target: LatLng(48.8566, 2.3522), zoom: 12);

class GesturesPage extends ExamplePage {
  const GesturesPage({super.key})
    : super(const Icon(Icons.touch_app), 'Gestures & Controls');

  @override
  Widget build(BuildContext context) => const _GesturesBody();
}

class _GesturesBody extends StatefulWidget {
  const _GesturesBody();

  @override
  State<_GesturesBody> createState() => _GesturesBodyState();
}

class _GesturesBodyState extends State<_GesturesBody> {
  bool _rotateGestures = true;
  bool _scrollGestures = true;
  bool _zoomGestures = true;
  bool _pitchGestures = true;
  bool _myLocationButton = true;

  @override
  Widget build(BuildContext context) {
    return MapScaffold(
      title: 'Gestures & Controls',
      mapBuilder: (mapPadding) => AppleMap(
        initialCameraPosition: _kInitial,
        rotateGesturesEnabled: _rotateGestures,
        scrollGesturesEnabled: _scrollGestures,
        zoomGesturesEnabled: _zoomGestures,
        pitchGesturesEnabled: _pitchGestures,
        myLocationButtonEnabled: _myLocationButton,
        padding: mapPadding,
      ),
      controls: [
        const _SectionHeader('Gesture Recognizers'),
        SwitchListTile(
          title: const Text('Rotate gestures'),
          subtitle: const Text('Two-finger twist to rotate'),
          value: _rotateGestures,
          onChanged: (v) => setState(() => _rotateGestures = v),
        ),
        SwitchListTile(
          title: const Text('Scroll gestures'),
          subtitle: const Text('Drag to pan'),
          value: _scrollGestures,
          onChanged: (v) => setState(() => _scrollGestures = v),
        ),
        SwitchListTile(
          title: const Text('Zoom gestures'),
          subtitle: const Text(
            'Pinch to zoom — try it; the map fills the screen so the gesture lands correctly on the simulator',
          ),
          value: _zoomGestures,
          onChanged: (v) => setState(() => _zoomGestures = v),
        ),
        SwitchListTile(
          title: const Text('Pitch gestures'),
          subtitle: const Text('Two-finger drag up/down to tilt'),
          value: _pitchGestures,
          onChanged: (v) => setState(() => _pitchGestures = v),
        ),
        const _SectionHeader('Controls'),
        SwitchListTile(
          title: const Text('Location button'),
          value: _myLocationButton,
          onChanged: (v) => setState(() => _myLocationButton = v),
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
