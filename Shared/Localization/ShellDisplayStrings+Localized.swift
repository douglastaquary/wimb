//
//  ShellDisplayStrings+Localized.swift
//  Shared
//

import AppShell
import Foundation

extension ShellDisplayStrings {
    static var localized: ShellDisplayStrings {
        ShellDisplayStrings(
            tabDirections: WIMBL10n.tabDirections,
            tabStations: WIMBL10n.tabStations,
            tabLines: WIMBL10n.tabLines,
            regionTitle: WIMBL10n.shellRegionTitle,
            directionsPrompt: WIMBL10n.shellDirectionsPrompt,
            directionsSearchPlaceholder: WIMBL10n.shellDirectionsSearchPlaceholder,
            comingSoonTitle: WIMBL10n.shellComingSoonTitle,
            directionsComingSoonMessage: WIMBL10n.shellDirectionsComingSoonMessage,
            stationsPlaceholderMessage: WIMBL10n.shellStationsPlaceholderMessage,
            linesPlaceholderMessage: WIMBL10n.shellLinesPlaceholderMessage
        )
    }
}
