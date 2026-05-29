//
//  TransportService.swift
//  WIMBCore
//
//  Created by WIMB Team on 2026-05-21.
//

import Foundation

/// Protocolo para serviços de transporte público.
///
/// Define a interface para comunicação com APIs de transporte,
/// permitindo diferentes implementações (SPTrans, Mock, etc.).
///
/// ## Conformance Requirements
/// Todas as operações são assíncronas e podem lançar erros.
///
/// ## Exemplo de uso
/// ```swift
/// class SPTransClient: TransportService {
///     func authenticate() async throws -> Bool { ... }
///     func searchLines(query: String) async throws -> [TransportLine] { ... }
///     // ...
/// }
/// ```
public protocol TransportService: Sendable {
    
    /// Autentica com a API de transporte.
    /// - Returns: `true` se autenticado com sucesso.
    /// - Throws: `WIMBError.authenticationFailed` se falhar.
    func authenticate() async throws -> Bool
    
    /// Busca linhas de transporte por termo.
    /// - Parameter query: Termo de busca (número ou nome da linha).
    /// - Returns: Lista de linhas encontradas.
    /// - Throws: Erros de rede ou decodificação.
    func searchLines(query: String) async throws -> [TransportLine]
    
    /// Busca posições de veículos de uma linha específica.
    /// - Parameter lineId: Código da linha.
    /// - Returns: Lista de veículos com posições atuais.
    /// - Throws: `WIMBError.lineNotFound` se a linha não existir.
    func fetchVehiclePositions(lineId: Int) async throws -> [Vehicle]
    
    /// Busca previsão de chegada para uma linha.
    /// - Parameter lineId: Código da linha.
    /// - Returns: Lista de paradas com previsões de chegada.
    /// - Throws: Erros de rede ou decodificação.
    func fetchArrivals(lineId: Int) async throws -> [Stop]
    
    /// Busca previsão de chegada para uma parada específica.
    /// - Parameter stopId: Código da parada.
    /// - Returns: Informações da parada com previsões.
    /// - Throws: `WIMBError.stopNotFound` se a parada não existir.
    func fetchStopForecast(stopId: Int) async throws -> Stop

    /// Busca paradas por termo (nome ou endereço).
    /// - Parameter query: Termo de busca.
    /// - Returns: Paradas encontradas.
    func searchStops(query: String) async throws -> [Stop]

    /// Busca detalhe da parada com previsões agrupadas por linha.
    /// - Parameter stopId: Código da parada.
    func fetchStopDetail(stopId: Int) async throws -> StopDetail
}

// MARK: - Convenience Extensions

extension TransportService {

    /// Filtra paradas próximas a uma coordenada.
    public func fetchNearbyStops(
        near coordinate: Coordinate,
        query: String,
        radiusMeters: Double = 800
    ) async throws -> [Stop] {
        let stops = try await searchStops(query: query)
        return NearbyStopsFilter.filter(stops, near: coordinate, radiusMeters: radiusMeters)
    }
    
    /// Busca posições de veículos para múltiplas linhas.
    /// - Parameter lineIds: Lista de códigos de linhas.
    /// - Returns: Dicionário de linha → veículos.
    public func fetchVehiclePositions(lineIds: [Int]) async throws -> [Int: [Vehicle]] {
        try await withThrowingTaskGroup(of: (Int, [Vehicle]).self) { group in
            for lineId in lineIds {
                group.addTask {
                    let vehicles = try await self.fetchVehiclePositions(lineId: lineId)
                    return (lineId, vehicles)
                }
            }
            
            var results: [Int: [Vehicle]] = [:]
            for try await (lineId, vehicles) in group {
                results[lineId] = vehicles
            }
            return results
        }
    }
}
