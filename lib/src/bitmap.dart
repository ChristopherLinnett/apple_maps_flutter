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

  /// Creates a [BitmapDescriptor] that uses the native Apple marker balloon
  /// (`MKMarkerAnnotationView`).
  ///
  /// [hue] tints the balloon body (0–359 degrees). When omitted the system
  /// default tint is used.
  ///
  /// [glyphWidget] is rendered off-screen to a PNG and placed as the small
  /// glyph image inside the balloon. [glyphSize] controls the logical pixel
  /// size of the rendered image (default 20×20).
  ///
  /// When neither argument is supplied this behaves the same as the old
  /// `BitmapDescriptor.markerAnnotation` constant — the default system balloon
  /// with no tint override.
  static Future<BitmapDescriptor> markerAnnotation({
    Widget? glyphWidget,
    Size glyphSize = const Size(20, 20),
    double? hue,
  }) async {
    if (hue != null) {
      assert(0.0 <= hue && hue < 360.0, 'hue must be in [0, 360)');
    }
    final double? iosHue = hue != null ? hue / 360.0 : null;

    if (glyphWidget != null) {
      final Uint8List bytes = await _renderWidgetToBytes(
        glyphWidget,
        logicalSize: glyphSize,
      );
      // Encoding: ['markerAnnotation', iosHue?, glyphBytes]
      // When iosHue is null we omit it so the list stays compact.
      return iosHue != null
          ? BitmapDescriptor._(<dynamic>['markerAnnotation', iosHue, bytes])
          : BitmapDescriptor._(<dynamic>['markerAnnotation', bytes]);
    }

    if (iosHue != null) {
      return BitmapDescriptor._(<dynamic>['markerAnnotation', iosHue]);
    }
    return BitmapDescriptor._(<dynamic>['markerAnnotation']);
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
            ? WidgetsBinding.instance.renderViews.first.configuration
                .devicePixelRatio
            : 1.0;

    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
    final PipelineOwner pipelineOwner = PipelineOwner();

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

    repaintBoundary.attach(pipelineOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    repaintBoundary.layout(
      BoxConstraints.tight(logicalSize),
      parentUsesSize: false,
    );
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

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
