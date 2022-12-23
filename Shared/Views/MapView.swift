//
//  MapView.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 16/07/20.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    private let mapZoomEdgeInsets = UIEdgeInsets(top: 30.0, left: 30.0, bottom: 30.0, right: 30.0)

    var locationManager = CLLocationManager()
    @Binding var showMapAlert: Bool
    @Binding var vehicles: [VehicleAnnotation]
    @Binding var stops: [StopBus]
    
    let mapView = MKMapView()
    let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    
    func makeUIView(context: Context) -> MKMapView {
        locationManager.delegate = context.coordinator
        mapView.delegate = context.coordinator
        updateOverlays(from: mapView)
        mapView.addAnnotations(self.stops)
        mapView.addAnnotations(self.vehicles)
        
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
         //Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, span: span)
            view.setRegion(region, animated: true)
        }
        
        for i in 0..<view.annotations.count {
            print("\nNew Vehicles count: \(view.annotations.count)\n")
            print("\nParadas count: \(stops.count)\n")
            
            for v in 0..<vehicles.count {
                if vehicles[v].coordinate.latitude != view.annotations[i].coordinate.latitude ||
                    vehicles[v].coordinate.longitude != view.annotations[i].coordinate.longitude {
                    mapView.addAnnotation(vehicles[v])
                    //moveBusWithAnimation(view.annotations[i], destinationCoordinate: vehicles[v].coordinate)
                }
            }
        }
        
        //updateVehiclePositionsIfNeeded(to: self.vehicles)
       // mapView.addAnnotations(self.vehicles)

        mapView.addAnnotations(self.stops)

        updateOverlays(from: view)
    }
    
    func updateVehiclePositionsIfNeeded(to newAnnotations: [VehicleAnnotation]) {
        if self.vehicles.isEmpty {
            mapView.addAnnotations(self.vehicles)
        } else {
            mapView.addAnnotations(self.vehicles)
            for v in 0..<vehicles.count {
                print("\nVehicles count: \(vehicles.count)\n")
                print("\nParadas count: \(stops.count)\n")
                for i in 0..<newAnnotations.count {
                    if vehicles[v].coordinate.latitude != newAnnotations[i].coordinate.latitude ||
                        vehicles[v].coordinate.longitude != newAnnotations[i].coordinate.longitude {
                        moveBusWithAnimation(vehicles[v], destinationCoordinate: newAnnotations[i].coordinate)
                    }
                }
            }
        }
    }
    
    private func updateOverlays(from mapView: MKMapView) {
        var points = vehicles.map { $0.coordinate }
        points.append(contentsOf: stops.map { $0.coordinate })
        
        let polyline = MKPolyline(coordinates: points, count: points.count)
        //mapView.addOverlay(polyline)
        guard !vehicles.isEmpty else { return }
        setMapZoomArea(map: mapView, polyline: polyline, edgeInsets: mapZoomEdgeInsets, animated: true)
    }
    
    private func setMapZoomArea(map: MKMapView, polyline: MKPolyline, edgeInsets: UIEdgeInsets, animated: Bool = false) {
        map.setVisibleMapRect(polyline.boundingMapRect, edgePadding: edgeInsets, animated: animated)
    }
    
    //MARK: Configura a duração da animação e o destino da coordenada
    fileprivate func moveBusWithAnimation(_ pointAnnotation: VehicleAnnotation ,destinationCoordinate : CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.6, animations: {
            pointAnnotation.coordinate = destinationCoordinate
        }, completion:  { success in
            if success {
                // handle a successfully ended animation
            } else {
                // handle a canceled animation, i.e move to destination immediately
                pointAnnotation.coordinate = destinationCoordinate
            }
        })
    }

    ///Use class Coordinator method
    func makeCoordinator() -> MapView.Coordinator {
      return Coordinator(mapView: self)
    }

    //MARK: - Core Location manager delegate
    class Coordinator: NSObject, CLLocationManagerDelegate, MKMapViewDelegate {
        
        var mapView: MapView
        
        init(mapView: MapView) {
            self.mapView = mapView
        }

      ///Switch between user location status
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch status {
            case .restricted:
                break
            case .denied:
                mapView.showMapAlert.toggle()
                return
            case .notDetermined:
                mapView.locationManager.requestWhenInUseAuthorization()
                return
            case .authorizedWhenInUse:
                return
            case .authorizedAlways:
                mapView.locationManager.allowsBackgroundLocationUpdates = true
                mapView.locationManager.pausesLocationUpdatesAutomatically = false
                return
            @unknown default:
                break
            }
            mapView.locationManager.startUpdatingLocation()
        }
        

        public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            print("mapView(_:viewFor:)")
            
            if (annotation is MKUserLocation) {
                return nil
            }
            
            else if annotation.isKind(of: VehicleAnnotation.self) {
                let identifier = "VehicleAnnotation"
                let annotationView = VehicleViewAnnotation(annotation: annotation, reuseIdentifier: identifier)
                annotationView.canShowCallout = true
                return annotationView
            } else {
                let identifier = "StopAnnotation"
                let annotationView = StopViewAnnotation(annotation: annotation, reuseIdentifier: identifier)
                annotationView.canShowCallout = true
                return annotationView
            }
        }
        
        // MARK: - Managing the Display of Overlays
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {

                let polylineRenderer = MKPolylineRenderer(overlay: polyline)
                polylineRenderer.strokeColor = .darkGray
                polylineRenderer.lineWidth = 2
                return polylineRenderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
}
    

//-23.5965911, -46.6867937
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(showMapAlert: .constant(false), vehicles: .constant([]), stops: .constant([]))
    }
}
