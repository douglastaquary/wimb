//
//  SPTransEndpoint.swift
//  NetworkClient
//
//  Created by WIMB Team on 2026-05-21.
//

import Foundation

/// Endpoints da API SPTrans OlhoVivo.
///
/// Enum type-safe que representa todos os endpoints disponíveis,
/// com seus parâmetros e métodos HTTP correspondentes.
///
/// ## Endpoints Disponíveis
/// - `authenticate`: Autenticação com token
/// - `searchLines`: Busca de linhas por termo
/// - `positions`: Posição de veículos por linha
/// - `arrivals`: Previsão de chegada por linha
/// - `stopForecast`: Previsão para uma parada específica
/// - `allPositions`: Posição de todos os veículos
///
/// ## Exemplo de uso
/// ```swift
/// let endpoint = SPTransEndpoint.searchLines(query: "8000")
/// let request = endpoint.urlRequest(baseURL: baseURL)
/// ```
public enum SPTransEndpoint: Sendable {
    
    /// Autenticação com a API.
    case authenticate(token: String)
    
    /// Busca linhas por termo.
    case searchLines(query: String)
    
    /// Posição de veículos de uma linha.
    case positions(lineId: Int)
    
    /// Previsão de chegada por linha.
    case arrivals(lineId: Int)
    
    /// Previsão de chegada em uma parada.
    case stopForecast(stopId: Int)

    /// Busca de paradas por termo.
    case searchStops(query: String)

    /// Posição de todos os veículos.
    case allPositions
    
    // MARK: - Properties
    
    /// Path do endpoint (sem base URL).
    public var path: String {
        switch self {
        case .authenticate:
            return "/Login/Autenticar"
        case .searchLines:
            return "/Linha/Buscar"
        case .positions:
            return "/Posicao/Linha"
        case .arrivals:
            return "/Previsao/Linha"
        case .stopForecast:
            return "/Previsao/Parada"
        case .searchStops:
            return "/Parada/Buscar"
        case .allPositions:
            return "/Posicao"
        }
    }
    
    /// Método HTTP do endpoint.
    public var method: HTTPMethod {
        switch self {
        case .authenticate:
            return .post
        default:
            return .get
        }
    }
    
    /// Query items do endpoint.
    public var queryItems: [URLQueryItem] {
        switch self {
        case .authenticate(let token):
            return [URLQueryItem(name: "token", value: token)]
            
        case .searchLines(let query):
            return [URLQueryItem(name: "termosBusca", value: query)]
            
        case .positions(let lineId):
            return [URLQueryItem(name: "codigoLinha", value: String(lineId))]
            
        case .arrivals(let lineId):
            return [URLQueryItem(name: "codigoLinha", value: String(lineId))]
            
        case .stopForecast(let stopId):
            return [URLQueryItem(name: "codigoParada", value: String(stopId))]

        case .searchStops(let query):
            return [URLQueryItem(name: "termosBusca", value: query)]

        case .allPositions:
            return []
        }
    }
    
    // MARK: - URLRequest Builder
    
    /// Constrói URLRequest para este endpoint.
    /// - Parameter baseURL: URL base da API.
    /// - Returns: URLRequest configurada ou nil se a URL for inválida.
    public func urlRequest(baseURL: URL) -> URLRequest? {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: true
        ) else {
            return nil
        }
        
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
}

// MARK: - CustomStringConvertible

extension SPTransEndpoint: CustomStringConvertible {
    public var description: String {
        switch self {
        case .authenticate:
            return "authenticate"
        case .searchLines(let query):
            return "searchLines(\(query))"
        case .positions(let lineId):
            return "positions(\(lineId))"
        case .arrivals(let lineId):
            return "arrivals(\(lineId))"
        case .stopForecast(let stopId):
            return "stopForecast(\(stopId))"
        case .searchStops(let query):
            return "searchStops(\(query))"
        case .allPositions:
            return "allPositions"
        }
    }
}
