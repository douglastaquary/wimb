//
//  RecentTripsStore.swift
//  Shared
//

import Foundation
import WIMBCore

/// Destinos pesquisados recentemente (persistência local).
@MainActor
final class RecentTripsStore: ObservableObject {
    static let maxCount = 6
    private static let storageKey = "wimb.directions.recent"

    @Published private(set) var places: [TripPlace] = []

    init() {
        load()
    }

    func record(_ place: TripPlace) {
        var updated = places.filter { $0.id != place.id }
        updated.insert(place, at: 0)
        places = Array(updated.prefix(Self.maxCount))
        save()
    }

    func remove(_ placeId: String) {
        places.removeAll { $0.id == placeId }
        save()
    }

    func clearAll() {
        places = []
        save()
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: Self.storageKey),
            let decoded = try? JSONDecoder().decode([TripPlace].self, from: data)
        else {
            places = []
            return
        }
        places = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(places) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
