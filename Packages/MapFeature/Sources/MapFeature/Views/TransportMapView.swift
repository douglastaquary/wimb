//
//  TransportMapView.swift
//  MapFeature
//

import Combine
import MapKit
import SwiftUI
import TransportEngine
import WIMBCore

/// Mapa full-screen com veículos animados, rota e enquadramento acima do bottom sheet (iOS 16).
public struct TransportMapView: View {
    @ObservedObject private var trackingState: TrackingState
    @State private var vehicleMotions: [UUID: VehicleMotion] = [:]
    @State private var stopAnnotations: [TransportMapAnnotation] = []
    @State private var refocusGeneration = 0
    @State private var livePrimaryVehicleID: UUID?

    private let bottomSheetRatio: CGFloat
    private let bottomInsetPoints: CGFloat?
    private let routeStyle: MapRouteStyle
    @Binding private var refocusRequest: Bool

    public init(
        trackingState: TrackingState,
        routeStyle: MapRouteStyle = .planner,
        bottomSheetRatio: CGFloat = 0.42,
        bottomInsetPoints: CGFloat? = nil,
        refocusRequest: Binding<Bool> = .constant(false),
        initialRegion: MKCoordinateRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -23.550520, longitude: -46.633308),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    ) {
        self.trackingState = trackingState
        self.routeStyle = routeStyle
        self.bottomSheetRatio = bottomSheetRatio
        self.bottomInsetPoints = bottomInsetPoints
        self._refocusRequest = refocusRequest
    }

    public var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { context in
                let followCenter = liveFollowCenter(at: context.date)
                TransportMapRepresentable(
                    annotations: annotations(at: context.date),
                    routeCoordinates: routeCoordinates,
                    routeStyle: routeStyle,
                    bottomInset: bottomInsetPoints ?? geometry.size.height * bottomSheetRatio,
                    refocusGeneration: refocusGeneration,
                    cameraFollowCenter: routeStyle == .live ? followCenter : nil,
                    cameraFollowSpan: routeStyle == .live ? LiveMapFocus.streetLevelSpan : nil,
                    userLocation: trackingState.locationManager.currentLocation?.clCoordinate
                )
            }
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            trackingState.locationManager.requestPermission()
            trackingState.locationManager.startTracking()
            resolveLivePrimaryVehicle()
            syncFromState(animated: false, refocus: true)
            Task { await trackingState.refreshContext() }
        }
        .onChange(of: trackingState.vehicles) { _ in
            let hadPrimary = livePrimaryVehicleID != nil
            resolveLivePrimaryVehicle()
            if routeStyle == .live {
                syncFromState(animated: true, refocus: !hadPrimary && livePrimaryVehicleID != nil)
            } else {
                syncFromState(animated: true, refocus: true)
            }
        }
        .onChange(of: trackingState.arrivals) { _ in
            syncStops()
            if routeStyle != .live { triggerRefocus() }
        }
        .onChange(of: trackingState.selectedLine?.id) { _ in
            livePrimaryVehicleID = nil
            resolveLivePrimaryVehicle()
            syncFromState(animated: true, refocus: true)
        }
        .onChange(of: refocusRequest) { requested in
            guard requested else { return }
            triggerRefocus()
            refocusRequest = false
        }
        .onReceive(trackingState.locationManager.$currentLocation) { _ in
            guard routeStyle == .live, livePrimaryVehicleID == nil else { return }
            resolveLivePrimaryVehicle()
            if livePrimaryVehicleID != nil {
                syncFromState(animated: false, refocus: true)
            }
        }
    }

    private var routeCoordinates: [CLLocationCoordinate2D] {
        guard trackingState.selectedLine != nil, routeStyle.showsRoutePolyline else { return [] }

        let vehicles = currentVehicles
        return RouteLineBuilder.routeCoordinates(stops: trackingState.arrivals, vehicles: vehicles)
    }

    private var currentVehicles: [Vehicle] {
        if let lineId = trackingState.selectedLine?.id {
            return trackingState.vehicles(for: lineId)
        }
        return trackingState.vehicles
    }

    private func liveFollowCenter(at date: Date) -> CLLocationCoordinate2D? {
        guard routeStyle == .live, let primaryID = livePrimaryVehicleID else { return nil }
        if let motion = vehicleMotions[primaryID] {
            return motion.coordinate(at: date)
        }
        return currentVehicles.first(where: { $0.id == primaryID })?.coordinate.clCoordinate
    }

    private func annotations(at date: Date) -> [TransportMapAnnotation] {
        vehicleMotions.values.map { motion in
            TransportMapAnnotation(
                id: "vehicle-\(motion.id.uuidString)",
                kind: .vehicle,
                coordinate: motion.coordinate(at: date),
                vehiclePrefix: motion.prefix,
                vehicleHeading: motion.displayHeading(at: date)
            )
        }
    }

    private func syncFromState(animated: Bool, refocus: Bool) {
        vehicleMotions = VehicleMotionTracker.merge(
            existing: vehicleMotions,
            vehicles: currentVehicles,
            animated: animated
        )
        syncStops()
        if refocus { triggerRefocus() }
    }

    /// Escolhe o ônibus principal uma vez: mais próximo do usuário (≤ 2 km) ou primeiro da API.
    private func resolveLivePrimaryVehicle() {
        guard routeStyle == .live else { return }

        if let id = livePrimaryVehicleID {
            if currentVehicles.contains(where: { $0.id == id }) {
                return
            }
            livePrimaryVehicleID = nil
        }

        guard let primary = LiveMapFocus.primaryVehicle(
            in: currentVehicles,
            userLocation: trackingState.locationManager.currentLocation?.clCoordinate
        ) else { return }

        livePrimaryVehicleID = primary.id
    }

    private func syncStops() {
        guard trackingState.selectedLine != nil, routeStyle != .live else {
            stopAnnotations = []
            return
        }
        stopAnnotations = trackingState.arrivals.map {
            TransportMapAnnotation(stop: StopMapItem(stop: $0))
        }
    }

    private func triggerRefocus() {
        refocusGeneration += 1
    }
}
