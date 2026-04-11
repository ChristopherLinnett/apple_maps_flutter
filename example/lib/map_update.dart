import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:apple_maps_flutter_example/page.dart';
import 'package:flutter/material.dart';

class MapUpdatePage extends ExamplePage {
  const MapUpdatePage({super.key})
    : super(const Icon(Icons.refresh), 'Update Map');

  @override
  Widget build(BuildContext context) {
    return _MapUpdate();
  }
}

class _MapUpdate extends StatefulWidget {
  const _MapUpdate();
  @override
  _MapUpdateState createState() => _MapUpdateState();
}

class _MapUpdateState extends State<_MapUpdate> {
  @override
  Widget build(BuildContext context) {
    return AppleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(-33.852, 151.211),
        zoom: 11,
      ),
    );
  }
}
