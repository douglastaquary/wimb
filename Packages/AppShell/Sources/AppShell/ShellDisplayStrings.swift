//
//  ShellDisplayStrings.swift
//  AppShell
//

import Foundation

/// Textos do shell principal (localizados pelo app).
public struct ShellDisplayStrings {
    public var tabDirections: String
    public var tabStations: String
    public var tabLines: String
    public var regionTitle: String
    public var directionsPrompt: String
    public var directionsSearchPlaceholder: String
    public var comingSoonTitle: String
    public var directionsComingSoonMessage: String
    public var stationsPlaceholderMessage: String
    public var linesPlaceholderMessage: String

    public init(
        tabDirections: String,
        tabStations: String,
        tabLines: String,
        regionTitle: String,
        directionsPrompt: String,
        directionsSearchPlaceholder: String,
        comingSoonTitle: String,
        directionsComingSoonMessage: String,
        stationsPlaceholderMessage: String,
        linesPlaceholderMessage: String
    ) {
        self.tabDirections = tabDirections
        self.tabStations = tabStations
        self.tabLines = tabLines
        self.regionTitle = regionTitle
        self.directionsPrompt = directionsPrompt
        self.directionsSearchPlaceholder = directionsSearchPlaceholder
        self.comingSoonTitle = comingSoonTitle
        self.directionsComingSoonMessage = directionsComingSoonMessage
        self.stationsPlaceholderMessage = stationsPlaceholderMessage
        self.linesPlaceholderMessage = linesPlaceholderMessage
    }

    public static let english = ShellDisplayStrings(
        tabDirections: "Directions",
        tabStations: "Stations",
        tabLines: "Lines",
        regionTitle: "São Paulo Region",
        directionsPrompt: "Where do you want to go?",
        directionsSearchPlaceholder: "Search destination",
        comingSoonTitle: "Coming soon",
        directionsComingSoonMessage: "Trip planner and suggested routes arrive in Phase 6.5.",
        stationsPlaceholderMessage: "Nearby bus stops on the map — available in the next update.",
        linesPlaceholderMessage: "Search and track bus lines — available in the next update."
    )
}
