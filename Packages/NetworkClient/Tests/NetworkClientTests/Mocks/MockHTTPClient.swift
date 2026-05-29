//
//  MockHTTPClient.swift
//  NetworkClientTests
//
//  Created by WIMB Team on 2026-05-21.
//

import Foundation
@testable import NetworkClient

/// Mock HTTP client para testes.
///
/// Permite configurar respostas pré-definidas para URLs específicas.
final class MockHTTPClient: HTTPClient, @unchecked Sendable {
    
    // MARK: - Properties
    
    /// Respostas configuradas por URL.
    var responses: [URL: (Data, URLResponse)] = [:]
    
    /// Erros configurados por URL.
    var errors: [URL: Error] = [:]
    
    /// Requisições recebidas (para verificação).
    var requestsReceived: [URLRequest] = []
    
    // MARK: - HTTPClient
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        requestsReceived.append(request)
        
        guard let url = request.url else {
            throw NetworkError.invalidURL
        }
        
        // Procura resposta exata primeiro
        if let response = responses[url] {
            return response
        }
        
        // Procura por URL sem query string
        if let baseURL = url.absoluteString.components(separatedBy: "?").first,
           let baseURLObj = URL(string: baseURL),
           let response = responses[baseURLObj] {
            return response
        }
        
        // Procura por path matching
        for (configuredURL, response) in responses {
            if url.path == configuredURL.path {
                return response
            }
        }
        
        if let error = errors[url] {
            throw error
        }
        
        throw NetworkError.notFound
    }
    
    // MARK: - Configuration Helpers
    
    /// Configura resposta para uma URL.
    func setResponse(_ data: Data, statusCode: Int = 200, for url: URL) {
        let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!
        responses[url] = (data, response)
    }
    
    /// Configura resposta JSON para uma URL.
    func setJSONResponse<T: Encodable>(_ value: T, statusCode: Int = 200, for url: URL) throws {
        let data = try JSONEncoder().encode(value)
        setResponse(data, statusCode: statusCode, for: url)
    }
    
    /// Configura resposta de texto para uma URL.
    func setTextResponse(_ text: String, statusCode: Int = 200, for url: URL) {
        let data = text.data(using: .utf8) ?? Data()
        setResponse(data, statusCode: statusCode, for: url)
    }
    
    /// Configura erro para uma URL.
    func setError(_ error: Error, for url: URL) {
        errors[url] = error
    }
    
    /// Limpa todas as configurações.
    func reset() {
        responses.removeAll()
        errors.removeAll()
        requestsReceived.removeAll()
    }
}
