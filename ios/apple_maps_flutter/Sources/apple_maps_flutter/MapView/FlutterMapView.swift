//
//  FlutterAppleMap.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 09.10.19.
//

import Foundation
import Flutter
import MapKit
import CoreLocation

enum BUTTON_IDS: Int {
    case LOCATION = 100
}


class FlutterMapView: MKMapView, UIGestureRecognizerDelegate {
    weak var mapContainerView: UIView?
    weak var channel: FlutterMethodChannel?
    var oldBounds: CGRect?
    var options: Dictionary<String, Any>?
    var isMyLocationButtonShowing: Bool? = false
    var isPointsOfInterestEnabled: Bool {
        (self.pointOfInterestFilter ?? .includingAll) != .excludingAll
    }
    
    fileprivate let locationManager: CLLocationManager = CLLocationManager()
    
    let mapTypes: Array<MKMapType> = [
        MKMapType.standard,
        MKMapType.satellite,
        MKMapType.hybrid,
    ]
    
    let userTrackingModes: Array<MKUserTrackingMode> = [
        MKUserTrackingMode.none,
        MKUserTrackingMode.follow,
        MKUserTrackingMode.followWithHeading,
    ]
    
    convenience init(channel: FlutterMethodChannel, options: Dictionary<String, Any>) {
        self.init(frame: CGRect.zero)
        self.channel = channel
        self.options = options
        initialiseTapGestureRecognizers()
    }
    
    var actualHeading: CLLocationDirection {
        get {
            if mapContainerView != nil {
                var heading: CLLocationDirection = fabs(180 * asin(Double(mapContainerView!.transform.b)) / .pi)
                if mapContainerView!.transform.b <= 0 {
                    if mapContainerView!.transform.a >= 0 {
                        // do nothing
                    } else {
                        heading = 180 - heading
                    }
                } else {
                    if mapContainerView!.transform.a <= 0 {
                        heading = heading + 180
                    } else {
                        heading = 360 - heading
                    }
                }
                return heading
            }
            return CLLocationDirection.zero
        }
    }
    
    // To calculate the displayed region we have to get the layout bounds.
    // Because the self is layed out using an auto layout we have to call
    // setCenterCoordinate after the self was layed out.
    override func layoutSubviews() {
        // Only update the map in layoutSubviews if the bounds changed
        if self.bounds != oldBounds {
            if self.options != nil {
                self.interpretOptions(options: self.options!)
            }
            setCenterCoordinateWithAltitude(centerCoordinate: centerCoordinate, zoomLevel: zoomLevel, animated: false)
            mapContainerView = self.findViewOfType("MKScrollContainerView", inView: self)
        }
        oldBounds = self.bounds
    }
    
    
    override func didMoveToSuperview() {
        if oldBounds != CGRect.zero {
            oldBounds = CGRect.zero
        }
    }
    
    private func findViewOfType(_ viewType: String, inView view: UIView) -> UIView? {
      // function scans subviews recursively and returns
      // reference to the found one of a type
      if view.subviews.count > 0 {
        for v in view.subviews {
          let valueDescription = v.description
          let keywords = viewType
          if valueDescription.range(of: keywords) != nil {
            return v
          }
          if let inSubviews = self.findViewOfType(viewType, inView: v) {
            return inSubviews
          }
        }
        return nil
      } else {
        return nil
      }
    }
    
    func interpretOptions(options: Dictionary<String, Any>) {
        if let isCompassEnabled: Bool = options["compassEnabled"] as? Bool {
            self.showsCompass = isCompassEnabled
            self.mapTrackingButton(isVisible: self.isMyLocationButtonShowing ?? false)
        }

        if let padding: Array<Any> = options["padding"] as? Array<Any> {
            var margins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            
            if padding.count >= 1, let top: Double = padding[0] as? Double {
                margins.top = CGFloat(top)
            }
            
            if padding.count >= 2, let left: Double = padding[1] as? Double {
                margins.left = CGFloat(left)
            }
            
            if padding.count >= 3, let bottom: Double = padding[2] as? Double {
                margins.bottom = CGFloat(bottom)
            }
            
            if padding.count >= 4, let right: Double = padding[3] as? Double {
                margins.right = CGFloat(right)
            }
            
            self.layoutMargins = margins
        }
        
        let newMapType = options["mapType"] as? Int
        let newTraffic = options["trafficEnabled"] as? Bool
        let newPoi = options["pointsOfInterestEnabled"] as? Bool
        if newMapType != nil || newTraffic != nil || newPoi != nil {
            let mapTypeIndex = newMapType ?? self.mapTypes.firstIndex(of: self.mapType) ?? 0
            let traffic = newTraffic ?? self.showsTraffic
            let poi: MKPointOfInterestFilter = {
                if let newPoi {
                    return newPoi ? .includingAll : .excludingAll
                }
                return self.pointOfInterestFilter ?? .includingAll
            }()

            if #available(iOS 16.0, *) {
                let config: MKMapConfiguration
                switch mapTypeIndex {
                case 1:
                    config = MKImageryMapConfiguration()
                case 2:
                    let c = MKHybridMapConfiguration(elevationStyle: .realistic)
                    c.showsTraffic = traffic
                    c.pointOfInterestFilter = poi
                    config = c
                default:
                    let c = MKStandardMapConfiguration(elevationStyle: .realistic)
                    c.showsTraffic = traffic
                    c.pointOfInterestFilter = poi
                    config = c
                }
                self.preferredConfiguration = config
            } else {
                self.mapType = self.mapTypes[mapTypeIndex]
                self.showsTraffic = traffic
                self.pointOfInterestFilter = poi
            }

        }
        
        if let rotateGesturesEnabled: Bool = options["rotateGesturesEnabled"] as? Bool {
            self.isRotateEnabled = rotateGesturesEnabled
        }
        
        if let scrollGesturesEnabled: Bool = options["scrollGesturesEnabled"] as? Bool {
            self.isScrollEnabled = scrollGesturesEnabled
        }
        
        if let pitchGesturesEnabled: Bool = options["pitchGesturesEnabled"] as? Bool {
            self.isPitchEnabled = pitchGesturesEnabled
        }
        
        if let zoomGesturesEnabled: Bool = options["zoomGesturesEnabled"] as? Bool{
            self.isZoomEnabled = zoomGesturesEnabled
        }
        
        if let myLocationEnabled: Bool = options["myLocationEnabled"] as? Bool {
            if (myLocationEnabled) {
                self.setUserLocation()
            } else {
                self.removeUserLocation()
            }
            
        }
        
        if let myLocationButtonEnabled: Bool = options["myLocationButtonEnabled"] as? Bool {
            self.mapTrackingButton(isVisible: myLocationButtonEnabled)
        }
        
        if let userTackingMode: Int = options["trackingMode"] as? Int {
            self.setUserTrackingMode(self.userTrackingModes[userTackingMode], animated: false)
        }
        
        if let minMaxZoom: Array<Any> = options["minMaxZoomPreference"] as? Array<Any>{
            if let _minZoom: Double = minMaxZoom[0] as? Double {
                self.minZoomLevel = _minZoom
            }
            if let _maxZoom: Double = minMaxZoom[1] as? Double {
                self.maxZoomLevel = _maxZoom
            }
        }
        
        if let insetsSafeArea: Bool = options["insetsLayoutMarginsFromSafeArea"] as? Bool {
            self.insetsLayoutMarginsFromSafeArea = insetsSafeArea
        }

        if options.keys.contains("cameraTargetBounds") {
            if let boundsData = options["cameraTargetBounds"] as? [[Double]] {
                let sw = CLLocationCoordinate2D(latitude: boundsData[0][0], longitude: boundsData[0][1])
                let ne = CLLocationCoordinate2D(latitude: boundsData[1][0], longitude: boundsData[1][1])
                let center = CLLocationCoordinate2D(
                    latitude: (sw.latitude + ne.latitude) / 2.0,
                    longitude: (sw.longitude + ne.longitude) / 2.0
                )
                let span = MKCoordinateSpan(
                    latitudeDelta: abs(ne.latitude - sw.latitude),
                    longitudeDelta: abs(ne.longitude - sw.longitude)
                )
                let region = MKCoordinateRegion(center: center, span: span)
                self.cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: region)
            } else {
                self.cameraBoundary = nil
            }
        }

        if let buildingsEnabled: Bool = options["buildingsEnabled"] as? Bool {
            self.showsBuildings = buildingsEnabled
        }

        if let scaleEnabled: Bool = options["scaleEnabled"] as? Bool {
            self.showsScale = scaleEnabled
        }

    }
    
    func setUserLocation() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
            
        case .authorizedAlways:
            fallthrough
        case .authorizedWhenInUse:
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.startUpdatingLocation()
            self.showsUserLocation = true
            break
            
        default:
            print("\(authorizationStatus.rawValue) is not supported.")
        }
    }
    
    func removeUserLocation() {
        locationManager.stopUpdatingLocation()
        self.showsUserLocation = false
    }
    
    // Functions used for the mapTrackingButton
    func mapTrackingButton(isVisible visible: Bool) {
        self.isMyLocationButtonShowing = visible
        if let _locationButton = self.viewWithTag(BUTTON_IDS.LOCATION.rawValue) {
           _locationButton.removeFromSuperview()
        }
        if visible {
            let buttonContainer = UIView()
            buttonContainer.translatesAutoresizingMaskIntoConstraints = false
            buttonContainer.widthAnchor.constraint(equalToConstant: 35).isActive = true
            buttonContainer.heightAnchor.constraint(equalToConstant: 35).isActive = true
            buttonContainer.layer.cornerRadius = 8
            buttonContainer.tag = BUTTON_IDS.LOCATION.rawValue
            buttonContainer.backgroundColor = .white
            let userTrackingButton = MKUserTrackingButton(mapView: self)
            userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
            buttonContainer.addSubview(userTrackingButton)
            userTrackingButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor).isActive = true
            userTrackingButton.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor).isActive = true
            self.addSubview(buttonContainer)
            buttonContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5 - self.layoutMargins.right).isActive = true
            buttonContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: self.showsCompass ? 50 : 5 + self.layoutMargins.top).isActive = true
        }
    }
    
    func getMapViewAnnotations() -> [FlutterAnnotation?] {
        let flutterAnnotations = self.annotations as? [FlutterAnnotation] ?? []
        let sortedAnnotations = flutterAnnotations.sorted(by: { $0.zIndex  < $1.zIndex })
        return sortedAnnotations
    }
       
    
    // Functions used for GestureRecognition
    private func initialiseTapGestureRecognizers() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onMapGesture))
        panGesture.maximumNumberOfTouches = 2
        panGesture.delegate = self
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(onMapGesture))
        pinchGesture.delegate = self
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(onMapGesture))
        rotateGesture.delegate = self
        let tiltGesture = UISwipeGestureRecognizer(target: self, action: #selector(onMapGesture))
        tiltGesture.numberOfTouchesRequired = 2
        tiltGesture.direction = .up
        tiltGesture.direction = .down
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: nil)
        doubleTapGesture.numberOfTapsRequired = 2
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        tapGesture.require(toFail: doubleTapGesture)    // only recognize taps that are not involved in zooming
        self.addGestureRecognizer(panGesture)
        self.addGestureRecognizer(pinchGesture)
        self.addGestureRecognizer(rotateGesture)
        self.addGestureRecognizer(tiltGesture)
        self.addGestureRecognizer(longTapGesture)
        self.addGestureRecognizer(doubleTapGesture)
        self.addGestureRecognizer(tapGesture)
    }
       
    @objc func onMapGesture(sender: UIGestureRecognizer) {
        let locationOnMap = self.region.center // self.convert(locationInView, toCoordinateFrom: self)
        let zoom = self.calculatedZoomLevel
        let pitch = self.camera.pitch
        let heading = self.actualHeading
        self.updateCameraValues()
        channel?.invokeMethod("camera#onMove", arguments: ["position": ["heading": heading, "target":  [locationOnMap.latitude, locationOnMap.longitude], "pitch": pitch, "zoom": zoom]])
    }

    @objc func longTap(sender: UIGestureRecognizer){
        if sender.state == .began {
           let locationInView = sender.location(in: self)
           let locationOnMap = self.convert(locationInView, toCoordinateFrom: self)
           
           channel?.invokeMethod("map#onLongPress", arguments: ["position": [locationOnMap.latitude, locationOnMap.longitude]])
        }
    }

    @objc func onTap(tap: UITapGestureRecognizer) {
        if tap.state == .recognized {
            TouchHandler.handleMapTaps(tap: tap, overlays: self.overlays, channel: self.channel, in: self)
        }
    }
    
    func updateCameraValues() {
        if oldBounds != nil && oldBounds != CGRect.zero {
            self.updateStoredCameraValues(newZoomLevel: calculatedZoomLevel, newPitch: camera.pitch, newHeading: actualHeading)
        }
    }
    
    // Always allow multiple gestureRecognizers
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func distanceOfCGPoints(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
}
