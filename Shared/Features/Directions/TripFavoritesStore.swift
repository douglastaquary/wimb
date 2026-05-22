//
//  TripFavoritesStore.swift
//  Shared
//

import Foundation
import WIMBCore

enum TripFavoriteKind: String, Codable, CaseIterable, Identifiable {
    case home
    case work

    var id: String { rawValue }
}

/// Favoritos Casa / Trabalho para o planejador.
@MainActor
final class TripFavoritesStore: ObservableObject {
    private static let storageKey = "wimb.directions.favorites"

    @Published private(set) var home: TripPlace?
    @Published private(set) var work: TripPlace?

    init() {
        load()
    }

    func place(for kind: TripFavoriteKind) -> TripPlace? {
        switch kind {
        case .home: return home
        case .work: return work
        }
    }

    func set(_ place: TripPlace?, for kind: TripFavoriteKind) {
        switch kind {
        case .home: home = place
        case .work: work = place
        }
        save()
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: Self.storageKey),
            let decoded = try? JSONDecoder().decode(StoredFavorites.self, from: data)
        else {
            return
        }
        home = decoded.home
        work = decoded.work
    }

    private func save() {
        let payload = StoredFavorites(home: home, work: work)
        guard let data = try? JSONEncoder().encode(payload) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }

    private struct StoredFavorites: Codable {
        let home: TripPlace?
        let work: TripPlace?
    }
}
