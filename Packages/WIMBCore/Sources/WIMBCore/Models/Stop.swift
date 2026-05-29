//
//  Stop.swift
//  WIMBCore
//
//  Created by WIMB Team on 2026-05-21.
//

import Foundation

/// Representa uma parada de ônibus.
///
/// Contém informações sobre a localização da parada e
/// opcionalmente os veículos que estão próximos.
///
/// ## Exemplo de uso
/// ```swift
/// let stop = Stop(
///     id: 12345,
///     name: "Av. Paulista, 1000",
///     coordinate: Coordinate(latitude: -23.561, longitude: -46.655)
/// )
///
/// if stop.hasVehicles {
///     print("\(stop.vehicleCount) ônibus próximo(s)")
/// }
/// ```
public struct Stop: Sendable, Identifiable, Hashable {
    
    // MARK: - Properties
    
    /// Código único da parada.
    public let id: Int
    
    /// Nome ou descrição da parada.
    public var name: String
    
    /// Coordenada geográfica da parada.
    public let coordinate: Coordinate
    
    /// Veículos próximos da parada (quando disponível).
    public var vehicles: [Vehicle]?
    
    // MARK: - Initialization
    
    /// Cria uma nova parada.
    /// - Parameters:
    ///   - id: Código único da parada.
    ///   - name: Nome ou descrição.
    ///   - coordinate: Localização geográfica.
    ///   - vehicles: Veículos próximos (opcional).
    public init(
        id: Int,
        name: String,
        coordinate: Coordinate,
        vehicles: [Vehicle]? = nil
    ) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.vehicles = vehicles
    }
    
    // MARK: - Computed Properties
    
    /// Número de veículos próximos.
    public var vehicleCount: Int {
        vehicles?.count ?? 0
    }
    
    /// Verifica se há veículos próximos.
    public var hasVehicles: Bool {
        vehicleCount > 0
    }
    
    /// Próximo veículo a chegar (se houver).
    public var nextVehicle: Vehicle? {
        vehicles?.first
    }
    
    /// Título para exibição.
    public var displayTitle: String {
        name.isEmpty ? "Parada \(id)" : name
    }
    
    /// Subtítulo para exibição.
    public var displaySubtitle: String? {
        guard hasVehicles else { return nil }
        
        if vehicleCount == 1 {
            return "1 ônibus próximo"
        }
        return "\(vehicleCount) ônibus próximos"
    }
}

// MARK: - Codable

extension Stop: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id = "cp"
        case name = "np"
        case latitude = "py"
        case longitude = "px"
        case vehicles = "vs"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        
        let lat = try container.decode(Double.self, forKey: .latitude)
        let lon = try container.decode(Double.self, forKey: .longitude)
        self.coordinate = Coordinate(latitude: lat, longitude: lon)
        
        self.vehicles = try container.decodeIfPresent([Vehicle].self, forKey: .vehicles)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encodeIfPresent(vehicles, forKey: .vehicles)
    }
}

// MARK: - Coordinatable

extension Stop: Coordinatable {
    public var heading: Double? { nil }
}

// MARK: - Mock Data

extension Stop {
    
    /// Parada de exemplo para previews e testes.
    public static let mock = Stop(
        id: 12345,
        name: "Av. Paulista, 1000",
        coordinate: Coordinate(latitude: -23.561414, longitude: -46.655882),
        vehicles: [
            Vehicle(
                prefix: "74512",
                accessible: true,
                lastUpdateTime: "14:30",
                coordinate: Coordinate(latitude: -23.562, longitude: -46.656),
                arrivalForecast: "3 min"
            )
        ]
    )
}
