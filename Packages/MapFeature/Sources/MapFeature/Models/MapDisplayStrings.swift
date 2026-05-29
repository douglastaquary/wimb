//
//  MapDisplayStrings.swift
//  MapFeature
//

import Foundation

/// Textos exibidos no mapa (localizados pelo app).
public struct MapDisplayStrings {
    public var idleStatus: String
    public var trackingStatus: (_ busCount: Int, _ lineCount: Int) -> String
    public var refreshAccessibilityLabel: String

    public init(
        idleStatus: String,
        trackingStatus: @escaping (_ busCount: Int, _ lineCount: Int) -> String,
        refreshAccessibilityLabel: String
    ) {
        self.idleStatus = idleStatus
        self.trackingStatus = trackingStatus
        self.refreshAccessibilityLabel = refreshAccessibilityLabel
    }

    public static let english = MapDisplayStrings(
        idleStatus: "Search for a bus line",
        trackingStatus: { buses, lines in
            String(format: "%d buses · %d line(s)", buses, lines)
        },
        refreshAccessibilityLabel: "Refresh bus positions"
    )
}
