//
//  TrackingState.swift
//  TransportEngine
//

import Combine
import Foundation
import NetworkClient
import WIMBCore

/// Estado observável consumido pelas views SwiftUI (iOS 16+).
@MainActor
public final class TrackingState: ObservableObject {
    @Published public private(set) var trackedLines: [TransportLine] = []
    @Published public private(set) var vehicles: [Vehicle] = []
    @Published public private(set) var vehiclesByLine: [Int: [Vehicle]] = [:]
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: WIMBError?
    @Published public private(set) var lastUpdate: Date?
    @Published public private(set) var searchResults: [TransportLine] = []
    @Published public private(set) var selectedLine: TransportLine?
    @Published public private(set) var arrivals: [Stop] = []
    @Published public private(set) var isLoadingArrivals = false
    @Published public private(set) var weather: WeatherSnapshot?
    @Published public private(set) var nearbyMetro: [NearbyMetroStop] = []
    @Published public private(set) var isLoadingContext = false

    public let locationManager: LocationManager

    private let client: TransportService
    private let engine: TransportEngine
    private let weatherClient: WeatherClient
    private let metroService: MetroNearbyService
    private let arrivalPredictor: SmartArrivalPredictor

    public init(
        client: TransportService,
        cacheManager: CacheManager = InMemoryCacheManager(),
        locationManager: LocationManager = LocationManager(),
        weatherClient: WeatherClient = WeatherClient(),
        metroService: MetroNearbyService = MetroNearbyService(),
        arrivalPredictor: SmartArrivalPredictor = SmartArrivalPredictor()
    ) {
        self.client = client
        self.engine = TransportEngine(client: client, cacheManager: cacheManager)
        self.locationManager = locationManager
        self.weatherClient = weatherClient
        self.metroService = metroService
        self.arrivalPredictor = arrivalPredictor
        bindEngineUpdates()
        bindLocationUpdates()

        Task {
            await refreshContext()
        }
    }

    public var totalVehicleCount: Int {
        vehicles.count
    }

    public var isTracking: Bool {
        !trackedLines.isEmpty
    }

    /// Intervalo de polling do motor de rastreamento (segundos).
    public var pollingInterval: TimeInterval {
        TransportEngine.defaultPollingInterval
    }

    public func searchLines(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchResults = []
            error = nil
            return
        }

        isLoading = true
        error = nil

        do {
            searchResults = try await client.searchLines(query: trimmed)
        } catch let wimbError as WIMBError {
            error = wimbError
            searchResults = []
        } catch {
            self.error = .networkError(underlying: error)
            searchResults = []
        }

        isLoading = false
    }

    public func trackLine(_ line: TransportLine) async {
        guard !trackedLines.contains(where: { $0.id == line.id }) else { return }

        isLoading = true
        error = nil

        do {
            try await engine.startTracking(lineId: line.id)
            trackedLines.append(line)
            await syncVehiclesFromEngine()
            lastUpdate = Date()
            await selectLine(line)
        } catch let wimbError as WIMBError {
            error = wimbError
        } catch {
            self.error = .networkError(underlying: error)
        }

        isLoading = false
    }

    public func untrackLine(_ lineId: Int) async {
        await engine.stopTracking(lineId: lineId)
        trackedLines.removeAll { $0.id == lineId }

        if selectedLine?.id == lineId {
            selectedLine = nil
            arrivals = []
        }

        await syncVehiclesFromEngine()
    }

    public func stopAll() async {
        await engine.stopAllTracking()
        trackedLines.removeAll()
        vehicles.removeAll()
        vehiclesByLine.removeAll()
    }

    public func refresh() async {
        isLoading = true
        await engine.refresh()
        await syncVehiclesFromEngine()
        await refreshContext()
        lastUpdate = Date()
        isLoading = false
    }

    /// Atualiza clima e metrô com base na localização do usuário.
    public func refreshContext() async {
        let location = Self.contextLocation(current: locationManager.currentLocation)
        isLoadingContext = true

        nearbyMetro = metroService.nearbyStations(to: location)

        do {
            weather = try await weatherClient.currentWeather(at: location)
        } catch {
            // Clima é complementar — não bloqueia o fluxo principal.
            weather = nil
        }

        isLoadingContext = false
    }

    /// Localização para clima/metrô: GPS em SP ou centro (Sé) como fallback.
    static func contextLocation(current: Coordinate?) -> Coordinate {
        guard let current = current else {
            return Coordinate.saoPauloDefault
        }

        if MetroNearbyService.isInSaoPauloMetroRegion(current) {
            return current
        }

        // Simulador fora de SP (ex.: Cupertino) ou GPS indisponível na região.
        return Coordinate.saoPauloDefault
    }

    public func vehicles(for lineId: Int) -> [Vehicle] {
        vehiclesByLine[lineId] ?? []
    }

    public func selectLine(_ line: TransportLine?) async {
        selectedLine = line

        guard let line = line else {
            arrivals = []
            return
        }

        await loadArrivals(for: line.id)
    }

    public func loadArrivals(for lineId: Int) async {
        isLoadingArrivals = true
        error = nil

        do {
            arrivals = try await client.fetchArrivals(lineId: lineId)
        } catch let wimbError as WIMBError {
            error = wimbError
            arrivals = []
        } catch {
            self.error = .networkError(underlying: error)
            arrivals = []
        }

        isLoadingArrivals = false
    }

    public func predictions(to destination: Coordinate) -> [ArrivalPrediction] {
        let context = PredictionContext(weather: weather)
        return vehicles.map { arrivalPredictor.predict(vehicle: $0, to: destination, context: context) }
    }

    public func smartPrediction(for vehicle: Vehicle, at stop: Stop) -> ArrivalPrediction {
        let context = PredictionContext(
            weather: weather,
            spTransForecast: vehicle.arrivalForecast
        )
        return arrivalPredictor.predict(
            vehicle: vehicle,
            to: stop.coordinate,
            context: context
        )
    }

    private func bindEngineUpdates() {
        let engine = self.engine
        let token = EngineUpdateToken(owner: self)
        Task.detached {
            await engine.setOnVehiclesUpdated { updated in
                token.deliver(updated)
            }
        }
    }

    private func bindLocationUpdates() {
        locationManager.$currentLocation
            .compactMap { $0 }
            .removeDuplicates()
            .debounce(for: .seconds(2), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                Task { await self?.refreshContext() }
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    private func syncVehiclesFromEngine() async {
        let tracked = await engine.trackedLines
        var byLine: [Int: [Vehicle]] = [:]

        for lineId in tracked {
            byLine[lineId] = await engine.vehicles(for: lineId)
        }

        vehiclesByLine = byLine
        vehicles = await engine.allVehicles()
    }

    fileprivate func applyVehicleUpdates(_ updated: [Int: [Vehicle]]) {
        vehiclesByLine = updated
        vehicles = updated.values.flatMap { $0 }
        lastUpdate = Date()
    }
}

private final class EngineUpdateToken: @unchecked Sendable {
    private weak var owner: TrackingState?

    init(owner: TrackingState) {
        self.owner = owner
    }

    func deliver(_ updated: [Int: [Vehicle]]) {
        DispatchQueue.main.async { [weak owner] in
            owner?.applyVehicleUpdates(updated)
        }
    }
}
