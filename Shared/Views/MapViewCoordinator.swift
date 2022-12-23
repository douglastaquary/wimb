//
//  MapViewCoordinator.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 16/07/20.
//

//import MapKit
//
//final class MapViewCoordinator: NSObject, MKMapViewDelegate {
//    private let map: MapView
//    
//    init(_ control: MapView) {
//        self.map = control
//    }
//    
//    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
//        map.centerCoordinate = mapView.centerCoordinate
//    }
//    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        let identifier = "Vehicle"
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//        if annotationView == nil {
//            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            annotationView?.canShowCallout = true
//            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//            
//        } else {
//            annotationView?.annotation = annotation
//        }
//        
//        return annotationView
//    }
//    
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        guard let placemark = view.annotation as? MKPointAnnotation else {return}
//        map.selectedPlace = placemark
//        map.showingPlaceDetails = true
//    }
//    
//    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
//        if let annotationView = views.first, let annotation = annotationView.annotation {
//            if annotation is MKUserLocation {
//                let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
//                mapView.setRegion(region, animated: true)
//            }
//        }
//    }
//    
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        let renderer = MKPolylineRenderer(overlay: overlay)
//        renderer.strokeColor = .blue
//        renderer.lineWidth = 3.0
//        return renderer
//    }
//}
