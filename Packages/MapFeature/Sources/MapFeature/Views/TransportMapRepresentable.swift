//
//  TransportMapRepresentable.swift
//  MapFeature
//

import MapKit
import SwiftUI
import UIKit
import WIMBCore

struct TransportMapRepresentable: UIViewRepresentable {
    let annotations: [TransportMapAnnotation]
    let routeCoordinates: [CLLocationCoordinate2D]
    let routeStyle: MapRouteStyle
    let bottomInset: CGFloat
    let refocusGeneration: Int
    let cameraFollowCenter: CLLocationCoordinate2D?
    let cameraFollowSpan: MKCoordinateSpan?
    let userLocation: CLLocationCoordinate2D?

    init(
        annotations: [TransportMapAnnotation],
        routeCoordinates: [CLLocationCoordinate2D],
        routeStyle: MapRouteStyle = .planner,
        bottomInset: CGFloat,
        refocusGeneration: Int,
        cameraFollowCenter: CLLocationCoordinate2D? = nil,
        cameraFollowSpan: MKCoordinateSpan? = nil,
        userLocation: CLLocationCoordinate2D? = nil
    ) {
        self.annotations = annotations
        self.routeCoordinates = routeCoordinates
        self.routeStyle = routeStyle
        self.bottomInset = bottomInset
        self.refocusGeneration = refocusGeneration
        self.cameraFollowCenter = cameraFollowCenter
        self.cameraFollowSpan = cameraFollowSpan
        self.userLocation = userLocation
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false
        mapView.pointOfInterestFilter = .excludingAll
        mapView.isRotateEnabled = false
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.parent = self
        mapView.layoutMargins = UIEdgeInsets(top: 64, left: 16, bottom: bottomInset + 16, right: 16)

        updateUserLocationVisibility(on: mapView)
        updateAnnotations(on: mapView)
        updateRoute(on: mapView)

        if routeStyle == .live {
            updateLiveCamera(on: mapView, coordinator: context.coordinator)
        } else if refocusGeneration != context.coordinator.appliedRefocusGeneration {
            context.coordinator.appliedRefocusGeneration = refocusGeneration
            focusPlannerContent(on: mapView)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    private func updateUserLocationVisibility(on mapView: MKMapView) {
        guard routeStyle == .live else {
            mapView.showsUserLocation = true
            return
        }

        let stubVehicles = annotations
            .filter { $0.kind == .vehicle }
            .map {
                Vehicle(
                    prefix: "0",
                    accessible: false,
                    lastUpdateTime: "",
                    coordinate: Coordinate($0.coordinate)
                )
            }

        if let target = LiveMapFocus.target(
            vehicles: stubVehicles,
            userLocation: userLocation ?? mapView.userLocation.location?.coordinate
        ) {
            mapView.showsUserLocation = target.showsUserLocation
        } else {
            mapView.showsUserLocation = false
        }
    }

    private func updateLiveCamera(on mapView: MKMapView, coordinator: Coordinator) {
        guard let center = cameraFollowCenter, let span = cameraFollowSpan else { return }

        let adjustedCenter = offsetCenter(center, on: mapView)
        let region = MKCoordinateRegion(center: adjustedCenter, span: span)

        if refocusGeneration != coordinator.appliedRefocusGeneration {
            coordinator.appliedRefocusGeneration = refocusGeneration
            coordinator.lockedSpan = span
            coordinator.liveZoomApplied = true
            mapView.setRegion(region, animated: false)
            return
        }

        if !coordinator.liveZoomApplied {
            coordinator.lockedSpan = span
            coordinator.liveZoomApplied = true
            mapView.setRegion(region, animated: false)
            return
        }

        let locked = MKCoordinateRegion(center: adjustedCenter, span: coordinator.lockedSpan ?? span)
        let deltaLat = abs(mapView.region.center.latitude - adjustedCenter.latitude)
        let deltaLon = abs(mapView.region.center.longitude - adjustedCenter.longitude)

        if deltaLat > 0.000015 || deltaLon > 0.000015 {
            mapView.setCenter(adjustedCenter, animated: false)
            if let lockedSpan = coordinator.lockedSpan,
               abs(mapView.region.span.latitudeDelta - lockedSpan.latitudeDelta) > 0.0005 {
                mapView.setRegion(locked, animated: false)
            }
        }
    }

    /// Desloca o centro para cima na tela, mantendo o ônibus visível acima do card inferior.
    private func offsetCenter(_ center: CLLocationCoordinate2D, on mapView: MKMapView) -> CLLocationCoordinate2D {
        guard bottomInset > 0 else { return center }

        let busPoint = mapView.convert(center, toPointTo: mapView)
        let offsetPoint = CGPoint(x: busPoint.x, y: busPoint.y + bottomInset * 0.22)
        return mapView.convert(offsetPoint, toCoordinateFrom: mapView)
    }

    private func updateAnnotations(on mapView: MKMapView) {
        let existing = mapView.annotations.compactMap { $0 as? TransportPointAnnotation }
        let existingIDs = Set(existing.map(\.annotationID))
        let newIDs = Set(annotations.map(\.id))

        for annotation in existing where !newIDs.contains(annotation.annotationID) {
            mapView.removeAnnotation(annotation)
        }

        for item in annotations where !existingIDs.contains(item.id) {
            mapView.addAnnotation(TransportPointAnnotation(item: item))
        }

        for annotation in mapView.annotations.compactMap({ $0 as? TransportPointAnnotation }) {
            guard let updated = annotations.first(where: { $0.id == annotation.annotationID }) else { continue }

            annotation.heading = updated.vehicleHeading
            annotation.kind = updated.kind
            annotation.title = updated.vehiclePrefix ?? updated.stopName

            if coordinatesDiffer(annotation.coordinate, updated.coordinate) {
                UIView.animate(withDuration: 0.28, delay: 0, options: [.curveLinear, .allowUserInteraction]) {
                    annotation.coordinate = updated.coordinate
                }
            }

            if updated.kind == .vehicle, let view = mapView.view(for: annotation) {
                view.transform = CGAffineTransform(rotationAngle: CGFloat(updated.vehicleHeading))
            }
        }
    }

    private func updateRoute(on mapView: MKMapView) {
        mapView.overlays.compactMap { $0 as? MKPolyline }.forEach { mapView.removeOverlay($0) }
        guard routeStyle.showsRoutePolyline, routeCoordinates.count >= 2 else { return }
        let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
        mapView.addOverlay(polyline)
    }

    private func focusPlannerContent(on mapView: MKMapView) {
        var points = annotations.map(\.coordinate)
        points.append(contentsOf: routeCoordinates)
        guard !points.isEmpty else { return }

        var rect = MKMapRect.null
        for coordinate in points {
            let point = MKMapPoint(coordinate)
            rect = rect.union(MKMapRect(x: point.x, y: point.y, width: 1, height: 1))
        }

        mapView.setVisibleMapRect(
            rect,
            edgePadding: UIEdgeInsets(top: 72, left: 28, bottom: bottomInset + 32, right: 28),
            animated: true
        )
    }

    private func coordinatesDiffer(_ lhs: CLLocationCoordinate2D, _ rhs: CLLocationCoordinate2D) -> Bool {
        abs(lhs.latitude - rhs.latitude) > 0.000001
            || abs(lhs.longitude - rhs.longitude) > 0.000001
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: TransportMapRepresentable
        var appliedRefocusGeneration = -1
        var lockedSpan: MKCoordinateSpan?
        var liveZoomApplied = false

        init(parent: TransportMapRepresentable) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let point = annotation as? TransportPointAnnotation else { return nil }

            switch point.kind {
            case .vehicle:
                let identifier = "vehicle-\(point.annotationID)"
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                    ?? MKAnnotationView(annotation: point, reuseIdentifier: identifier)
                view.annotation = point
                view.canShowCallout = false
                view.image = BusMarkerImage.make(size: CGSize(width: 36, height: 36))
                view.centerOffset = CGPoint(x: 0, y: -10)
                view.transform = CGAffineTransform(rotationAngle: CGFloat(point.heading))
                return view
            case .stop:
                let identifier = "stop"
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                    as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: point, reuseIdentifier: identifier)
                view.annotation = point
                view.markerTintColor = UIColor.systemGreen
                view.glyphImage = UIImage(systemName: "figure.wave")
                view.canShowCallout = true
                return view
            case .routeArrow:
                return nil
            }
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else {
                return MKOverlayRenderer(overlay: overlay)
            }

            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = parent.routeStyle.strokeColor
            renderer.lineWidth = parent.routeStyle.lineWidth
            renderer.lineCap = .round
            renderer.lineJoin = .round
            return renderer
        }
    }
}

final class TransportPointAnnotation: NSObject, MKAnnotation {
    let annotationID: String
    dynamic var coordinate: CLLocationCoordinate2D
    var kind: TransportMapAnnotation.Kind
    var heading: Double
    var title: String?

    init(item: TransportMapAnnotation) {
        self.annotationID = item.id
        self.coordinate = item.coordinate
        self.kind = item.kind
        self.heading = item.vehicleHeading
        self.title = item.vehiclePrefix ?? item.stopName
    }
}

enum BusMarkerImage {
    static func make(size: CGSize) -> UIImage? {
        if let asset = UIImage(named: "bus_top", in: .main, compatibleWith: nil) {
            return asset
        }
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        return UIImage(systemName: "bus.fill", withConfiguration: config)?
            .withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
    }
}

enum RouteArrowMarkerImage {
    static func make(size: CGSize) -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        return UIImage(systemName: "arrowtriangle.up.fill", withConfiguration: config)?
            .withTintColor(UIColor(red: 1.0, green: 0.843, blue: 0.0, alpha: 1.0), renderingMode: .alwaysOriginal)
    }
}
