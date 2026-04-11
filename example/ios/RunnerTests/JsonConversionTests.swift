// Tests that pin the behaviour of PlatformMapOptions.fromCreationDictionary(_:),
// which is the creation-params boundary between the Dart StandardMessageCodec
// payload and the typed Swift plugin surface.
//
// fromCreationDictionary is the only path that cannot be replaced by Pigeon
// because the Pigeon host channel does not yet exist when the platform view's
// init runs. These tests prevent key-name drift, encoding regressions, and
// edge-case omissions from going undetected.

import XCTest

@testable import apple_maps_flutter

// MARK: - Helpers

private typealias Dict = [String: Any]

// MARK: - Tests

final class JsonConversionTests: XCTestCase {

    // -------------------------------------------------------------------------
    // MARK: Bool fields
    // -------------------------------------------------------------------------

    func testBoolFields_allTrue() {
        let dict: Dict = [
            "compassEnabled": true,
            "trafficEnabled": true,
            "rotateGesturesEnabled": true,
            "scrollGesturesEnabled": true,
            "pitchGesturesEnabled": true,
            "zoomGesturesEnabled": true,
            "myLocationEnabled": true,
            "myLocationButtonEnabled": true,
            "buildingsEnabled": true,
            "pointsOfInterestEnabled": true,
            "scaleEnabled": true,
            "insetsLayoutMarginsFromSafeArea": true,
        ]
        let opts = PlatformMapOptions.fromCreationDictionary(dict)
        XCTAssertEqual(opts.compassEnabled, true)
        XCTAssertEqual(opts.trafficEnabled, true)
        XCTAssertEqual(opts.rotateGesturesEnabled, true)
        XCTAssertEqual(opts.scrollGesturesEnabled, true)
        XCTAssertEqual(opts.pitchGesturesEnabled, true)
        XCTAssertEqual(opts.zoomGesturesEnabled, true)
        XCTAssertEqual(opts.myLocationEnabled, true)
        XCTAssertEqual(opts.myLocationButtonEnabled, true)
        XCTAssertEqual(opts.buildingsEnabled, true)
        XCTAssertEqual(opts.pointsOfInterestEnabled, true)
        XCTAssertEqual(opts.scaleEnabled, true)
        XCTAssertEqual(opts.insetsLayoutMarginsFromSafeArea, true)
    }

    func testBoolFields_allFalse() {
        let dict: Dict = [
            "compassEnabled": false,
            "trafficEnabled": false,
            "rotateGesturesEnabled": false,
            "scrollGesturesEnabled": false,
            "pitchGesturesEnabled": false,
            "zoomGesturesEnabled": false,
            "myLocationEnabled": false,
            "myLocationButtonEnabled": false,
            "buildingsEnabled": false,
            "pointsOfInterestEnabled": false,
            "scaleEnabled": false,
            "insetsLayoutMarginsFromSafeArea": false,
        ]
        let opts = PlatformMapOptions.fromCreationDictionary(dict)
        XCTAssertEqual(opts.compassEnabled, false)
        XCTAssertEqual(opts.trafficEnabled, false)
        XCTAssertEqual(opts.rotateGesturesEnabled, false)
        XCTAssertEqual(opts.scrollGesturesEnabled, false)
        XCTAssertEqual(opts.pitchGesturesEnabled, false)
        XCTAssertEqual(opts.zoomGesturesEnabled, false)
        XCTAssertEqual(opts.myLocationEnabled, false)
        XCTAssertEqual(opts.myLocationButtonEnabled, false)
        XCTAssertEqual(opts.buildingsEnabled, false)
        XCTAssertEqual(opts.pointsOfInterestEnabled, false)
        XCTAssertEqual(opts.scaleEnabled, false)
        XCTAssertEqual(opts.insetsLayoutMarginsFromSafeArea, false)
    }

    func testBoolFields_absentYieldsNil() {
        let opts = PlatformMapOptions.fromCreationDictionary([:])
        XCTAssertNil(opts.compassEnabled)
        XCTAssertNil(opts.trafficEnabled)
        XCTAssertNil(opts.rotateGesturesEnabled)
        XCTAssertNil(opts.scrollGesturesEnabled)
        XCTAssertNil(opts.pitchGesturesEnabled)
        XCTAssertNil(opts.zoomGesturesEnabled)
        XCTAssertNil(opts.myLocationEnabled)
        XCTAssertNil(opts.myLocationButtonEnabled)
        XCTAssertNil(opts.buildingsEnabled)
        XCTAssertNil(opts.pointsOfInterestEnabled)
        XCTAssertNil(opts.scaleEnabled)
        XCTAssertNil(opts.insetsLayoutMarginsFromSafeArea)
    }

    // -------------------------------------------------------------------------
    // MARK: mapType
    // -------------------------------------------------------------------------

    func testMapType_standard() {
        let opts = PlatformMapOptions.fromCreationDictionary(["mapType": 0])
        XCTAssertEqual(opts.mapType, 0)
    }

    func testMapType_satellite() {
        let opts = PlatformMapOptions.fromCreationDictionary(["mapType": 1])
        XCTAssertEqual(opts.mapType, 1)
    }

    func testMapType_hybrid() {
        let opts = PlatformMapOptions.fromCreationDictionary(["mapType": 2])
        XCTAssertEqual(opts.mapType, 2)
    }

    func testMapType_absent_yieldsNil() {
        let opts = PlatformMapOptions.fromCreationDictionary([:])
        XCTAssertNil(opts.mapType)
    }

    func testMapType_wrongType_yieldsNil() {
        // Guard against a Dart-side regression that sends a String.
        let opts = PlatformMapOptions.fromCreationDictionary(["mapType": "standard"])
        XCTAssertNil(opts.mapType)
    }

    // -------------------------------------------------------------------------
    // MARK: trackingMode
    // -------------------------------------------------------------------------

    func testTrackingMode_none() {
        let opts = PlatformMapOptions.fromCreationDictionary(["trackingMode": 0])
        XCTAssertEqual(opts.trackingMode, 0)
    }

    func testTrackingMode_follow() {
        let opts = PlatformMapOptions.fromCreationDictionary(["trackingMode": 1])
        XCTAssertEqual(opts.trackingMode, 1)
    }

    func testTrackingMode_followWithHeading() {
        let opts = PlatformMapOptions.fromCreationDictionary(["trackingMode": 2])
        XCTAssertEqual(opts.trackingMode, 2)
    }

    func testTrackingMode_absent_yieldsNil() {
        let opts = PlatformMapOptions.fromCreationDictionary([:])
        XCTAssertNil(opts.trackingMode)
    }

    // -------------------------------------------------------------------------
    // MARK: minMaxZoomPreference
    // -------------------------------------------------------------------------

    func testMinMaxZoom_boundedValues() {
        let opts = PlatformMapOptions.fromCreationDictionary([
            "minMaxZoomPreference": [2.0, 14.0] as [Any]
        ])
        XCTAssertNotNil(opts.minMaxZoomPreference)
        XCTAssertEqual(opts.minMaxZoomPreference?.minZoom, 2.0)
        XCTAssertEqual(opts.minMaxZoomPreference?.maxZoom, 14.0)
    }

    func testMinMaxZoom_unbounded_bothNulls() {
        // Dart's MinMaxZoomPreference.unbounded encodes as [null, null].
        let opts = PlatformMapOptions.fromCreationDictionary([
            "minMaxZoomPreference": [NSNull(), NSNull()] as [Any]
        ])
        XCTAssertNotNil(opts.minMaxZoomPreference)
        XCTAssertNil(opts.minMaxZoomPreference?.minZoom)
        XCTAssertNil(opts.minMaxZoomPreference?.maxZoom)
    }

    func testMinMaxZoom_minNullMaxPresent() {
        let opts = PlatformMapOptions.fromCreationDictionary([
            "minMaxZoomPreference": [NSNull(), 18.0] as [Any]
        ])
        XCTAssertNil(opts.minMaxZoomPreference?.minZoom)
        XCTAssertEqual(opts.minMaxZoomPreference?.maxZoom, 18.0)
    }

    func testMinMaxZoom_maxNullMinPresent() {
        // Symmetric case: only the max end is unbounded.
        let opts = PlatformMapOptions.fromCreationDictionary([
            "minMaxZoomPreference": [2.0, NSNull()] as [Any]
        ])
        XCTAssertEqual(opts.minMaxZoomPreference?.minZoom, 2.0)
        XCTAssertNil(opts.minMaxZoomPreference?.maxZoom)
    }

    func testMinMaxZoom_absent_yieldsNil() {
        let opts = PlatformMapOptions.fromCreationDictionary([:])
        XCTAssertNil(opts.minMaxZoomPreference)
    }

    func testMinMaxZoom_emptyList_yieldsNil() {
        // Malformed: list shorter than 2 elements must not crash.
        let opts = PlatformMapOptions.fromCreationDictionary([
            "minMaxZoomPreference": [] as [Any]
        ])
        XCTAssertNil(opts.minMaxZoomPreference)
    }

    // -------------------------------------------------------------------------
    // MARK: padding
    // -------------------------------------------------------------------------

    func testPadding_explicitValues() {
        let opts = PlatformMapOptions.fromCreationDictionary([
            // Dart encodes as [top, left, bottom, right].
            "padding": [8.0, 4.0, 16.0, 12.0] as [Any]
        ])
        XCTAssertNotNil(opts.padding)
        XCTAssertEqual(opts.padding?.top, 8.0)
        XCTAssertEqual(opts.padding?.left, 4.0)
        XCTAssertEqual(opts.padding?.bottom, 16.0)
        XCTAssertEqual(opts.padding?.right, 12.0)
    }

    func testPadding_zeroes() {
        // Default AppleMap sends [0, 0, 0, 0].
        let opts = PlatformMapOptions.fromCreationDictionary([
            "padding": [0.0, 0.0, 0.0, 0.0] as [Any]
        ])
        XCTAssertNotNil(opts.padding)
        XCTAssertEqual(opts.padding?.top, 0.0)
        XCTAssertEqual(opts.padding?.left, 0.0)
        XCTAssertEqual(opts.padding?.bottom, 0.0)
        XCTAssertEqual(opts.padding?.right, 0.0)
    }

    func testPadding_absent_yieldsNil() {
        let opts = PlatformMapOptions.fromCreationDictionary([:])
        XCTAssertNil(opts.padding)
    }

    func testPadding_tooShort_yieldsNil() {
        // Malformed list must not crash; the field is left nil.
        let opts = PlatformMapOptions.fromCreationDictionary([
            "padding": [1.0, 2.0] as [Any]
        ])
        XCTAssertNil(opts.padding)
    }

    // -------------------------------------------------------------------------
    // MARK: cameraTargetBounds
    // -------------------------------------------------------------------------

    func testCameraTargetBounds_keyAbsent_yieldsNil() {
        // When the key is absent the field must stay nil (no change).
        let opts = PlatformMapOptions.fromCreationDictionary([:])
        XCTAssertNil(opts.cameraTargetBounds)
    }

    func testCameraTargetBounds_nsNull_yieldsUnboundedBounds() {
        // Dart sends NSNull when the bounds are unbounded.
        let opts = PlatformMapOptions.fromCreationDictionary([
            "cameraTargetBounds": NSNull()
        ])
        XCTAssertNotNil(opts.cameraTargetBounds)
        XCTAssertNil(opts.cameraTargetBounds?.bounds)
    }

    func testCameraTargetBounds_flatList_parsesSouthwestNortheast() {
        let opts = PlatformMapOptions.fromCreationDictionary([
            // [swLat, swLng, neLat, neLng]
            "cameraTargetBounds": [10.0, 20.0, 30.0, 40.0] as [Double]
        ])
        let bounds = opts.cameraTargetBounds?.bounds
        XCTAssertNotNil(bounds)
        XCTAssertEqual(bounds?.southwest.latitude, 10.0)
        XCTAssertEqual(bounds?.southwest.longitude, 20.0)
        XCTAssertEqual(bounds?.northeast.latitude, 30.0)
        XCTAssertEqual(bounds?.northeast.longitude, 40.0)
    }

    func testCameraTargetBounds_malformedList_yieldsNilBoundsObject() {
        // A list shorter than 4 doubles is malformed. The contract:
        // cameraTargetBounds stays nil (treated as "no change") rather than
        // crashing or producing a partial bounds object.
        let opts = PlatformMapOptions.fromCreationDictionary([
            "cameraTargetBounds": [10.0, 20.0] as [Double]
        ])
        XCTAssertNil(opts.cameraTargetBounds)
    }

    // -------------------------------------------------------------------------
    // MARK: emphasisStyle
    // -------------------------------------------------------------------------

    func testEmphasisStyle_defaultStyle() {
        let opts = PlatformMapOptions.fromCreationDictionary(["emphasisStyle": 0])
        XCTAssertEqual(opts.emphasisStyle, .defaultStyle)
    }

    func testEmphasisStyle_muted() {
        let opts = PlatformMapOptions.fromCreationDictionary(["emphasisStyle": 1])
        XCTAssertEqual(opts.emphasisStyle, .muted)
    }

    func testEmphasisStyle_absent_yieldsNil() {
        let opts = PlatformMapOptions.fromCreationDictionary([:])
        XCTAssertNil(opts.emphasisStyle)
    }

    func testEmphasisStyle_outOfRange_fallsBackToDefault() {
        // Unknown raw value must fall back to defaultStyle rather than crash.
        let opts = PlatformMapOptions.fromCreationDictionary(["emphasisStyle": 99])
        XCTAssertEqual(opts.emphasisStyle, .defaultStyle)
    }

    func testEmphasisStyle_wrongType_yieldsNil() {
        // Guard against a Dart-side regression that sends a String instead of Int.
        let opts = PlatformMapOptions.fromCreationDictionary(["emphasisStyle": "muted"])
        XCTAssertNil(opts.emphasisStyle)
    }

    // -------------------------------------------------------------------------
    // MARK: selectableFeatures bitmask
    // -------------------------------------------------------------------------

    func testSelectableFeatures_poi() {
        let opts = PlatformMapOptions.fromCreationDictionary(["selectableFeatures": 1])
        XCTAssertEqual(opts.selectableFeatures, 1)
    }

    func testSelectableFeatures_territories() {
        let opts = PlatformMapOptions.fromCreationDictionary(["selectableFeatures": 2])
        XCTAssertEqual(opts.selectableFeatures, 2)
    }

    func testSelectableFeatures_physicalFeatures() {
        let opts = PlatformMapOptions.fromCreationDictionary(["selectableFeatures": 4])
        XCTAssertEqual(opts.selectableFeatures, 4)
    }

    func testSelectableFeatures_allThree() {
        let opts = PlatformMapOptions.fromCreationDictionary(["selectableFeatures": 7])
        XCTAssertEqual(opts.selectableFeatures, 7)
    }

    func testSelectableFeatures_empty() {
        let opts = PlatformMapOptions.fromCreationDictionary(["selectableFeatures": 0])
        XCTAssertEqual(opts.selectableFeatures, 0)
    }

    func testSelectableFeatures_absent_yieldsNil() {
        let opts = PlatformMapOptions.fromCreationDictionary([:])
        XCTAssertNil(opts.selectableFeatures)
    }

    // -------------------------------------------------------------------------
    // MARK: Roundtrip preservation sanity-check
    //
    // These tests verify that a fully-specified creation dict produces a
    // PlatformMapOptions whose fields all match the input. This acts as a
    // catch-all for key-name regressions between Dart and Swift.
    // -------------------------------------------------------------------------

    func testFullCreationDict_allFieldsParsedCorrectly() {
        let dict: Dict = [
            "compassEnabled": true,
            "trafficEnabled": false,
            "mapType": 2,
            "minMaxZoomPreference": [3.0, 18.0] as [Any],
            "rotateGesturesEnabled": true,
            "scrollGesturesEnabled": true,
            "pitchGesturesEnabled": false,
            "trackingMode": 1,
            "zoomGesturesEnabled": true,
            "myLocationEnabled": false,
            "myLocationButtonEnabled": true,
            "padding": [8.0, 4.0, 16.0, 12.0] as [Any],
            "insetsLayoutMarginsFromSafeArea": true,
            "cameraTargetBounds": [10.0, 20.0, 30.0, 40.0] as [Double],
            "buildingsEnabled": true,
            "pointsOfInterestEnabled": false,
            "scaleEnabled": true,
            "emphasisStyle": 1,
            "selectableFeatures": 3,
        ]
        let opts = PlatformMapOptions.fromCreationDictionary(dict)

        XCTAssertEqual(opts.compassEnabled, true)
        XCTAssertEqual(opts.trafficEnabled, false)
        XCTAssertEqual(opts.mapType, 2)
        XCTAssertEqual(opts.minMaxZoomPreference?.minZoom, 3.0)
        XCTAssertEqual(opts.minMaxZoomPreference?.maxZoom, 18.0)
        XCTAssertEqual(opts.rotateGesturesEnabled, true)
        XCTAssertEqual(opts.scrollGesturesEnabled, true)
        XCTAssertEqual(opts.pitchGesturesEnabled, false)
        XCTAssertEqual(opts.trackingMode, 1)
        XCTAssertEqual(opts.zoomGesturesEnabled, true)
        XCTAssertEqual(opts.myLocationEnabled, false)
        XCTAssertEqual(opts.myLocationButtonEnabled, true)
        XCTAssertEqual(opts.padding?.top, 8.0)
        XCTAssertEqual(opts.padding?.left, 4.0)
        XCTAssertEqual(opts.padding?.bottom, 16.0)
        XCTAssertEqual(opts.padding?.right, 12.0)
        XCTAssertEqual(opts.insetsLayoutMarginsFromSafeArea, true)
        XCTAssertEqual(opts.cameraTargetBounds?.bounds?.southwest.latitude, 10.0)
        XCTAssertEqual(opts.cameraTargetBounds?.bounds?.northeast.longitude, 40.0)
        XCTAssertEqual(opts.buildingsEnabled, true)
        XCTAssertEqual(opts.pointsOfInterestEnabled, false)
        XCTAssertEqual(opts.scaleEnabled, true)
        XCTAssertEqual(opts.emphasisStyle, .muted)
        XCTAssertEqual(opts.selectableFeatures, 3)
    }

    func testEmptyDict_allFieldsAreNil() {
        let opts = PlatformMapOptions.fromCreationDictionary([:])

        XCTAssertNil(opts.compassEnabled)
        XCTAssertNil(opts.trafficEnabled)
        XCTAssertNil(opts.mapType)
        XCTAssertNil(opts.minMaxZoomPreference)
        XCTAssertNil(opts.rotateGesturesEnabled)
        XCTAssertNil(opts.scrollGesturesEnabled)
        XCTAssertNil(opts.pitchGesturesEnabled)
        XCTAssertNil(opts.trackingMode)
        XCTAssertNil(opts.zoomGesturesEnabled)
        XCTAssertNil(opts.myLocationEnabled)
        XCTAssertNil(opts.myLocationButtonEnabled)
        XCTAssertNil(opts.padding)
        XCTAssertNil(opts.insetsLayoutMarginsFromSafeArea)
        XCTAssertNil(opts.cameraTargetBounds)
        XCTAssertNil(opts.buildingsEnabled)
        XCTAssertNil(opts.pointsOfInterestEnabled)
        XCTAssertNil(opts.scaleEnabled)
        XCTAssertNil(opts.emphasisStyle)
        XCTAssertNil(opts.selectableFeatures)
    }
}
