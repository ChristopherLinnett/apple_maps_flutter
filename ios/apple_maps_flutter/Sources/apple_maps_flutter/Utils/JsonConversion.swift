//
//  JsonConversion.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 26.11.19.
//

import Foundation
import Flutter
import MapKit

class JsonConversions {
    
    static func convertLocation(data: Any?) -> CLLocationCoordinate2D? {
        if let updatedPosition = data as? Array<CLLocationDegrees> {
            let lat: Double = updatedPosition[0]
            let lon: Double = updatedPosition[1]

            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }

    static func convertColor(data: Any?) -> UIColor? {
        if let value = data as? CUnsignedLong {
            return UIColor(red: CGFloat(Float(((value & 0xFF0000) >> 16)) / 255.0),
                           green: CGFloat(Float(((value & 0xFF00) >> 8)) / 255.0),
                           blue: CGFloat(Float(((value & 0xFF))) / 255.0),
                           alpha: CGFloat(Float(((value & 0xFF000000) >> 24)) / 255.0)
            )
        }
        return nil
    }
}

private func nullOrValue(_ value: Any?) -> Any {
    return value ?? NSNull()
}

private func foundationArray<T>(_ values: [T]?) -> NSArray? {
    guard let values, !values.isEmpty else {
        return nil
    }
    return values as NSArray
}

struct LegacyAnnotationUpdates {
    let annotationsToAdd: NSArray?
    let annotationsToChange: NSArray?
    let annotationIdsToRemove: NSArray?
}

struct LegacyPolylineUpdates {
    let polylinesToAdd: NSArray?
    let polylinesToChange: NSArray?
    let polylineIdsToRemove: NSArray?
}

struct LegacyPolygonUpdates {
    let polygonsToAdd: NSArray?
    let polygonsToChange: NSArray?
    let polygonIdsToRemove: NSArray?
}

struct LegacyCircleUpdates {
    let circlesToAdd: NSArray?
    let circlesToChange: NSArray?
    let circleIdsToRemove: NSArray?
}

extension PlatformOffset {
    var asList: [Double] {
        [x, y]
    }
}

extension PlatformLatLng {
    var asCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var asList: [Double] {
        [latitude, longitude]
    }
}

extension PlatformLatLngBounds {
    var asTargetList: [[Double]] {
        [southwest.asList, northeast.asList]
    }
}

extension PlatformCameraPosition {
    var asDictionary: [String: Any] {
        [
            "target": target.asList,
            "heading": heading,
            "pitch": pitch,
            "zoom": zoom,
        ]
    }
}

extension PlatformMapOptions {
    /// Parses the `[String: Any]` dictionary delivered via `StandardMessageCodec` from the
    /// Flutter platform-view creation params into a typed `PlatformMapOptions`.
    ///
    /// Key names and encoding match `_AppleMapOptions.toMap()` in the Dart package.
    /// `cameraTargetBounds` is encoded as a flat `[Double]` list `[swLat, swLng, neLat, neLng]`
    /// or `null` when unbounded. All other list fields use the same format as the Pigeon path.
    /// This factory is the creation-path boundary only; Pigeon handles the update path directly.
    static func fromCreationDictionary(_ dict: [String: Any]) -> PlatformMapOptions {
        var options = PlatformMapOptions()

        options.compassEnabled = dict["compassEnabled"] as? Bool
        options.trafficEnabled = dict["trafficEnabled"] as? Bool

        if let mapType = dict["mapType"] as? Int {
            options.mapType = Int64(mapType)
        }

        if let minMaxZoom = dict["minMaxZoomPreference"] as? [Any], minMaxZoom.count >= 2 {
            options.minMaxZoomPreference = PlatformMinMaxZoomPreference(
                minZoom: minMaxZoom[0] as? Double,
                maxZoom: minMaxZoom[1] as? Double
            )
        }

        options.rotateGesturesEnabled = dict["rotateGesturesEnabled"] as? Bool
        options.scrollGesturesEnabled = dict["scrollGesturesEnabled"] as? Bool
        options.pitchGesturesEnabled = dict["pitchGesturesEnabled"] as? Bool

        if let trackingMode = dict["trackingMode"] as? Int {
            options.trackingMode = Int64(trackingMode)
        }

        options.zoomGesturesEnabled = dict["zoomGesturesEnabled"] as? Bool
        options.myLocationEnabled = dict["myLocationEnabled"] as? Bool
        options.myLocationButtonEnabled = dict["myLocationButtonEnabled"] as? Bool

        if let padding = dict["padding"] as? [Any], padding.count >= 4 {
            options.padding = PlatformPadding(
                top: padding[0] as? Double ?? 0.0,
                left: padding[1] as? Double ?? 0.0,
                bottom: padding[2] as? Double ?? 0.0,
                right: padding[3] as? Double ?? 0.0
            )
        }

        options.insetsLayoutMarginsFromSafeArea = dict["insetsLayoutMarginsFromSafeArea"] as? Bool

        // Dart encodes cameraTargetBounds as a flat [swLat, swLng, neLat, neLng] list or null.
        // The key is always present in the creation dict so the presence check is key-based.
        if dict.keys.contains("cameraTargetBounds") {
            let rawBounds = dict["cameraTargetBounds"]
            if rawBounds is NSNull {
                // Dart explicitly sent null → unbounded camera.
                options.cameraTargetBounds = PlatformCameraTargetBounds(bounds: nil)
            } else if let flat = rawBounds as? [Double], flat.count == 4 {
                options.cameraTargetBounds = PlatformCameraTargetBounds(
                    bounds: PlatformLatLngBounds(
                        southwest: PlatformLatLng(latitude: flat[0], longitude: flat[1]),
                        northeast: PlatformLatLng(latitude: flat[2], longitude: flat[3])
                    )
                )
            }
            // else: malformed data — leave cameraTargetBounds nil (treat as no change).
        }

        options.buildingsEnabled = dict["buildingsEnabled"] as? Bool
        options.pointsOfInterestEnabled = dict["pointsOfInterestEnabled"] as? Bool
        options.scaleEnabled = dict["scaleEnabled"] as? Bool

        if let emphasisStyleRaw = dict["emphasisStyle"] as? Int {
            options.emphasisStyle = PlatformMapEmphasisStyle(rawValue: emphasisStyleRaw) ?? .defaultStyle
        }

        if let selectableFeatures = dict["selectableFeatures"] as? Int {
            options.selectableFeatures = Int64(selectableFeatures)
        }

        return options
    }
}

extension PlatformInfoWindow {
    var asDictionary: [String: Any] {
        var infoWindow: [String: Any] = [
            "consumesTapEvents": consumesTapEvents,
        ]

        if let title {
            infoWindow["title"] = title
        }
        if let snippet {
            infoWindow["snippet"] = snippet
        }
        if let anchor {
            infoWindow["anchor"] = anchor.asList
        }

        return infoWindow
    }
}

extension BitmapDescriptorType {
    var identifier: String {
        switch self {
        case .defaultAnnotation:
            return "defaultAnnotation"
        case .markerAnnotation:
            return "markerAnnotation"
        case .fromAssetImage:
            return "fromAssetImage"
        case .fromBytes:
            return "fromBytes"
        }
    }
}

extension PlatformBitmapDescriptor {
    var asList: [Any] {
        var iconData: [Any] = [type.identifier]

        switch type {
        case .defaultAnnotation, .markerAnnotation:
            if let hue {
                iconData.append(hue)
            }
        case .fromAssetImage:
            if let assetName {
                iconData.append(assetName)
            }
            iconData.append(assetScale ?? 1.0)
        case .fromBytes:
            if let bytes {
                iconData.append(bytes)
            }
        }

        return iconData
    }
}

extension PlatformAnnotation {
    var asDictionary: [String: Any] {
        var dict: [String: Any] = [
            "annotationId": annotationId,
            "alpha": alpha,
            "anchor": anchor.asList,
            "draggable": draggable,
            "icon": icon.asList,
            "infoWindow": infoWindow.asDictionary,
            "visible": visible,
            "position": position.asList,
            "zIndex": zIndex,
        ]
        if let id = clusteringIdentifier {
            dict["clusteringIdentifier"] = id
        }
        return dict
    }
}

extension PlatformAnnotationUpdates {
    var asLegacyUpdates: LegacyAnnotationUpdates {
        LegacyAnnotationUpdates(
            annotationsToAdd: foundationArray(annotationsToAdd?.map(\.asDictionary)),
            annotationsToChange: foundationArray(annotationsToChange?.map(\.asDictionary)),
            annotationIdsToRemove: foundationArray(annotationIdsToRemove)
        )
    }
}

extension PatternItemType {
    var identifier: String {
        switch self {
        case .dot:
            return "dot"
        case .dash:
            return "dash"
        case .gap:
            return "gap"
        }
    }
}

extension PlatformPatternItem {
    var asList: [Any] {
        if let length {
            return [type.identifier, length]
        }
        return [type.identifier]
    }
}

extension CapType {
    var identifier: String {
        switch self {
        case .buttCap:
            return "buttCap"
        case .roundCap:
            return "roundCap"
        case .squareCap:
            return "squareCap"
        }
    }
}

extension PlatformPolyline {
    var asDictionary: [String: Any] {
        [
            "polylineId": polylineId,
            "consumeTapEvents": consumeTapEvents,
            "color": Int(color),
            "polylineCap": polylineCap.identifier,
            "jointType": Int(jointType),
            "visible": visible,
            "width": Int(width),
            "zIndex": nullOrValue(zIndex.map { Int($0) }),
            "points": points.map(\.asList),
            "pattern": patterns.map(\.asList),
        ]
    }
}

extension PlatformPolylineUpdates {
    var asLegacyUpdates: LegacyPolylineUpdates {
        LegacyPolylineUpdates(
            polylinesToAdd: foundationArray(polylinesToAdd?.map(\.asDictionary)),
            polylinesToChange: foundationArray(polylinesToChange?.map(\.asDictionary)),
            polylineIdsToRemove: foundationArray(polylineIdsToRemove)
        )
    }
}

extension PlatformPolygon {
    var asDictionary: [String: Any] {
        [
            "polygonId": polygonId,
            "consumeTapEvents": consumeTapEvents,
            "fillColor": Int(fillColor),
            "points": points.map(\.asList),
            "strokeColor": Int(strokeColor),
            "strokeWidth": Int(strokeWidth),
            "visible": visible,
            "zIndex": nullOrValue(zIndex.map { Int($0) }),
        ]
    }
}

extension PlatformPolygonUpdates {
    var asLegacyUpdates: LegacyPolygonUpdates {
        LegacyPolygonUpdates(
            polygonsToAdd: foundationArray(polygonsToAdd?.map(\.asDictionary)),
            polygonsToChange: foundationArray(polygonsToChange?.map(\.asDictionary)),
            polygonIdsToRemove: foundationArray(polygonIdsToRemove)
        )
    }
}

extension PlatformCircle {
    var asDictionary: [String: Any] {
        [
            "circleId": circleId,
            "consumeTapEvents": consumeTapEvents,
            "fillColor": Int(fillColor),
            "center": center.asList,
            "radius": radius,
            "strokeColor": Int(strokeColor),
            "strokeWidth": Int(strokeWidth),
            "visible": visible,
            "zIndex": nullOrValue(zIndex.map { Int($0) }),
        ]
    }
}

extension PlatformCircleUpdates {
    var asLegacyUpdates: LegacyCircleUpdates {
        LegacyCircleUpdates(
            circlesToAdd: foundationArray(circlesToAdd?.map(\.asDictionary)),
            circlesToChange: foundationArray(circlesToChange?.map(\.asDictionary)),
            circleIdsToRemove: foundationArray(circleIdsToRemove)
        )
    }
}

extension PlatformSnapshotOptions {
    var asDictionary: [String: Any] {
        [
            "showBuildings": showBuildings,
            "showPointsOfInterest": showPointsOfInterest,
            "showAnnotations": showAnnotations,
            "showOverlays": showOverlays,
        ]
    }
}
