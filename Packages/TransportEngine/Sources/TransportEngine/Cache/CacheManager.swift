//
//  CacheManager.swift
//  TransportEngine
//

import Foundation
import WIMBCore

/// Protocolo para persistência de posições de veículos (modo offline).
public protocol CacheManager: Sendable {
    func saveVehicles(_ vehicles: [Vehicle], for lineId: Int) async
    func loadVehicles(for lineId: Int) async -> [Vehicle]?
    func clearVehicles(for lineId: Int) async
    func clearAll() async
}

/// Cache em memória para desenvolvimento e testes.
public actor InMemoryCacheManager: CacheManager {
    private var cache: [Int: [Vehicle]] = [:]

    public init() {}

    public func saveVehicles(_ vehicles: [Vehicle], for lineId: Int) async {
        cache[lineId] = vehicles
    }

    public func loadVehicles(for lineId: Int) async -> [Vehicle]? {
        cache[lineId]
    }

    public func clearVehicles(for lineId: Int) async {
        cache.removeValue(forKey: lineId)
    }

    public func clearAll() async {
        cache.removeAll()
    }
}
