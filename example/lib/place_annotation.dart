// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'page.dart';

class PlaceAnnotationPage extends ExamplePage {
  const PlaceAnnotationPage({super.key}) : super(const Icon(Icons.place), 'Place annotation');

  @override
  Widget build(BuildContext context) {
    return const PlaceAnnotationBody();
  }
}

class PlaceAnnotationBody extends StatefulWidget {
  const PlaceAnnotationBody({super.key});

  @override
  State<StatefulWidget> createState() => PlaceAnnotationBodyState();
}

typedef AnnotationUpdateAction = Annotation Function(Annotation annotation);

class PlaceAnnotationBodyState extends State<PlaceAnnotationBody> {
  PlaceAnnotationBodyState();
  static final LatLng center = const LatLng(-33.86711, 151.1947171);

  late AppleMapController controller;
  Uint8List? _imageBytes;
  Map<AnnotationId, Annotation> annotations = <AnnotationId, Annotation>{};
  AnnotationId? selectedAnnotationId;
  int _annotationIdCounter = 1;
  BitmapDescriptor? _annotationIcon;
  late BitmapDescriptor _iconFromBytes;
  final double _devicePixelRatio = 3.0;

  void _onMapCreated(AppleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onAnnotationTapped(AnnotationId annotationId) {
    final Annotation? tappedAnnotation = annotations[annotationId];
    if (tappedAnnotation == null) return;

    setState(() {
      // Reset the previously selected annotation's visual state, if any.
      final AnnotationId? previous = selectedAnnotationId;
      if (previous != null && annotations.containsKey(previous)) {
        annotations[previous] = annotations[previous]!.copyWith();
      }
      selectedAnnotationId = annotationId;
    });
  }

  void _add(String iconType) {
    final int annotationCount = annotations.length;

    if (annotationCount == 12) {
      return;
    }

    final String annotationIdVal = 'annotation_id_$_annotationIdCounter';
    _annotationIdCounter++;
    final AnnotationId annotationId = AnnotationId(annotationIdVal);

    BitmapDescriptor bitMapDescriptor = BitmapDescriptor.defaultAnnotation;

    switch (iconType) {
      case 'marker':
        bitMapDescriptor = BitmapDescriptor.markerAnnotation;
        break;
      case 'pin':
        bitMapDescriptor = BitmapDescriptor.defaultAnnotation;
        break;
      case 'customAnnotationFromBytes':
        bitMapDescriptor = _iconFromBytes;
        break;
      case 'markerAnnotationWithHue':
        bitMapDescriptor = BitmapDescriptor.markerAnnotationWithHue(
          Random().nextDouble() * 360,
        );
        break;
      case 'defaultAnnotationWithColor':
        bitMapDescriptor = BitmapDescriptor.defaultAnnotationWithHue(
          Random().nextDouble() * 360,
        );
        break;
    }

    final Annotation annotation = Annotation(
      annotationId: annotationId,
      icon: bitMapDescriptor,
      position: LatLng(
        center.latitude + sin(_annotationIdCounter * pi / 6.0) / 20.0,
        center.longitude + cos(_annotationIdCounter * pi / 6.0) / 20.0,
      ),
      zIndex: annotationCount.toDouble(),
      infoWindow: InfoWindow(
        title: annotationIdVal,
        anchor: Offset(0.5, 0.0),
        snippet: '*',
        onTap: () => debugPrint('InfoWindow with id: $annotationId tapped.'),
      ),
      onTap: () {
        _onAnnotationTapped(annotationId);
      },
    );

    setState(() {
      annotations[annotationId] = annotation;
    });
  }

  void _remove() {
    setState(() {
      if (annotations.containsKey(selectedAnnotationId)) {
        annotations.remove(selectedAnnotationId);
      }
    });
  }

  void _changePosition() {
    final AnnotationId? id = selectedAnnotationId;
    if (id == null) return;
    final Annotation annotation = annotations[id]!;
    final LatLng current = annotation.position;
    final Offset offset = Offset(
      center.latitude - current.latitude,
      center.longitude - current.longitude,
    );
    setState(() {
      annotations[id] = annotation.copyWith(
        positionParam: LatLng(
          center.latitude + offset.dy,
          center.longitude + offset.dx,
        ),
      );
    });
  }

  Future<void> _toggleDraggable() async {
    final AnnotationId? id = selectedAnnotationId;
    if (id == null) return;
    final Annotation annotation = annotations[id]!;
    setState(() {
      annotations[id] = annotation.copyWith(
        draggableParam: !annotation.draggable,
      );
    });
  }

  Future<void> _changeInfo() async {
    final AnnotationId? id = selectedAnnotationId;
    if (id == null) return;
    final Annotation annotation = annotations[id]!;
    final String newSnippet =
        annotation.infoWindow.snippet! +
        (annotation.infoWindow.snippet!.length % 10 == 0 ? '\n' : '*');
    setState(() {
      annotations[id] = annotation.copyWith(
        infoWindowParam: annotation.infoWindow.copyWith(
          snippetParam: newSnippet,
        ),
      );
    });
  }

  Future<void> _changeAlpha() async {
    final AnnotationId? id = selectedAnnotationId;
    if (id == null) return;
    final Annotation annotation = annotations[id]!;
    final double current = annotation.alpha;
    setState(() {
      annotations[id] = annotation.copyWith(
        alphaParam: current < 0.1 ? 1.0 : current * 0.75,
      );
    });
  }

  Future<void> _toggleVisible() async {
    final AnnotationId? id = selectedAnnotationId;
    if (id == null) return;
    final Annotation annotation = annotations[id]!;
    setState(() {
      annotations[id] = annotation.copyWith(
        visibleParam: !annotation.visible,
      );
    });
  }

  Future<void> _createAnnotationImageFromAsset(
    BuildContext context,
    double devicelPixelRatio,
  ) async {
    if (_annotationIcon == null) {
      final ImageConfiguration imageConfiguration = ImageConfiguration(
        devicePixelRatio: devicelPixelRatio,
      );
      BitmapDescriptor.fromAssetImage(
        imageConfiguration,
        'assets/red_square.png',
      ).then(_updateBitmap);
    }
  }

  void _updateBitmap(BitmapDescriptor bitmap) {
    setState(() {
      _annotationIcon = bitmap;
    });
  }

  Future<void> _showInfoWindow() async {
    final AnnotationId? id = selectedAnnotationId;
    if (id == null) return;
    final Annotation? annotation = annotations[id];
    if (annotation == null) return;
    await controller.showMarkerInfoWindow(annotation.annotationId);
  }

  Future<void> _hideInfoWindow() async {
    final AnnotationId? id = selectedAnnotationId;
    if (id == null) return;
    final Annotation? annotation = annotations[id];
    if (annotation == null) return;
    controller.hideMarkerInfoWindow(annotation.annotationId);
  }

  Future<bool> _isInfoWindowShown() async {
    final AnnotationId? id = selectedAnnotationId;
    if (id == null) return false;
    final Annotation? annotation = annotations[id];
    if (annotation == null) return false;
    debugPrint(
      'Is InfowWindow visible: ${await controller.isMarkerInfoWindowShown(annotation.annotationId)}',
    );
    return (await controller.isMarkerInfoWindowShown(
      annotation.annotationId,
    ))!;
  }

  Future<void> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    _iconFromBytes = BitmapDescriptor.fromBytes(
      (await fi.image.toByteData(
        format: ui.ImageByteFormat.png,
      ))!.buffer.asUint8List(),
    );
  }

  Future<void> _changeZIndex(AnnotationId annotationId) async {
    final Annotation annotation = annotations[annotationId]!;
    final double current = annotation.zIndex;
    setState(() {
      annotations[annotationId] = annotation.copyWith(
        zIndexParam: current >= 12.0 ? 0.0 : current + 1.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _createAnnotationImageFromAsset(context, _devicePixelRatio);
    _getBytesFromAsset('assets/creator.png', 160);
    return SafeArea(
      child: Column(
        children: <Widget>[
          Expanded(
            child: AppleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(-33.852, 151.211),
                zoom: 11,
              ),
              annotations: Set<Annotation>.of(annotations.values),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: const Text('add defaultAnnotation'),
                  onPressed: () => _add('pin'),
                ),
                TextButton(
                  child: const Text('add defaultWithHue'),
                  onPressed: () => _add('defaultAnnotationWithColor'),
                ),
                TextButton(
                  child: const Text('add markerAnnotation'),
                  onPressed: () => _add('marker'),
                ),
                TextButton(
                  child: const Text('add markerWithHue'),
                  onPressed: () => _add('markerAnnotationWithHue'),
                ),
                TextButton(
                  child: const Text('add customAnnotation'),
                  onPressed: () => _add('customAnnotation'),
                ),
                TextButton(
                  child: const Text('customAnnotation from bytes'),
                  onPressed: () => _add('customAnnotationFromBytes'),
                ),
                TextButton(onPressed: _remove, child: const Text('remove')),
                TextButton(
                  onPressed: _changeInfo,
                  child: const Text('change info'),
                ),
                TextButton(
                  onPressed: _isInfoWindowShown,
                  child: const Text('infoWindow is shown?s'),
                ),
                TextButton(
                  onPressed: _changeAlpha,
                  child: const Text('change alpha'),
                ),
                TextButton(
                  onPressed: _toggleDraggable,
                  child: const Text('toggle draggable'),
                ),
                TextButton(
                  onPressed: _changePosition,
                  child: const Text('change position'),
                ),
                TextButton(
                  onPressed: _toggleVisible,
                  child: const Text('toggle visible'),
                ),
                TextButton(
                  onPressed: _showInfoWindow,
                  child: const Text('show infoWindow'),
                ),
                TextButton(
                  onPressed: _hideInfoWindow,
                  child: const Text('hide infoWindow'),
                ),
                TextButton(
                  child: const Text('change zIndex'),
                  onPressed: () {
                    if (selectedAnnotationId != null) {
                      _changeZIndex(selectedAnnotationId!);
                    }
                  },
                ),
                TextButton(
                  child: Text('Take a snapshot'),
                  onPressed: () async {
                    final imageBytes = await controller.takeSnapshot();
                    setState(() {
                      _imageBytes = imageBytes;
                    });
                  },
                ),
                Container(
                  decoration: BoxDecoration(color: Colors.blueGrey[50]),
                  height: 180,
                  child: _imageBytes != null
                      ? Image.memory(_imageBytes!)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
