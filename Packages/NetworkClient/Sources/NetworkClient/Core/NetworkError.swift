//
//  NetworkError.swift
//  NetworkClient
//
//  Created by WIMB Team on 2026-05-21.
//

import Foundation

/// Erros de rede do NetworkClient.
///
/// Representa todos os tipos de erro que podem ocorrer
/// durante comunicação com APIs externas.
public enum NetworkError: Error, Sendable {
    
    /// Não autorizado (401/403).
    case unauthorized
    
    /// Requisição inválida (400).
    case badRequest(message: String)
    
    /// Recurso não encontrado (404).
    case notFound
    
    /// Erro do servidor (5xx).
    case serverError(statusCode: Int)
    
    /// Erro ao decodificar resposta JSON.
    case decodingError(underlying: Error)
    
    /// Erro de rede (conexão, timeout, etc).
    case networkError(underlying: Error)
    
    /// Tempo limite excedido.
    case timeout
    
    /// URL inválida.
    case invalidURL
    
    /// Nenhum dado retornado.
    case noData
}

// MARK: - LocalizedError

extension NetworkError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Não autorizado. Token inválido ou expirado."
            
        case .badRequest(let message):
            return "Requisição inválida: \(message)"
            
        case .notFound:
            return "Recurso não encontrado"
            
        case .serverError(let code):
            return "Erro do servidor (código \(code))"
            
        case .decodingError(let error):
            return "Erro ao decodificar resposta: \(error.localizedDescription)"
            
        case .networkError(let error):
            return "Erro de rede: \(error.localizedDescription)"
            
        case .timeout:
            return "Tempo limite excedido"
            
        case .invalidURL:
            return "URL inválida"
            
        case .noData:
            return "Nenhum dado retornado"
        }
    }
}

// MARK: - Factory

extension NetworkError {
    
    /// Cria erro apropriado baseado no status code HTTP.
    /// - Parameters:
    ///   - statusCode: Código de status HTTP.
    ///   - data: Dados da resposta (para mensagem de erro).
    /// - Returns: Erro correspondente ou nil se sucesso (2xx).
    public static func from(statusCode: Int, data: Data?) -> NetworkError? {
        switch statusCode {
        case 200..<300:
            return nil
            
        case 400:
            let message = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Bad Request"
            return .badRequest(message: message)
            
        case 401, 403:
            return .unauthorized
            
        case 404:
            return .notFound
            
        case 408:
            return .timeout
            
        case 500..<600:
            return .serverError(statusCode: statusCode)
            
        default:
            return .serverError(statusCode: statusCode)
        }
    }
}

// MARK: - Equatable

extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.unauthorized, .unauthorized),
             (.notFound, .notFound),
             (.timeout, .timeout),
             (.invalidURL, .invalidURL),
             (.noData, .noData):
            return true
            
        case (.badRequest(let lhsMsg), .badRequest(let rhsMsg)):
            return lhsMsg == rhsMsg
            
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
            
        default:
            return false
        }
    }
}
