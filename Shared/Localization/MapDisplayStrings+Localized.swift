//
//  MapDisplayStrings+Localized.swift
//  Shared
//

import MapFeature

extension MapDisplayStrings {
    static var localized: MapDisplayStrings {
        MapDisplayStrings(
            idleStatus: WIMBL10n.mapIdle,
            trackingStatus: WIMBL10n.mapTrackingStatus,
            refreshAccessibilityLabel: WIMBL10n.mapRefresh
        )
    }
}
