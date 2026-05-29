//
//  SPTransClient.swift
//  NetworkClient
//
//  Created by WIMB Team on 2026-05-21.
//

import Foundation
import WIMBCore

/// Cliente da API SPTrans OlhoVivo.
///
/// Actor que gerencia a comunicação com a API SPTrans,
/// incluindo autenticação automática e tratamento de erros.
///
/// ## Thread Safety
/// Como `actor`, todas as operações são thread-safe automaticamente.
///
/// ## Autenticação
/// O cliente autentica automaticamente antes de cada requisição
/// se ainda não estiver autenticado.
///
/// ## Exemplo de uso
/// ```swift
/// let config = SPTransConfiguration(token: "seu-token")
/// let client = SPTransClient(configuration: config)
///
/// let lines = try await client.searchLines(query: "8000")
/// let positions = try await client.fetchVehiclePositions(lineId: 34041)
/// ```
public actor SPTransClient: TransportService {
    
    // MARK: - Properties
    
    private let httpClient: HTTPClient
    private let configuration: SPTransConfiguration
    private var isAuthenticated: Bool = false
    private let decoder: JSONDecoder
    
    // MARK: - Initialization
    
    /// Cria um novo cliente SPTrans.
    /// - Parameters:
    ///   - configuration: Configuração com token e URL base.
    ///   - httpClient: Cliente HTTP (default: URLSessionHTTPClient).
    public init(
        configuration: SPTransConfiguration,
        httpClient: HTTPClient = URLSessionHTTPClient()
    ) {
        self.configuration = configuration
        self.httpClient = httpClient
        self.decoder = JSONDecoder()
    }
    
    // MARK: - TransportService Implementation
    
    /// Autentica com a API SPTrans.
    /// - Returns: `true` se autenticado com sucesso.
    /// - Throws: `NetworkError.unauthorized` se falhar.
    public func authenticate() async throws -> Bool {
        let endpoint = SPTransEndpoint.authenticate(token: configuration.token)
        
        guard let request = endpoint.urlRequest(baseURL: configuration.baseURL) else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await httpClient.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }
            
            if let error = NetworkError.from(statusCode: httpResponse.statusCode, data: data) {
                throw error
            }
            
            if let result = String(data: data, encoding: .utf8) {
                isAuthenticated = result.lowercased() == "true"
                return isAuthenticated
            }
            
            throw NetworkError.decodingError(underlying: NSError(
                domain: "SPTransClient",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid auth response"]
            ))
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(underlying: error)
        }
    }
    
    /// Busca linhas por termo.
    /// - Parameter query: Termo de busca (número ou nome).
    /// - Returns: Lista de linhas encontradas.
    public func searchLines(query: String) async throws -> [TransportLine] {
        try await ensureAuthenticated()
        
        let endpoint = SPTransEndpoint.searchLines(query: query)
        return try await performRequest(endpoint: endpoint)
    }
    
    /// Busca posições de veículos de uma linha.
    /// - Parameter lineId: Código da linha.
    /// - Returns: Lista de veículos com posições atuais.
    public func fetchVehiclePositions(lineId: Int) async throws -> [Vehicle] {
        try await ensureAuthenticated()
        
        let endpoint = SPTransEndpoint.positions(lineId: lineId)
        let response: PositionsResponse = try await performRequest(endpoint: endpoint)
        return response.vehicles ?? []
    }
    
    /// Busca previsão de chegada para uma linha.
    /// - Parameter lineId: Código da linha.
    /// - Returns: Lista de paradas com previsões.
    public func fetchArrivals(lineId: Int) async throws -> [Stop] {
        try await ensureAuthenticated()
        
        let endpoint = SPTransEndpoint.arrivals(lineId: lineId)
        let response: ArrivalsResponse = try await performRequest(endpoint: endpoint)
        return response.stops ?? []
    }
    
    /// Busca previsão para uma parada específica.
    /// - Parameter stopId: Código da parada.
    /// - Returns: Informações da parada com previsões.
    public func fetchStopForecast(stopId: Int) async throws -> Stop {
        try await fetchStopDetail(stopId: stopId).stop
    }

    /// Busca detalhe da parada com linhas e previsões.
    public func fetchStopDetail(stopId: Int) async throws -> StopDetail {
        try await ensureAuthenticated()

        let endpoint = SPTransEndpoint.stopForecast(stopId: stopId)
        let response: StopForecastResponse = try await performRequest(endpoint: endpoint)
        return response.detail
    }

    /// Busca paradas por termo (nome ou endereço).
    public func searchStops(query: String) async throws -> [Stop] {
        try await ensureAuthenticated()

        let endpoint = SPTransEndpoint.searchStops(query: query)
        return try await performRequest(endpoint: endpoint)
    }

    // MARK: - Additional Methods
    
    /// Busca posição de todos os veículos de todas as linhas.
    /// - Returns: Resposta com todos os veículos.
    public func fetchAllPositions() async throws -> PositionsResponse {
        try await ensureAuthenticated()
        
        let endpoint = SPTransEndpoint.allPositions
        return try await performRequest(endpoint: endpoint)
    }
    
    /// Reseta o estado de autenticação.
    ///
    /// Útil quando o token expira ou precisa ser renovado.
    public func resetAuthentication() {
        isAuthenticated = false
    }
    
    /// Verifica se o cliente está autenticado.
    public var authenticated: Bool {
        isAuthenticated
    }
    
    // MARK: - Private Methods
    
    /// Garante que o cliente está autenticado.
    private func ensureAuthenticated() async throws {
        guard !isAuthenticated else { return }
        
        let success = try await authenticate()
        guard success else {
            throw NetworkError.unauthorized
        }
    }
    
    /// Executa requisição genérica com decodificação.
    private func performRequest<T: Decodable>(endpoint: SPTransEndpoint) async throws -> T {
        guard let request = endpoint.urlRequest(baseURL: configuration.baseURL) else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await httpClient.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }
            
            if let error = NetworkError.from(statusCode: httpResponse.statusCode, data: data) {
                if case .unauthorized = error {
                    isAuthenticated = false
                    try await ensureAuthenticated()
                    return try await performRequest(endpoint: endpoint)
                }
                throw error
            }
            
            return try decoder.decode(T.self, from: data)
            
        } catch let error as NetworkError {
            throw error
        } catch let error as DecodingError {
            throw NetworkError.decodingError(underlying: error)
        } catch {
            throw NetworkError.networkError(underlying: error)
        }
    }
}

// MARK: - Convenience Factory

extension SPTransClient {
    
    /// Cria cliente com token da variável de ambiente.
    public static func fromEnvironment() -> SPTransClient {
        SPTransClient(configuration: .fromEnvironment())
    }
}
