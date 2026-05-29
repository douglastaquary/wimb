//
//  URLSessionHTTPClient.swift
//  NetworkClient
//
//  Created by WIMB Team on 2026-05-21.
//

import Foundation

/// Implementação padrão de HTTPClient usando URLSession.
public struct URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    /// Cria um cliente HTTP com a sessão especificada.
    /// - Parameter session: URLSession a ser usada (default: shared).
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}

// MARK: - Custom URLSession Configuration

extension URLSessionHTTPClient {
    
    /// Cria um cliente com timeout customizado.
    /// - Parameter timeout: Timeout em segundos.
    /// - Returns: Cliente configurado.
    public static func withTimeout(_ timeout: TimeInterval) -> URLSessionHTTPClient {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout * 2
        return URLSessionHTTPClient(session: URLSession(configuration: config))
    }
}
