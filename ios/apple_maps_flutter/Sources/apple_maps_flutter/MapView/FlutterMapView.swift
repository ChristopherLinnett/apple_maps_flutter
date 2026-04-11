//
//  FlutterAppleMap.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 09.10.19.
//

import Foundation
import MapKit
import CoreLocation

private enum ButtonId: Int {
    case location = 100
}


class FlutterMapView: MKMapView, UIGestureRecognizerDelegate {
    weak var mapContainerView: UIView?
    var flutterApi: AppleMapFlutterApi?
    var oldBounds: CGRect?
    var storedOptions: PlatformMapOptions?
    var isMyLocationButtonShowing: Bool = false
    var currentMapTypeIndex: Int = 0
    // Persists the last applied emphasis style so it survives map-type switches.
    // Reading preferredConfiguration is unreliable when swapping between hybrid/satellite and standard.
    private var currentEmphasisStyle: PlatformMapEmphasisStyle = .defaultStyle
    // Tracks whether location services should start once the user grants permission.
    // Set when requestWhenInUseAuthorization is called; cleared on authorization or removal.
    private var pendingUserLocationEnabled = false
    var isPointsOfInterestEnabled: Bool {
        (self.pointOfInterestFilter ?? .includingAll) != .excludingAll
    }
    
    private let locationManager: CLLocationManager = CLLocationManager()
    
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
    
    convenience init(flutterApi: AppleMapFlutterApi, options: PlatformMapOptions) {
        self.init(frame: CGRect.zero)
        self.flutterApi = flutterApi
        self.storedOptions = options
        // Delegate is set once here so the callback is active for the view's full lifetime.
        locationManager.delegate = self
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
            if let options = self.storedOptions {
                self.applyOptions(options)
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
    
    func applyOptions(_ options: PlatformMapOptions) {
        // Store latest options so that layoutSubviews re-applies them on bounds changes.
        self.storedOptions = options

        if let isCompassEnabled = options.compassEnabled {
            self.showsCompass = isCompassEnabled
            // Reposition the tracking button now that the compass may have appeared or disappeared.
            // The button visibility is updated at the end when myLocationButtonEnabled is processed.
            self.mapTrackingButton(isVisible: isMyLocationButtonShowing)
        }

        if let padding = options.padding {
            self.layoutMargins = UIEdgeInsets(
                top: CGFloat(padding.top),
                left: CGFloat(padding.left),
                bottom: CGFloat(padding.bottom),
                right: CGFloat(padding.right)
            )
        }

        let newMapType = options.mapType.map { Int($0) }
        let newTraffic = options.trafficEnabled
        let newPoi = options.pointsOfInterestEnabled
        let newBuildings = options.buildingsEnabled
        let newEmphasisStyle = options.emphasisStyle
        let newSelectableFeatures = options.selectableFeatures.map { Int($0) }
        if newMapType != nil || newTraffic != nil || newPoi != nil || newBuildings != nil
            || newEmphasisStyle != nil || newSelectableFeatures != nil {
            let mapTypeIndex = newMapType ?? self.currentMapTypeIndex
            let traffic = newTraffic ?? self.showsTraffic
            let buildings = newBuildings ?? self.showsBuildings
            let poi: MKPointOfInterestFilter = {
                if let newPoi {
                    return newPoi ? .includingAll : .excludingAll
                }
                return self.pointOfInterestFilter ?? .includingAll
            }()

            if #available(iOS 16.0, *) {
                let elevation: MKMapConfiguration.ElevationStyle = buildings ? .realistic : .flat
                let config: MKMapConfiguration
                switch mapTypeIndex {
                case 1:
                    config = MKImageryMapConfiguration(elevationStyle: elevation)
                case 2:
                    let c = MKHybridMapConfiguration(elevationStyle: elevation)
                    c.showsTraffic = traffic
                    c.pointOfInterestFilter = poi
                    config = c
                default:
                    // Standard map: apply emphasis style (iOS 16+).
                    // Use the persisted currentEmphasisStyle as the fallback rather than casting
                    // preferredConfiguration, which fails when switching through non-standard types.
                    let emphasisStyle = newEmphasisStyle ?? self.currentEmphasisStyle
                    if let new = newEmphasisStyle { self.currentEmphasisStyle = new }
                    let c = MKStandardMapConfiguration(elevationStyle: elevation)
                    c.showsTraffic = traffic
                    c.pointOfInterestFilter = poi
                    c.emphasisStyle = emphasisStyle == .muted
                        ? .muted
                        : MKStandardMapConfiguration.EmphasisStyle.default
                    config = c
                }
                self.preferredConfiguration = config
            } else {
                // Clamp to a valid index. Guard both ends: a negative value or a value
                // beyond the array length (e.g. a future Dart MapType added before the
                // plugin is updated) would otherwise crash. Standard (0) is the safest
                // fallback for unknown types.
                let safeIndex = mapTypeIndex >= 0 && mapTypeIndex < mapTypes.count ? mapTypeIndex : 0
                self.mapType = self.mapTypes[safeIndex]
                self.showsTraffic = traffic
                self.showsBuildings = buildings
                self.pointOfInterestFilter = poi
            }
            // Track the index that was actually applied so that state stays consistent
            // when a future option update omits mapType and falls back to currentMapTypeIndex.
            // On iOS 16+ the index was validated by the switch default; on iOS < 16 use safeIndex.
            if #available(iOS 16.0, *) {
                self.currentMapTypeIndex = mapTypeIndex
            } else {
                let appliedIndex = mapTypeIndex >= 0 && mapTypeIndex < mapTypes.count ? mapTypeIndex : 0
                self.currentMapTypeIndex = appliedIndex
            }

            // Selectable map features sit on MKMapView directly (iOS 16+).
            // bit 0=pointsOfInterest, bit 1=territories, bit 2=physicalFeatures.
            // Guard with `let` so unrelated option updates do not reset the user's setting.
            if #available(iOS 16.0, *), let mask = newSelectableFeatures {
                var features: MKMapFeatureOptions = []
                if mask & 1 != 0 { features.insert(.pointsOfInterest) }
                if mask & 2 != 0 { features.insert(.territories) }
                if mask & 4 != 0 { features.insert(.physicalFeatures) }
                self.selectableMapFeatures = features
            }
        }

        if let rotateGesturesEnabled = options.rotateGesturesEnabled {
            self.isRotateEnabled = rotateGesturesEnabled
        }

        if let scrollGesturesEnabled = options.scrollGesturesEnabled {
            self.isScrollEnabled = scrollGesturesEnabled
        }

        if let pitchGesturesEnabled = options.pitchGesturesEnabled {
            self.isPitchEnabled = pitchGesturesEnabled
        }

        if let zoomGesturesEnabled = options.zoomGesturesEnabled {
            self.isZoomEnabled = zoomGesturesEnabled
        }

        if let myLocationEnabled = options.myLocationEnabled {
            myLocationEnabled ? self.setUserLocation() : self.removeUserLocation()
        }

        if let myLocationButtonEnabled = options.myLocationButtonEnabled {
            self.mapTrackingButton(isVisible: myLocationButtonEnabled)
        }

        if let trackingMode = options.trackingMode {
            let index = Int(trackingMode)
            if index < userTrackingModes.count {
                self.setUserTrackingMode(userTrackingModes[index], animated: false)
            }
        }

        if let minMaxZoom = options.minMaxZoomPreference {
            if let minZoom = minMaxZoom.minZoom {
                self.minZoomLevel = minZoom
            }
            if let maxZoom = minMaxZoom.maxZoom {
                self.maxZoomLevel = maxZoom
            }
        }

        if let insetsSafeArea = options.insetsLayoutMarginsFromSafeArea {
            self.insetsLayoutMarginsFromSafeArea = insetsSafeArea
        }

        if let cameraTargetBounds = options.cameraTargetBounds {
            if let bounds = cameraTargetBounds.bounds {
                let sw = bounds.southwest.asCoordinate
                let ne = bounds.northeast.asCoordinate
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

        if let scaleEnabled = options.scaleEnabled {
            self.showsScale = scaleEnabled
        }
    }
    
    func setUserLocation() {
        let authorizationStatus: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }

        switch authorizationStatus {
        case .notDetermined:
            // Guard against requesting authorization a second time if a prompt is already showing.
            guard !pendingUserLocationEnabled else { return }
            // Store intent so the delegate can start location once the user grants permission.
            pendingUserLocationEnabled = true
            locationManager.requestWhenInUseAuthorization()

        case .authorizedAlways, .authorizedWhenInUse:
            startUpdatingUserLocation()

        default:
            break
        }
    }

    private func startUpdatingUserLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        self.showsUserLocation = true
    }

    func removeUserLocation() {
        pendingUserLocationEnabled = false
        locationManager.stopUpdatingLocation()
        self.showsUserLocation = false
    }
    
    // Functions used for the mapTrackingButton
    func mapTrackingButton(isVisible visible: Bool) {
        isMyLocationButtonShowing = visible
        if let _locationButton = self.viewWithTag(ButtonId.location.rawValue) {
           _locationButton.removeFromSuperview()
        }
        if visible {
            let buttonContainer = UIView()
            buttonContainer.translatesAutoresizingMaskIntoConstraints = false
            buttonContainer.widthAnchor.constraint(equalToConstant: 35).isActive = true
            buttonContainer.heightAnchor.constraint(equalToConstant: 35).isActive = true
            buttonContainer.layer.cornerRadius = 8
            buttonContainer.tag = ButtonId.location.rawValue
            buttonContainer.backgroundColor = .white
            let userTrackingButton = MKUserTrackingButton(mapView: self)
            userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
            buttonContainer.addSubview(userTrackingButton)
            userTrackingButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor).isActive = true
            userTrackingButton.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor).isActive = true
            self.addSubview(buttonContainer)
            buttonContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5 - self.layoutMargins.right).isActive = true
            // layoutMargins.top must be added in both cases so the button respects safe-area
            // insets consistently regardless of compass visibility.
            buttonContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: (self.showsCompass ? 50 : 5) + self.layoutMargins.top).isActive = true
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
        let tiltGestureUp = UISwipeGestureRecognizer(target: self, action: #selector(onMapGesture))
        tiltGestureUp.numberOfTouchesRequired = 2
        tiltGestureUp.direction = .up
        tiltGestureUp.delegate = self
        let tiltGestureDown = UISwipeGestureRecognizer(target: self, action: #selector(onMapGesture))
        tiltGestureDown.numberOfTouchesRequired = 2
        tiltGestureDown.direction = .down
        tiltGestureDown.delegate = self
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: nil)
        doubleTapGesture.numberOfTapsRequired = 2
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        tapGesture.require(toFail: doubleTapGesture)    // only recognize taps that are not involved in zooming
        self.addGestureRecognizer(panGesture)
        self.addGestureRecognizer(pinchGesture)
        self.addGestureRecognizer(rotateGesture)
        self.addGestureRecognizer(tiltGestureUp)
        self.addGestureRecognizer(tiltGestureDown)
        self.addGestureRecognizer(longTapGesture)
        self.addGestureRecognizer(doubleTapGesture)
        self.addGestureRecognizer(tapGesture)
    }
       
    @objc func onMapGesture(sender: UIGestureRecognizer) {
        self.updateCameraValues()
    }

    @objc func longTap(sender: UIGestureRecognizer){
        if sender.state == .began {
           let locationInView = sender.location(in: self)
           let locationOnMap = self.convert(locationInView, toCoordinateFrom: self)
           
           flutterApi?.onMapLongPress(
               position: PlatformLatLng(latitude: locationOnMap.latitude, longitude: locationOnMap.longitude),
               completion: pigeonLogOnError
           )
        }
    }

    @objc func onTap(tap: UITapGestureRecognizer) {
        if tap.state == .recognized {
            TouchHandler.handleMapTaps(tap: tap, overlays: self.overlays, flutterApi: self.flutterApi, in: self)
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

// MARK: - CLLocationManagerDelegate

extension FlutterMapView: CLLocationManagerDelegate {
    // iOS 14+ unified authorization callback.
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationChange(status: manager.authorizationStatus)
    }

    // Called on iOS 13 only. iOS 14+ uses locationManagerDidChangeAuthorization(_:) above.
    // When both are implemented, Apple guarantees only one fires per OS version.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleAuthorizationChange(status: status)
    }

    private func handleAuthorizationChange(status: CLAuthorizationStatus) {
        guard pendingUserLocationEnabled else { return }
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            pendingUserLocationEnabled = false
            startUpdatingUserLocation()
        case .denied, .restricted:
            // Clear the flag so a later setUserLocation() call re-evaluates correctly.
            pendingUserLocationEnabled = false
            flutterApi?.onPermissionDenied(completion: pigeonLogOnError)
        default:
            break
        }
    }
}
