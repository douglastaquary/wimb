//
//  LinesRecentStore.swift
//  Shared
//

import Foundation
import WIMBCore

/// Linhas visualizadas recentemente (persistência local).
@MainActor
final class LinesRecentStore: ObservableObject {
    static let maxCount = 8
    private static let storageKey = "wimb.lines.recent"

    @Published private(set) var lines: [TransportLine] = []

    init() {
        load()
    }

    func record(_ line: TransportLine) {
        var updated = lines.filter { $0.id != line.id }
        updated.insert(line, at: 0)
        lines = Array(updated.prefix(Self.maxCount))
        save()
    }

    func remove(_ lineId: Int) {
        lines.removeAll { $0.id == lineId }
        save()
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: Self.storageKey),
            let decoded = try? JSONDecoder().decode([TransportLine].self, from: data)
        else {
            lines = []
            return
        }
        lines = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(lines) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
