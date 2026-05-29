//
//  HTTPClient.swift
//  NetworkClient
//
//  Created by WIMB Team on 2026-05-21.
//

import Foundation

/// Protocolo para abstração de cliente HTTP.
///
/// Permite injeção de dependência e mocking para testes.
///
/// ## Exemplo de uso
/// ```swift
/// let client: HTTPClient = URLSessionHTTPClient()
/// let (data, response) = try await client.data(for: request)
/// ```
public protocol HTTPClient: Sendable {
    
    /// Executa uma requisição HTTP.
    /// - Parameter request: Requisição a ser executada.
    /// - Returns: Tupla com dados e resposta.
    /// - Throws: Erro de rede se a requisição falhar.
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}
