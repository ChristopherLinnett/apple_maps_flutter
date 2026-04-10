//
//  PolylineController.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 12.11.19.
//

import Foundation
import MapKit

extension AppleMapController: PolylineDelegate {
    
    func polylineRenderer(overlay: MKOverlay) -> MKOverlayRenderer {
        // Make sure we are rendering a polyline.
        guard let polyline = overlay as? MKPolyline else {
           return MKOverlayRenderer()
        }
        let polylineRenderer = MKPolylineRenderer(overlay: polyline)

        if let flutterPolyline: FlutterPolyline = overlay as? FlutterPolyline {
            if flutterPolyline.isVisible ?? true {
                polylineRenderer.strokeColor = flutterPolyline.color
                polylineRenderer.lineWidth = flutterPolyline.width ?? 1.0
                polylineRenderer.lineDashPattern = flutterPolyline.pattern
                polylineRenderer.lineJoin = flutterPolyline.lineJoin ?? .round
                polylineRenderer.lineCap = flutterPolyline.capType ?? .butt
            } else {
                polylineRenderer.strokeColor = UIColor.clear
                polylineRenderer.lineWidth = 0.0
            }
        }
        return polylineRenderer
    }

    func addPolylines(polylineData data: NSArray) {
        for _polyline in data {
            let polylineData :Dictionary<String, Any> = _polyline as! Dictionary<String, Any>
            let polyline = FlutterPolyline(fromDictionaray: polylineData)
            addPolyline(polyline: polyline)
        }
    }

    func changePolylines(polylineData data: NSArray) {
        let oldOverlays: [MKOverlay] = self.mapView.overlays
        for oldOverlay in oldOverlays {
            if oldOverlay is FlutterPolyline {
                let oldFlutterPolyline = oldOverlay as! FlutterPolyline
                for _polyline in data {
                    let polylineData :Dictionary<String, Any> = _polyline as! Dictionary<String, Any>
                    if oldFlutterPolyline.id == (polylineData["polylineId"] as! String) {
                        let newPolyline = FlutterPolyline.init(fromDictionaray: polylineData)
                        if oldFlutterPolyline != newPolyline {
                            updatePolylinesOnMap(oldPolyline: oldFlutterPolyline, newPolyline: newPolyline)
                        }
                    }
                }
            }
        }
    }

    func removePolylines(polylineIds: NSArray) {
        for overlay in self.mapView.overlays {
            if let polyline = overlay as? FlutterPolyline {
                if polylineIds.contains(polyline.id!) {
                    self.mapView.removeOverlay(polyline)
                }
            }
        }
    }
    
    func removeAllPolylines() {
        for overlay in self.mapView.overlays {
            if let polyline = overlay as? FlutterPolyline {
                self.mapView.removeOverlay(polyline)
            }
        }
    }
    
    private func updatePolylinesOnMap(oldPolyline: FlutterPolyline, newPolyline: FlutterPolyline) {
        self.mapView.removeOverlay(oldPolyline)
        addPolyline(polyline: newPolyline)
    }
    
    private func addPolyline(polyline: FlutterPolyline) {
        if polyline.zIndex == nil || polyline.zIndex == -1 {
            self.mapView.addOverlay(polyline)
        } else {
            self.mapView.insertOverlay(polyline, at: polyline.zIndex ?? 0)
        }
    }
}
