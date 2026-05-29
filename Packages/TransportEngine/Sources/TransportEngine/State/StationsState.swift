//
//  StationsState.swift
//  TransportEngine
//

import Combine
import Foundation
import WIMBCore

/// Estado observável da aba Estações (Fase 6.4).
@MainActor
public final class StationsState: ObservableObject {
    @Published public private(set) var mapStops: [Stop] = []
    @Published public private(set) var searchResults: [Stop] = []
    @Published public private(set) var selectedStop: Stop?
    @Published public private(set) var stopDetail: StopDetail?
    @Published public private(set) var isLoading = false
    @Published public private(set) var isLoadingDetail = false
    @Published public private(set) var error: WIMBError?

    public let locationManager: LocationManager

    private let client: TransportService

    public init(
        client: TransportService,
        locationManager: LocationManager = LocationManager()
    ) {
        self.client = client
        self.locationManager = locationManager
    }

    public func searchStops(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchResults = []
            error = nil
            return
        }

        isLoading = true
        error = nil

        do {
            searchResults = try await client.searchStops(query: trimmed)
            mapStops = searchResults
        } catch let wimbError as WIMBError {
            error = wimbError
            searchResults = []
        } catch {
            self.error = .networkError(underlying: error)
            searchResults = []
        }

        isLoading = false
    }

    public func loadNearbyStops(fallbackStops: [Stop] = []) async {
        isLoading = true
        error = nil

        locationManager.requestPermission()
        locationManager.startTracking()

        let coordinate = TrackingState.contextLocation(current: locationManager.currentLocation)
        let query = await ReverseGeocoder.streetQuery(for: coordinate)

        do {
            let nearby = try await client.fetchNearbyStops(near: coordinate, query: query)
            if nearby.isEmpty, !fallbackStops.isEmpty {
                mapStops = NearbyStopsFilter.filter(fallbackStops, near: coordinate)
            } else {
                mapStops = nearby
            }
            searchResults = mapStops
        } catch let wimbError as WIMBError {
            error = wimbError
            mapStops = NearbyStopsFilter.filter(fallbackStops, near: coordinate)
            searchResults = mapStops
        } catch {
            self.error = .networkError(underlying: error)
            mapStops = NearbyStopsFilter.filter(fallbackStops, near: coordinate)
            searchResults = mapStops
        }

        isLoading = false
    }

    public func loadStopDetail(stopId: Int) async {
        isLoadingDetail = true
        error = nil

        do {
            stopDetail = try await client.fetchStopDetail(stopId: stopId)
            selectedStop = stopDetail?.stop
        } catch let wimbError as WIMBError {
            error = wimbError
            stopDetail = nil
        } catch {
            self.error = .networkError(underlying: error)
            stopDetail = nil
        }

        isLoadingDetail = false
    }

    public func selectStop(_ stop: Stop?) {
        selectedStop = stop
        if stop == nil {
            stopDetail = nil
        }
    }
}
