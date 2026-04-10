//
//  AppleMapController.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 03.09.19.
//

import Foundation
import Flutter
import MapKit

public class AppleMapController: NSObject, FlutterPlatformView, AppleMapHostApi {
    var contentView: UIView
    var mapView: FlutterMapView
    var registrar: FlutterPluginRegistrar
    var channel: FlutterMethodChannel
    let mapId: Int64
    let hostApiSuffix: String
    var initialCameraPosition: [String: Any]
    var options: [String: Any]
    var currentlySelectedAnnotation: String?
    var snapShotOptions: MKMapSnapshotter.Options = MKMapSnapshotter.Options()
    var snapShot: MKMapSnapshotter?
    var isDisposed: Bool = false
    
    public init(withFrame frame: CGRect, withRegistrar registrar: FlutterPluginRegistrar, withargs args: Dictionary<String, Any> ,withId id: Int64) {
        self.mapId = id
        self.hostApiSuffix = String(id)
        self.options = args["options"] as! [String: Any]
        self.channel = FlutterMethodChannel(name: "apple_maps_plugin.luisthein.de/apple_maps_\(id)", binaryMessenger: registrar.messenger())
        
        self.mapView = FlutterMapView(channel: channel, options: options)
        self.registrar = registrar
        
        // To stop the odd movement of the Apple logo.
        self.contentView = UIScrollView()
        self.contentView.addSubview(mapView)
        mapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        self.initialCameraPosition = args["initialCameraPosition"]! as! Dictionary<String, Any>
        
        super.init()
        
        self.mapView.delegate = self
        AppleMapHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: self, messageChannelSuffix: hostApiSuffix)
        
        self.mapView.setCenterCoordinate(initialCameraPosition, animated: false)
        
        if let annotationsToAdd: NSArray = args["annotationsToAdd"] as? NSArray {
            self.annotationsToAdd(annotations: annotationsToAdd)
        }
        if let polylinesToAdd: NSArray = args["polylinesToAdd"] as? NSArray {
            self.addPolylines(polylineData: polylinesToAdd)
        }
        if let polygonsToAdd: NSArray = args["polygonsToAdd"] as? NSArray {
            self.addPolygons(polygonData: polygonsToAdd)
        }
        if let circlesToAdd: NSArray = args["circlesToAdd"] as? NSArray {
            self.addCircles(circleData: circlesToAdd)
        }
    }

    deinit {
        tearDownHostApi()
    }
    
    public func view() -> UIView {
        return contentView
    }

    func updateMapOptions(options: PlatformMapOptions) throws {
        self.mapView.interpretOptions(options: options.asDictionary)
    }

    func updateAnnotations(updates: PlatformAnnotationUpdates) throws {
        let legacyUpdates = updates.asLegacyUpdates
        if let annotationsToAdd = legacyUpdates.annotationsToAdd {
            self.annotationsToAdd(annotations: annotationsToAdd)
        }
        if let annotationsToChange = legacyUpdates.annotationsToChange {
            self.annotationsToChange(annotations: annotationsToChange)
        }
        if let annotationIdsToRemove = legacyUpdates.annotationIdsToRemove {
            self.annotationsIdsToRemove(annotationIds: annotationIdsToRemove as NSArray)
        }
    }

    func updatePolylines(updates: PlatformPolylineUpdates) throws {
        let legacyUpdates = updates.asLegacyUpdates
        if let polylinesToAdd = legacyUpdates.polylinesToAdd {
            self.addPolylines(polylineData: polylinesToAdd)
        }
        if let polylinesToChange = legacyUpdates.polylinesToChange {
            self.changePolylines(polylineData: polylinesToChange)
        }
        if let polylineIdsToRemove = legacyUpdates.polylineIdsToRemove {
            self.removePolylines(polylineIds: polylineIdsToRemove as NSArray)
        }
    }

    func updatePolygons(updates: PlatformPolygonUpdates) throws {
        let legacyUpdates = updates.asLegacyUpdates
        if let polygonsToAdd = legacyUpdates.polygonsToAdd {
            self.addPolygons(polygonData: polygonsToAdd)
        }
        if let polygonsToChange = legacyUpdates.polygonsToChange {
            self.changePolygons(polygonData: polygonsToChange)
        }
        if let polygonIdsToRemove = legacyUpdates.polygonIdsToRemove {
            self.removePolygons(polygonIds: polygonIdsToRemove as NSArray)
        }
    }

    func updateCircles(updates: PlatformCircleUpdates) throws {
        let legacyUpdates = updates.asLegacyUpdates
        if let circlesToAdd = legacyUpdates.circlesToAdd {
            self.addCircles(circleData: circlesToAdd)
        }
        if let circlesToChange = legacyUpdates.circlesToChange {
            self.changeCircles(circleData: circlesToChange)
        }
        if let circleIdsToRemove = legacyUpdates.circleIdsToRemove {
            self.removeCircles(circleIds: circleIdsToRemove as NSArray)
        }
    }

    func animateCamera(cameraUpdate: PlatformCameraUpdate) throws {
        updateCamera(cameraUpdate: cameraUpdate, animated: true)
    }

    func moveCamera(cameraUpdate: PlatformCameraUpdate) throws {
        updateCamera(cameraUpdate: cameraUpdate, animated: false)
    }

    func showMarkerInfoWindow(annotationId: String) throws {
        self.selectAnnotation(with: annotationId)
    }

    func hideMarkerInfoWindow(annotationId: String) throws {
        self.hideAnnotation(with: annotationId)
    }

    func isMarkerInfoWindowShown(annotationId: String) throws -> Bool? {
        self.isAnnotationSelected(with: annotationId)
    }

    func getZoomLevel() throws -> Double? {
        self.mapView.calculatedZoomLevel
    }

    func getVisibleRegion() throws -> PlatformLatLngBounds {
        let region = self.mapView.getVisibleRegion()
        let southwest = region["southwest"] ?? [0, 0]
        let northeast = region["northeast"] ?? [0, 0]
        return PlatformLatLngBounds(
            southwest: PlatformLatLng(latitude: southwest[0], longitude: southwest[1]),
            northeast: PlatformLatLng(latitude: northeast[0], longitude: northeast[1])
        )
    }

    func getScreenCoordinate(latLng: PlatformLatLng) throws -> PlatformScreenCoordinate? {
        let point = self.mapView.convert(latLng.asCoordinate, toPointTo: self.view())
        return PlatformScreenCoordinate(x: point.x, y: point.y)
    }

    func takeSnapshot(options: PlatformSnapshotOptions, completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void) {
        self.takeSnapshot(options: SnapshotOptions(options: options.asDictionary)) { snapshot, error in
            if let error {
                completion(.failure(error))
                return
            }
            completion(.success(snapshot))
        }
    }

    func dispose() throws {
        tearDownHostApi()
    }

    private func tearDownHostApi() {
        if isDisposed {
            return
        }
        isDisposed = true
        AppleMapHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: nil, messageChannelSuffix: hostApiSuffix)
        channel.setMethodCallHandler(nil)
        mapView.delegate = nil
        snapShot?.cancel()
        snapShot = nil
        mapView.resetStoredCameraState()
    }

    private func updateCamera(cameraUpdate: PlatformCameraUpdate, animated: Bool) {
        let positionData = self.toPositionData(cameraUpdate: cameraUpdate, animated: animated)
        if !positionData.isEmpty {
            guard positionData["moveToBounds"] == nil else {
                self.mapView.setBounds(positionData, animated: animated)
                return
            }
            self.mapView.setCenterCoordinate(positionData, animated: animated)
        }
    }

    private func toPositionData(cameraUpdate: PlatformCameraUpdate, animated: Bool) -> Dictionary<String, Any> {
        switch cameraUpdate.type {
        case .newCameraPosition:
            return cameraUpdate.cameraPosition?.asDictionary ?? [:]
        case .newLatLng:
            if let latLng = cameraUpdate.latLng {
                return ["target": latLng.asList]
            }
        case .newLatLngZoom:
            if let latLng = cameraUpdate.latLng {
                return ["target": latLng.asList, "zoom": cameraUpdate.zoom ?? 0]
            }
        case .newLatLngBounds:
            if let bounds = cameraUpdate.bounds {
                return [
                    "target": bounds.asTargetList,
                    "padding": cameraUpdate.padding ?? 0,
                    "moveToBounds": true,
                ]
            }
        case .zoomBy:
            if let zoomBy = cameraUpdate.zoom {
                let focus: CGPoint? = cameraUpdate.focus.map { CGPoint(x: $0.x, y: $0.y) }
                mapView.zoomBy(zoomBy: zoomBy, animated: animated, focus: focus)
            }
        case .zoomTo:
            if let zoomTo = cameraUpdate.zoom {
                mapView.zoomTo(newZoomLevel: zoomTo, animated: animated)
            }
        case .zoomIn:
            mapView.zoomIn(animated: animated)
        case .zoomOut:
            mapView.zoomOut(animated: animated)
        }
        return [:]
    }
}


extension AppleMapController: MKMapViewDelegate {
    // onIdle
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if ((self.mapView.mapContainerView) != nil) {
            let locationOnMap = self.mapView.region.center
            self.channel.invokeMethod("camera#onMove", arguments: ["position": ["heading": self.mapView.actualHeading, "target":  [locationOnMap.latitude, locationOnMap.longitude], "pitch": self.mapView.camera.pitch, "zoom": self.mapView.calculatedZoomLevel]])
        }
        self.channel.invokeMethod("camera#onIdle", arguments: "")
    }
    
    // onMoveStarted
    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        self.channel.invokeMethod("camera#onMoveStarted", arguments: "")
    }
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is FlutterPolyline {
            return self.polylineRenderer(overlay: overlay)
        } else if overlay is FlutterPolygon {
            return self.polygonRenderer(overlay: overlay)
        } else if overlay is FlutterCircle {
            return self.circleRenderer(overlay: overlay)
        }
        return MKOverlayRenderer()
    }
}

extension AppleMapController {
    private func takeSnapshot(options: SnapshotOptions, onCompletion: @escaping (FlutterStandardTypedData?, Error?) -> Void) {
        // MKMapSnapShotOptions setting.
        snapShotOptions.region = self.mapView.region
        snapShotOptions.size = self.mapView.frame.size
        snapShotOptions.scale = UIScreen.main.scale
        snapShotOptions.showsBuildings = options.showBuildings
        if #available(iOS 13.0, *) {
            snapShotOptions.pointOfInterestFilter = options.showPointsOfInterest
                ? .includingAll
                : .excludingAll
        } else {
            snapShotOptions.showsPointsOfInterest = options.showPointsOfInterest
        }
        
        // Cancel any in-flight snapshot before creating a new one.
        snapShot?.cancel()
        snapShot = MKMapSnapshotter(options: snapShotOptions)
        
        if #available(iOS 10.0, *) {
            snapShot?.start { [weak self] snapshot, error in
                guard let self = self else {
                    return
                }
                
                guard let snapshot = snapshot, error == nil else {
                    onCompletion(nil, error)
                    return
                }
                
                let image = UIGraphicsImageRenderer(size: self.snapShotOptions.size).image { [weak self] context in
                    guard let self = self else {
                        return
                    }
                    snapshot.image.draw(at: .zero)
                    let rect = self.snapShotOptions.mapRect
                    if options.showAnnotations {
                        for annotation in self.mapView.getMapViewAnnotations() {
                            self.drawAnnotations(annotation: annotation, point: snapshot.point(for: annotation!.coordinate))
                        }
                    }
                    if options.showOverlays {
                        for overlay in self.mapView.overlays {
                            if ((overlay.intersects?(rect)) != nil) {
                                self.drawOverlays(overlay: overlay, snapshot: snapshot, context: context)
                            }
                        }
                    }
                }

                if let imageData = image.pngData() {
                    onCompletion(FlutterStandardTypedData.init(bytes: imageData), nil)
                }
            }
        }
    }
    
    private func drawAnnotations(annotation: FlutterAnnotation?, point: CGPoint) {
        guard annotation != nil else {
            return
        }
        let annotationView = self.getAnnotationView(annotation: annotation!)
        
        var offsetPoint = point
        
        offsetPoint.x -= annotationView.bounds.width / 2
        offsetPoint.y -= annotationView.bounds.height / 2
        
        
        if #available(iOS 11.0, *), annotationView is MKMarkerAnnotationView {
            annotationView.drawHierarchy(in: CGRect(x: offsetPoint.x, y: offsetPoint.y, width: annotationView.bounds.width, height: annotationView.bounds.height), afterScreenUpdates: true)
        } else {
            offsetPoint.x += annotationView.centerOffset.x
            offsetPoint.y += annotationView.centerOffset.y
            let annotationImage = annotationView.image
            annotationImage?.draw(at: offsetPoint)
        }
    }
    
    @available(iOS 10.0, *)
    private func drawOverlays(overlay: MKOverlay?, snapshot: MKMapSnapshotter.Snapshot, context: UIGraphicsRendererContext) {
        guard overlay != nil else {
            return
        }
        
        if let flutterOverlay: FlutterOverlay = overlay as? FlutterOverlay {
            flutterOverlay.getCAShapeLayer(snapshot: snapshot).render(in: context.cgContext)
        }
        
    }
}
