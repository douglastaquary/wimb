//
//  StationsMapRepresentable.swift
//  MapFeature
//

import MapKit
import SwiftUI
import WIMBCore

/// Mapa com pins de paradas (aba Estações).
public struct StationsMapView: View {
    private let stops: [Stop]
    private let selectedStopId: Int?
    private let userCoordinate: Coordinate?
    private let bottomInset: CGFloat
    private let onSelectStop: ((Stop) -> Void)?
    @Binding private var refocusRequest: Bool

    public init(
        stops: [Stop],
        selectedStopId: Int? = nil,
        userCoordinate: Coordinate? = nil,
        bottomInset: CGFloat = 120,
        refocusRequest: Binding<Bool> = .constant(false),
        onSelectStop: ((Stop) -> Void)? = nil
    ) {
        self.stops = stops
        self.selectedStopId = selectedStopId
        self.userCoordinate = userCoordinate
        self.bottomInset = bottomInset
        self.onSelectStop = onSelectStop
        self._refocusRequest = refocusRequest
    }

    public var body: some View {
        StationsMapRepresentable(
            stops: stops,
            selectedStopId: selectedStopId,
            userCoordinate: userCoordinate,
            bottomInset: bottomInset,
            onSelectStop: onSelectStop,
            refocusRequest: $refocusRequest
        )
        .ignoresSafeArea(edges: .top)
    }
}

private struct StationsMapRepresentable: UIViewRepresentable {
    let stops: [Stop]
    let selectedStopId: Int?
    let userCoordinate: Coordinate?
    let bottomInset: CGFloat
    let onSelectStop: ((Stop) -> Void)?
    @Binding var refocusRequest: Bool

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.pointOfInterestFilter = .excludingAll
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.parent = self
        mapView.layoutMargins = UIEdgeInsets(top: 72, left: 16, bottom: bottomInset + 16, right: 16)

        let existing = mapView.annotations.compactMap { $0 as? StopPointAnnotation }
        let existingIDs = Set(existing.map(\.stopId))
        let newIDs = Set(stops.map(\.id))

        for annotation in existing where !newIDs.contains(annotation.stopId) {
            mapView.removeAnnotation(annotation)
        }

        for stop in stops where !existingIDs.contains(stop.id) {
            mapView.addAnnotation(StopPointAnnotation(stop: stop, isSelected: stop.id == selectedStopId))
        }

        for annotation in mapView.annotations.compactMap({ $0 as? StopPointAnnotation }) {
            annotation.isSelectedStop = annotation.stopId == selectedStopId
        }

        if refocusRequest {
            focus(on: mapView)
            DispatchQueue.main.async {
                refocusRequest = false
            }
        } else if context.coordinator.needsInitialFocus {
            focus(on: mapView)
            context.coordinator.needsInitialFocus = false
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    private func focus(on mapView: MKMapView) {
        var coordinates = stops.map { $0.coordinate.clCoordinate }
        if let userCoordinate = userCoordinate {
            coordinates.append(userCoordinate.clCoordinate)
        }

        guard !coordinates.isEmpty else { return }

        var rect = MKMapRect.null
        for coordinate in coordinates {
            let point = MKMapPoint(coordinate)
            rect = rect.union(MKMapRect(x: point.x, y: point.y, width: 0.01, height: 0.01))
        }

        mapView.setVisibleMapRect(
            rect,
            edgePadding: UIEdgeInsets(top: 80, left: 24, bottom: bottomInset + 24, right: 24),
            animated: true
        )
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: StationsMapRepresentable
        var needsInitialFocus = true

        init(parent: StationsMapRepresentable) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let stopAnnotation = annotation as? StopPointAnnotation else { return nil }

            let identifier = "stopPin"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: stopAnnotation, reuseIdentifier: identifier)
            view.annotation = stopAnnotation
            view.canShowCallout = true
            view.markerTintColor = stopAnnotation.isSelectedStop ? UIColor.systemBlue : UIColor.systemGreen
            view.glyphImage = UIImage(systemName: "figure.wave")
            return view
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let stopAnnotation = view.annotation as? StopPointAnnotation else { return }
            guard let stop = parent.stops.first(where: { $0.id == stopAnnotation.stopId }) else { return }
            parent.onSelectStop?(stop)
            mapView.deselectAnnotation(stopAnnotation, animated: false)
        }
    }
}

private final class StopPointAnnotation: NSObject, MKAnnotation {
    let stopId: Int
    dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    var isSelectedStop: Bool

    init(stop: Stop, isSelected: Bool) {
        self.stopId = stop.id
        self.coordinate = stop.coordinate.clCoordinate
        self.title = stop.displayTitle
        self.isSelectedStop = isSelected
    }
}
