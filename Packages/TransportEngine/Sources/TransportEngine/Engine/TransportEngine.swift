//
//  TransportEngine.swift
//  TransportEngine
//

import Foundation
import WIMBCore

/// Orquestrador de rastreamento de múltiplas linhas em tempo real.
public actor TransportEngine {
    public static let maxTrackedLines = 10
    public static let minimumPollingInterval: TimeInterval = 5
    public static let defaultPollingInterval: TimeInterval = 10

    private let client: TransportService
    private let cacheManager: CacheManager
    private var trackedLineIds: Set<Int> = []
    private var vehiclesByLine: [Int: [Vehicle]] = [:]
    private var pollingTask: Task<Void, Never>?
    private var isPolling = false

    public var pollingInterval: TimeInterval = defaultPollingInterval
    public var onVehiclesUpdated: (@Sendable ([Int: [Vehicle]]) -> Void)?

    public init(
        client: TransportService,
        cacheManager: CacheManager = InMemoryCacheManager()
    ) {
        self.client = client
        self.cacheManager = cacheManager
    }

    public var trackedLines: Set<Int> {
        trackedLineIds
    }

    public var polling: Bool {
        isPolling
    }

    public func startTracking(lineId: Int) async throws {
        guard trackedLineIds.count < Self.maxTrackedLines || trackedLineIds.contains(lineId) else {
            throw WIMBError.tooManyTrackedLines(max: Self.maxTrackedLines)
        }

        trackedLineIds.insert(lineId)

        do {
            let vehicles = try await client.fetchVehiclePositions(lineId: lineId)
            vehiclesByLine[lineId] = vehicles
            await cacheManager.saveVehicles(vehicles, for: lineId)
        } catch {
            if let cached = await cacheManager.loadVehicles(for: lineId) {
                vehiclesByLine[lineId] = cached
            } else {
                trackedLineIds.remove(lineId)
                throw error
            }
        }

        if !isPolling {
            startPolling()
        }

        notifyUpdate()
    }

    public func stopTracking(lineId: Int) {
        trackedLineIds.remove(lineId)
        vehiclesByLine.removeValue(forKey: lineId)

        if trackedLineIds.isEmpty {
            stopPolling()
        }

        notifyUpdate()
    }

    public func stopAllTracking() {
        trackedLineIds.removeAll()
        vehiclesByLine.removeAll()
        stopPolling()
        notifyUpdate()
    }

    public func vehicles(for lineId: Int) -> [Vehicle] {
        vehiclesByLine[lineId] ?? []
    }

    public func allVehicles() -> [Vehicle] {
        vehiclesByLine.values.flatMap { $0 }
    }

    public func startPolling() {
        guard !isPolling else { return }
        isPolling = true

        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self = self else { break }

                await self.fetchAllPositions()

                let interval = max(Self.minimumPollingInterval, await self.pollingInterval)
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }

    public func stopPolling() {
        isPolling = false
        pollingTask?.cancel()
        pollingTask = nil
    }

    public func refresh() async {
        await fetchAllPositions()
    }

    public func setOnVehiclesUpdated(_ handler: (@Sendable ([Int: [Vehicle]]) -> Void)?) {
        onVehiclesUpdated = handler
    }

    private func fetchAllPositions() async {
        for lineId in trackedLineIds {
            do {
                let incoming = try await client.fetchVehiclePositions(lineId: lineId)
                let merged = VehicleTracker.merge(
                    existing: vehiclesByLine[lineId] ?? [],
                    with: incoming
                )
                vehiclesByLine[lineId] = merged
                await cacheManager.saveVehicles(merged, for: lineId)
            } catch {
                if let cached = await cacheManager.loadVehicles(for: lineId) {
                    vehiclesByLine[lineId] = cached
                }
            }
        }

        notifyUpdate()
    }

    private func notifyUpdate() {
        onVehiclesUpdated?(vehiclesByLine)
    }
}
