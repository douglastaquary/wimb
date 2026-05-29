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

    static var metroSection: String { text("metro.section") }
    static var metroHint: String { text("metro.hint") }
    static var rainDelayHint: String { text("weather.rainDelay") }

    static func smartETA(minutes: Int) -> String {
        String(format: text("eta.smart"), minutes)
    }

    static func metroWalkingMinutes(_ minutes: Int) -> String {
        String(format: text("metro.walking"), minutes)
    }

    static var tabDirections: String { text("tab.directions") }
    static var tabStations: String { text("tab.stations") }
    static var tabLines: String { text("tab.lines") }
    static var shellRegionTitle: String { text("shell.region") }
    static var shellDirectionsPrompt: String { text("shell.directions.prompt") }
    static var shellDirectionsSearchPlaceholder: String { text("shell.directions.search") }
    static var shellComingSoonTitle: String { text("shell.comingSoon.title") }
    static var shellDirectionsComingSoonMessage: String { text("shell.directions.comingSoon") }
    static var shellStationsPlaceholderMessage: String { text("shell.stations.placeholder") }
    static var shellLinesPlaceholderMessage: String { text("shell.lines.placeholder") }

    static var linesSearchPlaceholder: String { text("lines.search") }
    static var linesFilterAll: String { text("lines.filter.all") }
    static var linesFilterBus: String { text("lines.filter.bus") }
    static var linesRecentSection: String { text("lines.recent") }
    static var linesEmptyTitle: String { text("lines.empty.title") }
    static var linesEmptyMessage: String { text("lines.empty.message") }
    static var lineTimelineTitle: String { text("line.timeline.title") }
    static var lineTimelineNoForecast: String { text("line.timeline.noForecast") }
    static var lineActiveVehiclesSection: String { text("line.activeVehicles.section") }
    static var lineActiveVehiclesHint: String { text("line.activeVehicles.hint") }
    static var lineDirectionTitle: String { text("line.direction.title") }
    static var lineDirectionOutbound: String { text("line.direction.outbound") }
    static var lineDirectionInbound: String { text("line.direction.inbound") }
    static var lineSwitchDirection: String { text("line.direction.switch") }
    static var liveTrackingButton: String { text("liveTracking.button") }

    static func liveTrackingStopsAway(_ count: Int) -> String {
        String(format: text("liveTracking.stopsAway"), count)
    }

    static func liveTrackingRefreshIn(_ seconds: Int) -> String {
        String(format: text("liveTracking.refreshIn"), seconds)
    }

    static var liveTrackingClose: String { text("liveTracking.close") }
    static var liveTrackingLiveNow: String { text("liveTracking.liveNow") }
    static var liveTrackingShowRoute: String { text("liveTracking.showRoute") }

    static var stationsSearchPlaceholder: String { text("stations.search") }
    static var stationsNearbyButton: String { text("stations.nearby") }
    static var stationsResultsSection: String { text("stations.results") }
    static var stationsEmptyMessage: String { text("stations.empty.message") }
    static var stationsArrivalsSection: String { text("stations.arrivals.section") }
    static var stationsNoArrivalsTitle: String { text("stations.arrivals.empty.title") }
    static var stationsNoArrivalsMessage: String { text("stations.arrivals.empty.message") }

    static func stationsUpdatedAt(_ hour: String) -> String {
        String(format: text("stations.updatedAt"), hour)
    }

    static func stationsMultipleBuses(_ count: Int) -> String {
        String(format: text("stations.multipleBuses"), count)
    }

    static var directionsPrompt: String { text("directions.prompt") }
    static var directionsRecentSection: String { text("directions.recent") }
    static var directionsClearRecent: String { text("directions.recent.clear") }
    static var directionsPlaceActions: String { text("directions.place.actions") }
    static var directionsFavoritesSection: String { text("directions.favorites") }
    static var directionsFavoriteHome: String { text("directions.favorite.home") }
    static var directionsFavoriteWork: String { text("directions.favorite.work") }
    static var directionsFavoritesHint: String { text("directions.favorites.hint") }
    static var directionsFavoriteSaveHome: String { text("directions.favorite.saveHome") }
    static var directionsFavoriteSaveWork: String { text("directions.favorite.saveWork") }
    static var directionsFavoriteClear: String { text("directions.favorite.clear") }

    static var plannerTitle: String { text("planner.title") }
    static var plannerCurrentLocation: String { text("planner.currentLocation") }
    static var plannerOriginLabel: String { text("planner.origin") }
    static var plannerDestinationLabel: String { text("planner.destination") }
    static var plannerDepartureSection: String { text("planner.departure.section") }
    static var plannerDepartureNow: String { text("planner.departure.now") }
    static var plannerDepartureEarlier: String { text("planner.departure.earlier") }
    static var plannerDepartureLater: String { text("planner.departure.later") }
    static var plannerShowRoutes: String { text("planner.showRoutes") }
    static var plannerDisclaimer: String { text("planner.disclaimer") }
    static var plannerEmptyTitle: String { text("planner.empty.title") }
    static var plannerEmptyMessage: String { text("planner.empty.message") }

    static var routeStepsSection: String { text("route.steps.section") }

    static func routeTotalMinutes(_ minutes: Int) -> String {
        String(format: text("route.totalMinutes"), minutes)
    }

    static func routeWalkMinutes(_ minutes: Int) -> String {
        String(format: text("route.walkMinutes"), minutes)
    }

    static func routeBusMinutes(_ minutes: Int) -> String {
        String(format: text("route.busMinutes"), minutes)
    }

    static func routeStepMinutes(_ minutes: Int) -> String {
        String(format: text("route.stepMinutes"), minutes)
    }

    static var errorNetwork: String { text("error.network") }
    static var errorTimeout: String { text("error.timeout") }
    static var errorServer: String { text("error.server") }
    static var errorNoData: String { text("error.noData") }
    static var errorLineNotFound: String { text("error.lineNotFound") }
    static var errorStopNotFound: String { text("error.stopNotFound") }
    static var errorNoVehicles: String { text("error.noVehicles") }
    static var errorLocationDenied: String { text("error.locationDenied") }
    static var errorLocationDisabled: String { text("error.locationDisabled") }
    static var errorAuth: String { text("error.auth") }
    static var errorGeneric: String { text("error.generic") }

    static func errorTooManyLines(max: Int) -> String {
        String(format: text("error.tooManyLines"), max)
    }
}
