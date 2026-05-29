//
//  DirectionsState.swift
//  TransportEngine
//

import Foundation
import NetworkClient
import WIMBCore

/// Estado observável da aba Direções (Fase 6.5).
@MainActor
public final class DirectionsState: ObservableObject {
    @Published public private(set) var placeSearchResults: [TripPlace] = []
    @Published public var origin: TripPlace?
    @Published public var destination: TripPlace?
    @Published public var departureOffsetMinutes: Int = 0
    @Published public private(set) var suggestions: [RouteSuggestion] = []
    @Published public private(set) var isSearchingPlaces = false
    @Published public private(set) var isPlanning = false
    @Published public private(set) var error: WIMBError?

    public let locationManager: LocationManager

    private let client: TransportService
    private let suggestionEngine: RouteSuggestionEngine
    private let weatherClient: WeatherClient
    private var weather: WeatherSnapshot?

    public init(
        client: TransportService,
        locationManager: LocationManager = LocationManager(),
        weatherClient: WeatherClient = WeatherClient()
    ) {
        self.client = client
        self.locationManager = locationManager
        self.weatherClient = weatherClient
        self.suggestionEngine = RouteSuggestionEngine(client: client)
    }

    public func searchPlaces(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            placeSearchResults = []
            error = nil
            return
        }

        isSearchingPlaces = true
        error = nil

        do {
            placeSearchResults = try await PlaceSearchService.search(query: trimmed)
        } catch {
            self.error = .networkError(underlying: error)
            placeSearchResults = []
        }

        isSearchingPlaces = false
    }

    public func resolveOriginFromLocation(defaultName: String) async {
        locationManager.requestPermission()
        locationManager.startTracking()

        let coordinate = TrackingState.contextLocation(current: locationManager.currentLocation)
        origin = TripPlace(
            id: "current-location",
            name: defaultName,
            subtitle: nil,
            coordinate: coordinate
        )
    }

    public func swapEndpoints() {
        guard let destination else { return }
        let previousOrigin = origin
        origin = destination
        if let previousOrigin {
            self.destination = previousOrigin
        } else {
            self.destination = nil
        }
    }

    public func planRoutes() async {
        guard let origin, let destination else {
            error = .noData
            return
        }

        isPlanning = true
        error = nil
        suggestions = []

        await refreshWeather(at: origin.coordinate)

        let context = PredictionContext(weather: weather)

        do {
            suggestions = try await suggestionEngine.suggest(
                from: origin.coordinate,
                to: destination.coordinate,
                context: context
            )
        } catch let wimbError as WIMBError {
            error = wimbError
        } catch {
            self.error = .networkError(underlying: error)
        }

        isPlanning = false
    }

    public func clearSuggestions() {
        suggestions = []
    }

    private func refreshWeather(at coordinate: Coordinate) async {
        do {
            weather = try await weatherClient.currentWeather(at: coordinate)
        } catch {
            weather = nil
        }
    }
}
