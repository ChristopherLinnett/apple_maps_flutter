//
//  MapViewExtension.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 22.09.19.
//

import Foundation
import UIKit
import MapKit
import ObjectiveC

public extension MKMapView {
    private final class MapCameraState {
        var zoomLevel: Double = 0
        var pitch: CGFloat = 0
        var heading: CLLocationDirection = 0
        var maxZoomLevel: Double = 21
        var minZoomLevel: Double = 2
    }

    private static var mapCameraStateKey: UInt8 = 0

    private var mapCameraState: MapCameraState {
        get {
            if let state = objc_getAssociatedObject(self, &Self.mapCameraStateKey) as? MapCameraState {
                return state
            }
            let state = MapCameraState()
            objc_setAssociatedObject(self, &Self.mapCameraStateKey, state, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return state
        }
        set {
            objc_setAssociatedObject(self, &Self.mapCameraStateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func resetStoredCameraState() {
        objc_setAssociatedObject(self, &Self.mapCameraStateKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    var maxZoomLevel: Double {
        set(_maxZoomLevel) {
            mapCameraState.maxZoomLevel = _maxZoomLevel
            if mapCameraState.zoomLevel > _maxZoomLevel {
                self.setCenterCoordinateWithAltitude(centerCoordinate: centerCoordinate, zoomLevel: _maxZoomLevel, animated: false)
            }
            self.applyCameraZoomRange()
        }
        get {
            return mapCameraState.maxZoomLevel
        }
    }
    
    var minZoomLevel: Double {
        set(_minZoomLevel) {
            mapCameraState.minZoomLevel = _minZoomLevel
            if mapCameraState.zoomLevel < _minZoomLevel {
                self.setCenterCoordinateWithAltitude(centerCoordinate: centerCoordinate, zoomLevel: _minZoomLevel, animated: false)
            }
            self.applyCameraZoomRange()
        }
        get {
              return mapCameraState.minZoomLevel
        }
    }
    
    var zoomLevel: Double {
        get {
            return mapCameraState.zoomLevel
        }
    }
    
    var calculatedZoomLevel: Double {
        get {
            let centerPixelSpaceX = Utils.longitudeToPixelSpaceX(longitude: self.centerCoordinate.longitude)

            let lonLeft = self.centerCoordinate.longitude - (self.region.span.longitudeDelta / 2)

            let leftPixelSpaceX = Utils.longitudeToPixelSpaceX(longitude: lonLeft)
            let pixelSpaceWidth = abs(centerPixelSpaceX - leftPixelSpaceX) * 2

            let zoomScale = pixelSpaceWidth / Double(self.bounds.size.width)

            let zoomExponent = Utils.logC(val: zoomScale, forBase: 2)

            var zoomLevel = 21 - zoomExponent
            
            zoomLevel = Utils.roundToTwoDecimalPlaces(number: zoomLevel)
            
            mapCameraState.zoomLevel = zoomLevel
            
            return zoomLevel
            
        }
        set (newZoomLevel) {
            mapCameraState.zoomLevel = newZoomLevel
        }
    }
    
    func setCenterCoordinate(_ positionData: Dictionary<String, Any>, animated: Bool) {
        let targetList :Array<CLLocationDegrees> = positionData["target"] as? Array<CLLocationDegrees> ?? [self.camera.centerCoordinate.latitude, self.camera.centerCoordinate.longitude]
        let zoom :Double = positionData["zoom"] as? Double ?? mapCameraState.zoomLevel
        mapCameraState.zoomLevel = zoom
        if let pitch :CGFloat = positionData["pitch"] as? CGFloat {
            mapCameraState.pitch = pitch
        }
        if let heading :CLLocationDirection = positionData["heading"] as? CLLocationDirection {
            mapCameraState.heading = heading
        }
        let centerCoordinate :CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:  targetList[0], longitude: targetList[1])
        self.setCenterCoordinateWithAltitude(centerCoordinate: centerCoordinate, zoomLevel: zoom, animated: animated)
    }
    
    func setBounds(_ positionData: Dictionary<String, Any>, animated: Bool) {
        guard let targetList :Array<Array<CLLocationDegrees>> = positionData["target"] as? Array<Array<CLLocationDegrees>> else { return }
        let padding :Double = positionData["padding"] as? Double ?? 0
        let coodinates: Array<CLLocationCoordinate2D> = targetList.map { (coordinate : Array<CLLocationDegrees>) in
            return CLLocationCoordinate2D(latitude:  coordinate[0], longitude: coordinate[1])
        }
        guard let mapRect = coodinates.mapRect() else { return }
        self.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: CGFloat(padding), left: CGFloat(padding), bottom: CGFloat(padding), right: CGFloat(padding)), animated: animated)
    }
    
    func setCenterCoordinateWithAltitude(centerCoordinate: CLLocationCoordinate2D, zoomLevel: Double, animated: Bool) {
        // clamp large numbers to 28
        let zoomL = min(zoomLevel, 28);
        let altitude = getCameraAltitude(centerCoordinate: centerCoordinate, zoomLevel: zoomL)
        self.setCamera(MKMapCamera(lookingAtCenter: centerCoordinate, fromDistance: CLLocationDistance(altitude), pitch: mapCameraState.pitch, heading: mapCameraState.heading), animated: animated)
    }
    
    private func getCameraAltitude(centerCoordinate: CLLocationCoordinate2D, zoomLevel: Double) -> Double {
        // convert center coordiate to pixel space
        let centerPixelY = Utils.latitudeToPixelSpaceY(latitude: centerCoordinate.latitude)
        // determine the scale value from the zoom level
        let zoomExponent:Double = 21.0 - zoomLevel
        let zoomScale:Double = pow(2.0, zoomExponent)
        // scale the map’s size in pixel space
        let mapSizeInPixels = self.bounds.size
        let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale
        // figure out the position of the top-left pixel
        let topLeftPixelY = centerPixelY - (scaledMapHeight / 2.0)
        // find delta between left and right longitudes
        let maxLat = Utils.pixelSpaceYToLatitude(pixelY: topLeftPixelY + scaledMapHeight)
        let topBottom = CLLocationCoordinate2D.init(latitude: maxLat, longitude: centerCoordinate.longitude)
        
        let distance = MKMapPoint.init(centerCoordinate).distance(to: MKMapPoint.init(topBottom))
        let altitude = distance / tan(.pi*(15/180.0))
        
        return altitude
    }

    /// Converts a zoom level to a camera center-coordinate distance using the
    /// equator as reference latitude. The result is independent of the current
    /// map bounds so it can safely be called before layout completes.
    private func zoomLevelToDistance(_ zoom: Double) -> CLLocationDistance {
        let z = min(zoom, 28)
        let metersPerPixelAtEquator = 156543.03392
        let referenceScreenHeight = 800.0
        let metersPerPixel = metersPerPixelAtEquator / pow(2.0, z)
        let visibleMeters = metersPerPixel * referenceScreenHeight
        return visibleMeters / tan(.pi * (15.0 / 180.0))
    }

    /// Applies `MKMapView.cameraZoomRange` (iOS 13+) so the native map view
    /// itself prevents pinch gestures from exceeding the stored min/max zoom
    /// levels. Without this, `MKMapView` allows unrestricted gesture zooming
    /// and the per-instance stored min/max zoom values are only checked during
    /// programmatic camera moves.
    private func applyCameraZoomRange() {
        // Lower zoom level = further out = larger center-coordinate distance.
        let maxDistance = zoomLevelToDistance(mapCameraState.minZoomLevel)
        let minDistance = zoomLevelToDistance(mapCameraState.maxZoomLevel)
        self.cameraZoomRange = MKMapView.CameraZoomRange(
            minCenterCoordinateDistance: minDistance,
            maxCenterCoordinateDistance: maxDistance
        )
    }
    
    func getVisibleRegion() -> Dictionary<String, Array<Double>> {
        if self.bounds.size != CGSize.zero {
            // convert center coordiate to pixel space
            let centerPixelX = Utils.longitudeToPixelSpaceX(longitude: self.centerCoordinate.longitude)
            let centerPixelY = Utils.latitudeToPixelSpaceY(latitude: self.centerCoordinate.latitude)

            // determine the scale value from the zoom level
            let zoomExponent = Double(21 - mapCameraState.zoomLevel)
            let zoomScale = pow(2.0, zoomExponent)

            // scale the map’s size in pixel space
            let mapSizeInPixels = self.bounds.size
            let scaledMapWidth = Double(mapSizeInPixels.width) * zoomScale
            let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale;

            // figure out the position of the top-left pixel
            let topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
            let topLeftPixelY = centerPixelY - (scaledMapHeight / 2);

            // find the southwest coordinate
            let minLng = Utils.pixelSpaceXToLongitude(pixelX: topLeftPixelX)
            let minLat = Utils.pixelSpaceYToLatitude(pixelY: topLeftPixelY)

            // find the northeast coordinate
            let maxLng = Utils.pixelSpaceXToLongitude(pixelX: topLeftPixelX + scaledMapWidth)
            let maxLat = Utils.pixelSpaceYToLatitude(pixelY: topLeftPixelY + scaledMapHeight)

            return ["northeast": [minLat, maxLng], "southwest": [maxLat, minLng]]
        }
        return ["northeast": [0.0, 0.0], "southwest": [0.0, 0.0]]
    }
    
    func zoomIn(animated: Bool) {
        if mapCameraState.zoomLevel - 1 <= mapCameraState.maxZoomLevel {
            if mapCameraState.zoomLevel < 2 {
                mapCameraState.zoomLevel = 2
            }
            mapCameraState.zoomLevel += 1
            self.setCenterCoordinateWithAltitude(centerCoordinate: centerCoordinate, zoomLevel: mapCameraState.zoomLevel, animated: animated)
        }
    }
    
    func zoomOut(animated: Bool) {
        if mapCameraState.zoomLevel - 1 >= mapCameraState.minZoomLevel {
            mapCameraState.zoomLevel -= 1
            if round(mapCameraState.zoomLevel) <= 2 {
               mapCameraState.zoomLevel = 0
            }

            self.setCenterCoordinateWithAltitude(centerCoordinate: centerCoordinate, zoomLevel: mapCameraState.zoomLevel, animated: animated)
        }
    }

    func zoomTo(newZoomLevel: Double, animated: Bool) {
        if newZoomLevel < mapCameraState.minZoomLevel {
            mapCameraState.zoomLevel = mapCameraState.minZoomLevel
        } else if newZoomLevel > mapCameraState.maxZoomLevel {
            mapCameraState.zoomLevel = mapCameraState.maxZoomLevel
        } else {
            mapCameraState.zoomLevel = newZoomLevel
        }

        self.setCenterCoordinateWithAltitude(centerCoordinate: centerCoordinate, zoomLevel: mapCameraState.zoomLevel, animated: animated)
    }

    func zoomBy(zoomBy: Double, animated: Bool, focus: CGPoint? = nil) {
        let oldZoom = mapCameraState.zoomLevel
        let newZoom: Double
        if oldZoom + zoomBy < mapCameraState.minZoomLevel {
            newZoom = mapCameraState.minZoomLevel
        } else if oldZoom + zoomBy > mapCameraState.maxZoomLevel {
            newZoom = mapCameraState.maxZoomLevel
        } else {
            newZoom = oldZoom + zoomBy
        }
        mapCameraState.zoomLevel = newZoom

        let newCenter: CLLocationCoordinate2D
        if let focus = focus {
            let focusCoordinate = self.convert(focus, toCoordinateFrom: self)
            let zoomDelta = newZoom - oldZoom
            let scale = pow(2.0, zoomDelta)
            let focusPt = MKMapPoint(focusCoordinate)
            let centerPt = MKMapPoint(centerCoordinate)
            let adjustedPt = MKMapPoint(
                x: focusPt.x + (centerPt.x - focusPt.x) / scale,
                y: focusPt.y + (centerPt.y - focusPt.y) / scale
            )
            newCenter = adjustedPt.coordinate
        } else {
            newCenter = centerCoordinate
        }

        self.setCenterCoordinateWithAltitude(centerCoordinate: newCenter, zoomLevel: newZoom, animated: animated)
    }
    
    func updateStoredCameraValues(newZoomLevel: Double, newPitch: CGFloat, newHeading: CLLocationDirection) {
        mapCameraState.zoomLevel = newZoomLevel
        mapCameraState.pitch = newPitch
        mapCameraState.heading = newHeading
    }
}

extension Array where Element == CLLocationCoordinate2D {
    func mapRect() -> MKMapRect? {
        return map(MKMapPoint.init).mapRect()
    }
}

extension Array where Element == CLLocation {
    func mapRect() -> MKMapRect? {
        return map { MKMapPoint($0.coordinate) }.mapRect()
    }
}

extension Array where Element == MKMapPoint {
    func mapRect() -> MKMapRect? {
        guard count > 0 else { return nil }

        let xs = map { $0.x }
        let ys = map { $0.y }

        let west = xs.min()!
        let east = xs.max()!
        let width = east - west

        let south = ys.min()!
        let north = ys.max()!
        let height = north - south

        return MKMapRect(x: west, y: south, width: width, height: height)
    }
}
