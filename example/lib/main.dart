import 'package:apple_maps_flutter_example/annotation_clustering.dart';
import 'package:apple_maps_flutter_example/annotations.dart';
import 'package:apple_maps_flutter_example/camera_bounds.dart';
import 'package:apple_maps_flutter_example/camera_control.dart';
import 'package:apple_maps_flutter_example/circles.dart';
import 'package:apple_maps_flutter_example/gestures.dart';
import 'package:apple_maps_flutter_example/location_tracking.dart';
import 'package:apple_maps_flutter_example/map_appearance.dart';
import 'package:apple_maps_flutter_example/map_events.dart';
import 'package:apple_maps_flutter_example/map_padding.dart';
import 'package:apple_maps_flutter_example/page.dart';
import 'package:apple_maps_flutter_example/polygons.dart';
import 'package:apple_maps_flutter_example/polylines.dart';
import 'package:apple_maps_flutter_example/projection.dart';
import 'package:apple_maps_flutter_example/scrolling_map.dart';
import 'package:apple_maps_flutter_example/snapshots.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AppleMapsExampleApp());
}

class AppleMapsExampleApp extends StatelessWidget {
  const AppleMapsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apple Maps Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A73E8)),
        useMaterial3: true,
      ),
      home: const _HomePage(),
    );
  }
}

class _Section {
  const _Section(this.title, this.pages);
  final String title;
  final List<ExamplePage> pages;
}

final List<_Section> _sections = [
  _Section('Appearance', [MapAppearancePage()]),
  _Section('Camera', [CameraControlPage(), CameraBoundsPage()]),
  _Section('Interaction', [GesturesPage(), MapEventsPage()]),
  _Section('Location', [LocationTrackingPage()]),
  _Section('Annotations', [AnnotationsPage(), AnnotationClusteringPage()]),
  _Section('Overlays', [PolylinesPage(), PolygonsPage(), CirclesPage()]),
  _Section('API & Utilities', [
    ProjectionPage(),
    MapPaddingPage(),
    SnapshotsPage(),
    ScrollingMapPage(),
  ]),
];

class _HomePage extends StatelessWidget {
  const _HomePage();

  void _pushPage(BuildContext context, ExamplePage page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<Widget> items = [];

    for (final section in _sections) {
      items.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text(
            section.title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
      for (final page in section.pages) {
        items.add(
          ListTile(
            leading: IconTheme(
              data: IconThemeData(color: colorScheme.primary),
              child: page.leading,
            ),
            title: Text(page.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pushPage(context, page),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apple Maps Flutter'),
        centerTitle: false,
      ),
      body: ListView(children: items),
    );
  }
}
