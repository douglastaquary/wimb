//
//  WIMBL10n.swift
//  Shared
//

import Foundation

/// Strings localizadas (pt-BR e en) para o app.
enum WIMBL10n {
    private static func text(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    static var homeTitle: String { text("home.title") }
    static var homeSubtitle: String { text("home.subtitle") }
    static var back: String { text("common.back") }
    static var updated: String { text("common.updated") }
    static var trackingSection: String { text("tracking.section") }
    static var searchPlaceholder: String { text("search.placeholder") }
    static var searchCancel: String { text("search.cancel") }
    static var searchResults: String { text("search.results") }
    static var searchErrorTitle: String { text("search.error.title") }
    static var searchEmptyTitle: String { text("search.empty.title") }
    static var searchEmptyMessage: String { text("search.empty.message") }
    static var lineStopsTitle: String { text("line.stops.title") }
    static var lineStopsEmptyTitle: String { text("line.stops.empty.title") }
    static var lineStopsEmptyMessage: String { text("line.stops.empty.message") }
    static var vehicleAccessible: String { text("vehicle.accessible") }
    static var mapIdle: String { text("map.idle") }
    static var mapRefresh: String { text("map.refresh") }

    static func trackingStop(lineNumber: String) -> String {
        String(format: text("tracking.stop"), lineNumber)
    }

    static func lineBusesOnMap(_ count: Int) -> String {
        String(format: text("line.busesOnMap"), count)
    }

    static func mapTrackingStatus(buses: Int, lines: Int) -> String {
        String(format: text("map.tracking"), buses, lines)
    }
}
