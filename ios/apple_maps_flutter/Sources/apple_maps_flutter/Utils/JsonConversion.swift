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
    var asDictionary: [String: Any] {
        var options: [String: Any] = [:]

        if let compassEnabled {
            options["compassEnabled"] = compassEnabled
        }
        if let trafficEnabled {
            options["trafficEnabled"] = trafficEnabled
        }
        if let mapType {
            options["mapType"] = Int(mapType)
        }
        if let minMaxZoomPreference {
            options["minMaxZoomPreference"] = [
                nullOrValue(minMaxZoomPreference.minZoom),
                nullOrValue(minMaxZoomPreference.maxZoom),
            ]
        }
        if let rotateGesturesEnabled {
            options["rotateGesturesEnabled"] = rotateGesturesEnabled
        }
        if let scrollGesturesEnabled {
            options["scrollGesturesEnabled"] = scrollGesturesEnabled
        }
        if let pitchGesturesEnabled {
            options["pitchGesturesEnabled"] = pitchGesturesEnabled
        }
        if let trackingMode {
            options["trackingMode"] = Int(trackingMode)
        }
        if let zoomGesturesEnabled {
            options["zoomGesturesEnabled"] = zoomGesturesEnabled
        }
        if let myLocationEnabled {
            options["myLocationEnabled"] = myLocationEnabled
        }
        if let myLocationButtonEnabled {
            options["myLocationButtonEnabled"] = myLocationButtonEnabled
        }
        if let padding {
            options["padding"] = [padding.top, padding.left, padding.bottom, padding.right]
        }
        if let insetsLayoutMarginsFromSafeArea {
            options["insetsLayoutMarginsFromSafeArea"] = insetsLayoutMarginsFromSafeArea
        }
        if let cameraTargetBounds {
            if let bounds = cameraTargetBounds.bounds {
                options["cameraTargetBounds"] = bounds.asTargetList
            } else {
                options["cameraTargetBounds"] = NSNull()
            }
        }
        if let buildingsEnabled {
            options["buildingsEnabled"] = buildingsEnabled
        }
        if let pointsOfInterestEnabled {
            options["pointsOfInterestEnabled"] = pointsOfInterestEnabled
        }
        if let scaleEnabled {
            options["scaleEnabled"] = scaleEnabled
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
