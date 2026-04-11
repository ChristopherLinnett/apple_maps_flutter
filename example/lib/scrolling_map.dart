import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'page.dart';

const _kCenter = LatLng(32.080664, 34.9563837);
const _kInitial = CameraPosition(target: _kCenter, zoom: 11);

class ScrollingMapPage extends ExamplePage {
  const ScrollingMapPage({super.key})
    : super(const Icon(Icons.swap_vert), 'Scrolling Map');

  @override
  Widget build(BuildContext context) => const _ScrollingMapBody();
}

class _ScrollingMapBody extends StatelessWidget {
  const _ScrollingMapBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scrolling Map')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _MapCard(
              title: 'Map consumes all gestures',
              subtitle:
                  'EagerGestureRecognizer — the map intercepts every touch, '
                  'including vertical drags. While your finger is on this map '
                  'the page cannot be scrolled.',
              mapHeight: 280,
              map: AppleMap(
                initialCameraPosition: _kInitial,
                gestureRecognizers: {
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
              ),
            ),
            const SizedBox(height: 16),
            _MapCard(
              title: 'Map shares gestures with scroll view',
              subtitle:
                  'ScaleGestureRecognizer only — vertical drags scroll the '
                  'page normally. Pinch-to-zoom and pan still work on the map.',
              mapHeight: 280,
              map: AppleMap(
                initialCameraPosition: _kInitial,
                annotations: {
                  const Annotation(
                    annotationId: AnnotationId('landmark'),
                    position: _kCenter,
                    infoWindow: InfoWindow(title: 'Tel Aviv–Yafo'),
                  ),
                },
                gestureRecognizers: {
                  Factory<OneSequenceGestureRecognizer>(
                    () => ScaleGestureRecognizer(),
                  ),
                },
                insetsLayoutMarginsFromSafeArea: false,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Tip — the maps above each have a fixed height of 280 pt. '
                  'Their centres are at the screen centre when the card is visible, so '
                  'simulator pinch-to-zoom works correctly.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({
    required this.title,
    required this.subtitle,
    required this.mapHeight,
    required this.map,
  });

  final String title;
  final String subtitle;
  final double mapHeight;
  final Widget map;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: mapHeight, child: map),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
