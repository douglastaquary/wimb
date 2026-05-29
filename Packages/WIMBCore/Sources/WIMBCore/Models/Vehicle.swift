//
//  Vehicle.swift
//  WIMBCore
//
//  Created by WIMB Team on 2026-05-21.
//

import Foundation

/// Representa um veículo (ônibus) em operação na rede SPTrans.
///
/// Este modelo contém informações de posição em tempo real do veículo,
/// incluindo a posição anterior para cálculo de animação de movimento.
///
/// ## Exemplo de uso
/// ```swift
/// var vehicle = Vehicle(
///     prefix: "74512",
///     accessible: true,
///     lastUpdateTime: "14:30",
///     coordinate: Coordinate(latitude: -23.660826, longitude: -46.679442)
/// )
///
/// // Atualizar posição mantendo histórico
/// vehicle.updatePosition(to: newCoordinate)
/// let heading = vehicle.heading // Ângulo de direção
/// ```
public struct Vehicle: Sendable, Identifiable, Hashable {
    
    // MARK: - Properties
    
    /// Identificador único do veículo.
    public let id: UUID
    
    /// Prefixo do veículo (número identificador).
    public let prefix: String
    
    /// Indica se o veículo possui acessibilidade.
    public let accessible: Bool
    
    /// Horário da última atualização de posição.
    public let lastUpdateTime: String
    
    /// Coordenada atual do veículo.
    public var coordinate: Coordinate
    
    /// Coordenada anterior (para cálculo de animação).
    public var previousCoordinate: Coordinate?
    
    /// Previsão de chegada (quando disponível).
    public var arrivalForecast: String?
    
    // MARK: - Initialization
    
    /// Cria um novo veículo.
    /// - Parameters:
    ///   - id: Identificador único (gerado automaticamente se não fornecido).
    ///   - prefix: Prefixo/número do veículo.
    ///   - accessible: Se possui acessibilidade.
    ///   - lastUpdateTime: Horário da última atualização.
    ///   - coordinate: Posição atual.
    ///   - previousCoordinate: Posição anterior (opcional).
    ///   - arrivalForecast: Previsão de chegada (opcional).
    /// Identificador estável por prefixo — mantém o mesmo ônibus entre polls da API.
    public static func stableID(prefix: String) -> UUID {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in "wimb:vehicle:\(prefix)".utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x100000001b3
        }
        let suffix = String(format: "%012x", hash & 0xFFFFFFFFFFFF)
        return UUID(uuidString: "00000000-0000-4000-8000-\(suffix)") ?? UUID()
    }

    public init(
        id: UUID? = nil,
        prefix: String,
        accessible: Bool,
        lastUpdateTime: String,
        coordinate: Coordinate,
        previousCoordinate: Coordinate? = nil,
        arrivalForecast: String? = nil
    ) {
        self.id = id ?? Self.stableID(prefix: prefix)
        self.prefix = prefix
        self.accessible = accessible
        self.lastUpdateTime = lastUpdateTime
        self.coordinate = coordinate
        self.previousCoordinate = previousCoordinate
        self.arrivalForecast = arrivalForecast
    }
    
    // MARK: - Computed Properties
    
    /// Ângulo de direção (heading) baseado no movimento.
    ///
    /// Calcula o ângulo entre a posição anterior e a atual.
    /// Retorna 0 se não houver posição anterior.
    public var heading: Double {
        guard let previous = previousCoordinate else { return 0 }
        return previous.bearing(to: coordinate)
    }
    
    /// Verifica se o veículo se moveu desde a última atualização.
    public var hasMoved: Bool {
        guard let previous = previousCoordinate else { return false }
        return previous != coordinate
    }
    
    /// Título para exibição (prefixo do veículo).
    public var displayTitle: String {
        prefix
    }
    
    /// Subtítulo para exibição (previsão de chegada ou horário de atualização).
    public var displaySubtitle: String {
        if let forecast = arrivalForecast, !forecast.isEmpty {
            return "Chegada: \(forecast)"
        }
        return "Atualizado: \(lastUpdateTime)"
    }
    
    // MARK: - Methods
    
    /// Atualiza a posição do veículo mantendo a coordenada anterior para animação.
    /// - Parameter newCoordinate: Nova coordenada.
    public mutating func updatePosition(to newCoordinate: Coordinate) {
        previousCoordinate = coordinate
        coordinate = newCoordinate
    }
    
    /// Cria uma cópia do veículo com nova posição.
    /// - Parameter newCoordinate: Nova coordenada.
    /// - Returns: Novo veículo com posição atualizada.
    public func withUpdatedPosition(_ newCoordinate: Coordinate) -> Vehicle {
        var updated = self
        updated.updatePosition(to: newCoordinate)
        return updated
    }
}

// MARK: - Codable

extension Vehicle: Codable {
    
    enum CodingKeys: String, CodingKey {
        case prefix = "p"
        case accessible = "a"
        case lastUpdateTime = "ta"
        case latitude = "py"
        case longitude = "px"
        case arrivalForecast = "t"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.prefix = try container.decode(String.self, forKey: .prefix)
        self.id = Self.stableID(prefix: prefix)
        self.accessible = try container.decode(Bool.self, forKey: .accessible)
        self.lastUpdateTime = try container.decode(String.self, forKey: .lastUpdateTime)
        
        let lat = try container.decode(Double.self, forKey: .latitude)
        let lon = try container.decode(Double.self, forKey: .longitude)
        self.coordinate = Coordinate(latitude: lat, longitude: lon)
        
        self.previousCoordinate = nil
        self.arrivalForecast = try container.decodeIfPresent(String.self, forKey: .arrivalForecast)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(prefix, forKey: .prefix)
        try container.encode(accessible, forKey: .accessible)
        try container.encode(lastUpdateTime, forKey: .lastUpdateTime)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encodeIfPresent(arrivalForecast, forKey: .arrivalForecast)
    }
}

// MARK: - Coordinatable

extension Vehicle: Coordinatable {}
