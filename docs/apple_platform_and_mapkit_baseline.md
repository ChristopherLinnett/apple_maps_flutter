# Apple Platform and MapKit Baseline

Date: 2026-04-10

## Purpose

This document records the Apple-native baseline for `apple_maps_flutter` so future modernization work targets one consistent set of assumptions for toolchains, runtime support, packaging, and MapKit adoption.

This file is the package-facing summary of that baseline.

During the audit-driven modernization effort, the canonical planning artifact is `apple_maps_flutter_audit/00_apple_platform_and_mapkit_baseline/native_baseline.md` in the workspace audit pack. If the two documents ever diverge during active audit work, the audit artifact wins and this repo summary should be updated to match it.

## Maintenance Direction

This fork should be maintained as a production-ready Apple Maps plugin, not as a narrow compatibility-only fork.

That means future work should prioritize:

- current stable Flutter and Dart
- typed plugin transport instead of raw channel payload maps
- dual CocoaPods and Swift Package Manager support
- deliberate adoption of current MapKit configuration APIs
- stronger automated testing across Dart, integration, and native iOS layers

## Toolchain Baseline

### Flutter and Dart

- Flutter baseline: `3.41.x` stable
- Dart baseline: `3.11.x`
- Target package constraints for modernization work: Dart `^3.11.0`, Flutter `>=3.41.0`

### Xcode

- Active-maintenance baseline: latest stable Xcode supported by current stable Flutter and available on CI
- Do not preserve compatibility branches purely for historically old Xcode releases

This aligns with current Flutter iOS guidance, which expects contributors to use the latest Xcode line.

### Swift

- Swift language baseline: Swift `5.9` minimum
- New work may compile with newer Swift compilers, but should not require a newer language mode unless the baseline is deliberately raised in a later task

This aligns with Flutter's current Swift Package Manager guidance for plugin authors.

## Runtime Baseline

### Minimum Supported iOS

- Minimum iOS deployment target: `13.0`

Rationale:

- Flutter's current SwiftPM plugin-author guidance uses `.iOS("13.0")`
- this fork already relies on `MKMapView.cameraZoomRange`, which is iOS 13+
- keeping an iOS 9 floor preserves obsolete camera and UI fallback code that actively complicates modernization

### CI Runtime Policy

- Validate one minimum-supported simulator runtime: iOS `13.x`
- Validate one current simulator runtime from the active Xcode image

This document defines the policy; later tasks should implement it in CI.

## MapKit Capability Baseline

### Required baseline capabilities

These remain core responsibilities of the plugin:

- `MKMapView` embedding
- camera movement and visible-region behavior
- annotations, circles, polygons, and polylines
- user location and user tracking
- snapshot generation
- native min/max zoom enforcement on iOS 13+

### Modern configuration baseline

These APIs are the intended modern MapKit model for future feature work:

- `MKMapView.preferredConfiguration`
- `MKStandardMapConfiguration`
- `MKHybridMapConfiguration`
- `MKImageryMapConfiguration`
- traffic and point-of-interest configuration through configuration objects
- elevation and emphasis style controls

Availability:

- these configuration APIs are iOS `16+`

### Deferred modern Apple-only features

These are valuable but should be implemented after the lower-level modernization work is stable:

- `MKMapFeatureAnnotation`
- feature selection and place-detail flows
- Look Around and similar Apple-only discovery features

Availability:

- `MKMapFeatureAnnotation` is iOS `16+`

## Current Legacy Audit

The current codebase still contains legacy assumptions that should guide future refactors.

### Packaging

- `ios/apple_maps_flutter.podspec` still declares iOS `9.0`
- the podspec still uses placeholder metadata and `s.swift_version = '5.0'`
- there is no `Package.swift` and no SwiftPM-ready source layout

### CI and testing

- `.github/workflows/dart.yml` still installs Flutter `3.27.3`
- the example app still uses `flutter_driver`
- there is no minimum-runtime or SwiftPM validation matrix

### Documentation

- `README.md` still describes platform views as a preview
- `README.md` still instructs users to set `io.flutter.embedded_views_preview`

### Native implementation

- `ios/Classes/MapView/MapViewExtension.swift` stores camera state in a shared static `Holder`
- many `#available(iOS 9.0, *)` branches remain even though the intended runtime floor is now iOS 13
- the native plugin boundary still uses raw method-channel maps rather than typed transport

## Version-Gating Rules

Future tasks should follow these rules.

### Rule 1

- iOS 13 is the runtime floor for all new work
- do not add new compatibility branches for iOS 12 and earlier

### Rule 2

- iOS 16+ MapKit APIs must be gated explicitly
- any fallback behavior for iOS 13-15 must be documented and testable

### Rule 3

- do not expose a Dart capability unless the native side is actually wired
- avoid silent no-op behavior for materially new Apple-only features

### Rule 4

- preserve working behavior for existing public APIs on iOS 13-15 using the closest real MapKit equivalent
- for newly introduced Apple-native features, prefer explicit availability semantics over pretending parity exists on older systems

## Summary

The baseline for ongoing modernization is:

- Flutter `3.41.x`
- Dart `3.11.x`
- latest stable Xcode for active maintenance
- Swift `5.9` minimum
- iOS deployment target `13.0`
- explicit iOS 16 gating for modern MapKit configuration and feature-selection APIs
- dual CocoaPods and Swift Package Manager support