//
//  LocationManager.swift
//  TransportEngine
//

import Combine
import CoreLocation
import Foundation
import WIMBCore

/// Gerenciador de localização do usuário para o mapa (iOS 16+).
public final class LocationManager: NSObject, ObservableObject {
    @Published public private(set) var currentLocation: Coordinate?
    @Published public private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published public private(set) var isTracking = false
    @Published public private(set) var error: WIMBError?

    private let locationManager = CLLocationManager()

    public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }

    public var isAuthorized: Bool {
        #if os(iOS)
        return authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
        #elseif os(macOS)
        return authorizationStatus == .authorizedAlways
        #else
        return false
        #endif
    }

    public func requestPermission() {
        #if os(iOS)
        locationManager.requestWhenInUseAuthorization()
        #else
        locationManager.requestAlwaysAuthorization()
        #endif
    }

    public func startTracking() {
        guard isAuthorized else {
            error = .locationPermissionDenied
            return
        }

        isTracking = true
        locationManager.startUpdatingLocation()
    }

    public func stopTracking() {
        isTracking = false
        locationManager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.currentLocation = Coordinate(location.coordinate)
            self.error = nil
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.error = .networkError(underlying: error)
        }
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus

            switch self.authorizationStatus {
            #if os(iOS)
            case .authorizedWhenInUse, .authorizedAlways:
                self.error = nil
            #elseif os(macOS)
            case .authorizedAlways:
                self.error = nil
            #endif
            case .denied, .restricted:
                self.error = .locationPermissionDenied
            default:
                break
            }
        }
    }
}
