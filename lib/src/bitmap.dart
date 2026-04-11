// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../apple_maps_flutter.dart';

/// Defines a bitmap image. For a annotation, this class can be used to set the
/// image of the annotation icon. For a ground overlay, it can be used to set the
/// image to place on the surface of the earth.
class BitmapDescriptor {
  const BitmapDescriptor._(this._json);

  /// Convenience hue value representing red.
  static const double hueRed = 0.0;

  /// Convenience hue value representing orange.
  static const double hueOrange = 30.0;

  /// Convenience hue value representing yellow.
  static const double hueYellow = 60.0;

  /// Convenience hue value representing green.
  static const double hueGreen = 120.0;

  /// Convenience hue value representing cyan.
  static const double hueCyan = 180.0;

  /// Convenience hue value representing azure.
  static const double hueAzure = 210.0;

  /// Convenience hue value representing blue.
  static const double hueBlue = 240.0;

  /// Convenience hue value representing violet.
  static const double hueViolet = 270.0;

  /// Convenience hue value representing magenta.
  static const double hueMagenta = 300.0;

  /// Convenience hue value representing rose.
  static const double hueRose = 330.0;

  /// Creates a BitmapDescriptor that refers to the default/Pin annotation image.
  static const BitmapDescriptor defaultAnnotation = BitmapDescriptor._(
    <dynamic>['defaultAnnotation'],
  );

  // Process-lifetime cache for markerAnnotation descriptors. Keyed by the
  // caller-supplied cacheKey, so re-renders are avoided across widget rebuilds.
  static final Map<String, BitmapDescriptor> _markerAnnotationCache = {};

  /// Creates a [BitmapDescriptor] that uses the native Apple marker balloon
  /// (`MKMarkerAnnotationView`).
  ///
  /// [hue] tints the balloon body (0–359 degrees). When omitted the system
  /// default tint is used.
  ///
  /// [glyphWidget] is rendered off-screen to a PNG and placed as the small
  /// glyph image inside the balloon. [glyphSize] controls the logical pixel
  /// size of the rendered image (default 20×20). Any widget is supported,
  /// including [Image.asset] — async image loading is handled internally.
  ///
  /// [cacheKey] is an optional string that uniquely identifies this
  /// configuration. When provided, the result is cached for the process
  /// lifetime so subsequent calls with the same key return instantly without
  /// re-rendering. Use a key that encodes all the relevant parameters, for
  /// example `'dive-freediver-cyan-24x36'`.
  ///
  /// When neither [glyphWidget] nor [hue] is supplied this behaves the same as
  /// the old `BitmapDescriptor.markerAnnotation` constant — the default system
  /// balloon with no tint override.
  static Future<BitmapDescriptor> markerAnnotation({
    String? cacheKey,
    Widget? glyphWidget,
    Size glyphSize = const Size(20, 20),
    double? hue,
  }) async {
    if (hue != null) {
      assert(0.0 <= hue && hue < 360.0, 'hue must be in [0, 360)');
    }

    if (cacheKey != null) {
      final cached = _markerAnnotationCache[cacheKey];
      if (cached != null) return cached;
    }

    final double? iosHue = hue != null ? hue / 360.0 : null;

    BitmapDescriptor result;
    if (glyphWidget != null) {
      final Uint8List bytes = await _renderWidgetToBytes(
        glyphWidget,
        logicalSize: glyphSize,
      );
      // Encoding: ['markerAnnotation', iosHue?, glyphBytes]
      // When iosHue is null we omit it so the list stays compact.
      result = iosHue != null
          ? BitmapDescriptor._(<dynamic>['markerAnnotation', iosHue, bytes])
          : BitmapDescriptor._(<dynamic>['markerAnnotation', bytes]);
    } else if (iosHue != null) {
      result = BitmapDescriptor._(<dynamic>['markerAnnotation', iosHue]);
    } else {
      result = BitmapDescriptor._(<dynamic>['markerAnnotation']);
    }

    if (cacheKey != null) _markerAnnotationCache[cacheKey] = result;
    return result;
  }

  /// Creates a [BitmapDescriptor] for a native marker annotation using
  /// pre-rendered PNG [glyphBytes] as the glyph image.
  ///
  /// Use this instead of [markerAnnotation] with a [glyphWidget] when you
  /// already have PNG bytes (e.g. rendered via [dart:ui.PictureRecorder]).
  /// This bypasses the headless widget pipeline entirely, avoiding frame-timing
  /// issues that can occur when [markerAnnotation] is called during a Flutter
  /// build/paint phase.
  static BitmapDescriptor markerAnnotationFromBytes(
    Uint8List glyphBytes, {
    double? hue,
  }) {
    if (hue != null) {
      assert(0.0 <= hue && hue < 360.0, 'hue must be in [0, 360)');
    }
    final double? iosHue = hue != null ? hue / 360.0 : null;
    return iosHue != null
        ? BitmapDescriptor._(<dynamic>['markerAnnotation', iosHue, glyphBytes])
        : BitmapDescriptor._(<dynamic>['markerAnnotation', glyphBytes]);
  }

  /// Renders [widget] off-screen to a PNG.
  ///
  /// Uses Flutter's headless rendering pipeline so no `BuildContext` is
  /// required. The result is suitable for use as a marker glyph image.
  static Future<Uint8List> _renderWidgetToBytes(
    Widget widget, {
    required Size logicalSize,
  }) async {
    final double devicePixelRatio =
        WidgetsBinding.instance.renderViews.isNotEmpty
        ? WidgetsBinding
              .instance
              .renderViews
              .first
              .configuration
              .devicePixelRatio
        : 1.0;

    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
    final PipelineOwner pipelineOwner = PipelineOwner();

    // Attach before building the widget tree so that child render objects have
    // an owner when they first call markNeedsPaint(). If attach comes after
    // attachToRenderTree, _needsPaint is set to true on children but they are
    // never added to _nodesNeedingPaint (no owner yet), so flushPaint() misses
    // them and toImage() fails the !debugNeedsPaint assertion.
    repaintBoundary.attach(pipelineOwner);

    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());
    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: MediaQueryData(devicePixelRatio: devicePixelRatio),
          child: SizedBox.fromSize(size: logicalSize, child: widget),
        ),
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    // Pump the event loop to allow async image providers (Image.asset,
    // Image.memory, Image.network, etc.) to load. Image loading involves
    // rootBundle.load (IO event) + codec decode (compute isolate), both of
    // which need event-loop cycles to complete. We rebuild after each pump to
    // flush the dirty _ImageState elements created by their setState calls.
    for (var i = 0; i < 10; i++) {
      if (PaintingBinding.instance.imageCache.pendingImageCount == 0) break;
      await Future.delayed(const Duration(milliseconds: 5));
      buildOwner.buildScope(rootElement);
      buildOwner.finalizeTree();
    }
    // One final rebuild to flush any dirty elements settled after the loop.
    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    repaintBoundary.layout(
      BoxConstraints.tight(logicalSize),
      parentUsesSize: false,
    );
    pipelineOwner.flushCompositingBits();

    // Use repaintCompositedChild rather than pipelineOwner.flushPaint().
    // In a headless PipelineOwner the OffsetLayer is never attached to a real
    // scene, so flushPaint() calls _skippedPaintingOnLayer() and silently skips
    // the node.  debugAlsoPaintedParent: true suppresses the debug assertion
    // that requires the layer to be attached, which is not meaningful here.
    PaintingContext.repaintCompositedChild(repaintBoundary, debugAlsoPaintedParent: true);

    final ui.Image image = await repaintBoundary.toImage(
      pixelRatio: devicePixelRatio,
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }

  /// Creates a BitmapDescriptor that refers to a colorization of the default/Pin
  /// annotation image. For convenience, there is a predefined set of hue values.
  /// See e.g. [hueCyan].
  static BitmapDescriptor defaultAnnotationWithHue(double hue) {
    assert(0.0 <= hue && hue < 360.0);
    double iosCompatibleHue = hue / 360.0;
    return BitmapDescriptor._(<dynamic>['defaultAnnotation', iosCompatibleHue]);
  }

  /// Creates a [BitmapDescriptor] from an asset image.
  ///
  /// Asset images in flutter are stored per:
  /// https://flutter.dev/docs/development/ui/assets-and-images#declaring-resolution-aware-image-assets
  /// This method takes into consideration various asset resolutions
  /// and scales the images to the right resolution depending on the dpi.
  static Future<BitmapDescriptor> fromAssetImage(
    ImageConfiguration configuration,
    String assetName, {
    AssetBundle? bundle,
    String? package,
    bool mipmaps = true,
  }) async {
    if (!mipmaps && configuration.devicePixelRatio != null) {
      return BitmapDescriptor._(<dynamic>[
        'fromAssetImage',
        assetName,
        configuration.devicePixelRatio,
      ]);
    }
    final AssetImage assetImage = AssetImage(
      assetName,
      package: package,
      bundle: bundle,
    );
    final AssetBundleImageKey assetBundleImageKey = await assetImage.obtainKey(
      configuration,
    );
    return BitmapDescriptor._(<dynamic>[
      'fromAssetImage',
      assetBundleImageKey.name,
      assetBundleImageKey.scale,
    ]);
  }

  /// Creates a BitmapDescriptor using an array of bytes that must be encoded
  /// as PNG.
  static BitmapDescriptor fromBytes(Uint8List byteData) {
    return BitmapDescriptor._(<dynamic>['fromBytes', byteData]);
  }

  final dynamic _json;

  dynamic _toJson() => _json;
}
