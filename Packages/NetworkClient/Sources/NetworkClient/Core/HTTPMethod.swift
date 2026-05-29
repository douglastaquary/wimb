//
//  HTTPMethod.swift
//  NetworkClient
//
//  Created by WIMB Team on 2026-05-21.
//

import Foundation

/// Métodos HTTP suportados pelo cliente.
public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
