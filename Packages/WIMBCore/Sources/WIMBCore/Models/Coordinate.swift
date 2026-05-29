//
//  Coordinate.swift
//  WIMBCore
//
//  Created by WIMB Team on 2026-05-21.
//

import Foundation
import CoreLocation

/// Representa uma coordenada geográfica imutável.
///
/// Este tipo é usado em todo o app para representar posições geográficas
/// de veículos, paradas e outros pontos de interesse.
///
/// ## Exemplo de uso
/// ```swift
/// let coordinate = Coordinate(latitude: -23.550520, longitude: -46.633308)
/// let bearing = coordinate.bearing(to: anotherCoordinate)
/// ```
public struct Coordinate: Sendable, Hashable, Codable {
    
    // MARK: - Properties
    
    /// Latitude em graus decimais (-90 a 90).
    public let latitude: Double
    
    /// Longitude em graus decimais (-180 a 180).
    public let longitude: Double
    
    // MARK: - Initialization
    
    /// Cria uma nova coordenada.
    /// - Parameters:
    ///   - latitude: Latitude em graus decimais.
    ///   - longitude: Longitude em graus decimais.
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    /// Cria uma coordenada a partir de CLLocationCoordinate2D.
    /// - Parameter clCoordinate: Coordenada do CoreLocation.
    public init(_ clCoordinate: CLLocationCoordinate2D) {
        self.latitude = clCoordinate.latitude
        self.longitude = clCoordinate.longitude
    }
    
    // MARK: - Computed Properties
    
    /// Converte para CLLocationCoordinate2D do CoreLocation.
    public var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // MARK: - Methods
    
    /// Calcula o ângulo de direção (bearing) para outra coordenada.
    ///
    /// O ângulo é calculado em radianos, onde:
    /// - 0 = Norte
    /// - π/2 = Leste
    /// - π = Sul
    /// - 3π/2 = Oeste
    ///
    /// - Parameter destination: Coordenada de destino.
    /// - Returns: Ângulo em radianos.
    public func bearing(to destination: Coordinate) -> Double {
        let deltaLongitude = destination.longitude - longitude
        let deltaLatitude = destination.latitude - latitude
        
        guard deltaLongitude != 0 else {
            return deltaLatitude < 0 ? .pi : 0.0
        }
        
        let angle = (.pi * 0.5) - atan(deltaLatitude / deltaLongitude)
        
        if deltaLongitude > 0 {
            return angle
        } else {
            return angle + .pi
        }
    }
    
    /// Trunca as coordenadas para uma precisão específica.
    ///
    /// Útil para comparações onde pequenas variações devem ser ignoradas.
    ///
    /// - Parameter places: Número de casas decimais (default: 6).
    /// - Returns: Nova coordenada truncada.
    public func truncated(places: Int = 6) -> Coordinate {
        Coordinate(
            latitude: latitude.truncated(places: places),
            longitude: longitude.truncated(places: places)
        )
    }
    
    /// Calcula a distância em metros para outra coordenada.
    /// - Parameter destination: Coordenada de destino.
    /// - Returns: Distância em metros.
    public func distance(to destination: Coordinate) -> Double {
        let location1 = CLLocation(latitude: latitude, longitude: longitude)
        let location2 = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        return location1.distance(from: location2)
    }
}

// MARK: - Static Constants

extension Coordinate {
    
    /// Coordenada padrão de São Paulo (Praça da Sé).
    public static let saoPauloDefault = Coordinate(
        latitude: -23.550520,
        longitude: -46.633308
    )
    
    /// Coordenada zero (0, 0).
    public static let zero = Coordinate(latitude: 0, longitude: 0)
}

// MARK: - CustomStringConvertible

extension Coordinate: CustomStringConvertible {
    public var description: String {
        String(format: "(%.6f, %.6f)", latitude, longitude)
    }
}
