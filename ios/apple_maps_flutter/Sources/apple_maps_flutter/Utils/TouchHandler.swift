//
//  TouchHandler.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 09.03.20.
//

import Foundation
import MapKit

class TouchHandler {
    
    static func handleMapTaps(tap: UITapGestureRecognizer, overlays: [MKOverlay], flutterApi: AppleMapFlutterApi?, in view: MKMapView) {
        let locationInView = tap.location(in: view)
        let touchPt: CGPoint = tap.location(in: view)
        let coord: CLLocationCoordinate2D = view.convert(touchPt, toCoordinateFrom: view)
        var didOverlayConsumeTapEvent: Bool = false
        for overlay: MKOverlay in overlays {
            if let flutterPolyline: FlutterPolyline = overlay as?  FlutterPolyline {
                if  flutterPolyline.isConsumingTapEvents ?? false && flutterPolyline.contains(coordinate: coord, mapView: view),
                    let id = flutterPolyline.id {
                    flutterApi?.onPolylineTap(polylineId: id, completion: pigeonLogOnError)
                    didOverlayConsumeTapEvent = true
                }
            } else if let flutterPolygon: FlutterPolygon = overlay as?  FlutterPolygon {
                if  flutterPolygon.isConsumingTapEvents ?? false && flutterPolygon.contains(coordinate: coord),
                    let id = flutterPolygon.id {
                    flutterApi?.onPolygonTap(polygonId: id, completion: pigeonLogOnError)
                    didOverlayConsumeTapEvent = true
                }
            } else if let flutterCircle: FlutterCircle = overlay as?  FlutterCircle {
                if  flutterCircle.isConsumingTapEvents ?? false && flutterCircle.contains(coordinate: coord),
                    let id = flutterCircle.id {
                    flutterApi?.onCircleTap(circleId: id, completion: pigeonLogOnError)
                    didOverlayConsumeTapEvent = true
                }
            }
        }
        if !didOverlayConsumeTapEvent {
            let locationOnMap = view.convert(locationInView, toCoordinateFrom: view)
            flutterApi?.onMapTap(position: PlatformLatLng(latitude: locationOnMap.latitude, longitude: locationOnMap.longitude), completion: pigeonLogOnError)
        }
    }
}
