//
//  MockResponses.swift
//  NetworkClientTests
//
//  Created by WIMB Team on 2026-05-21.
//

import Foundation

/// Respostas mock para testes.
enum MockResponses {
    
    // MARK: - Authentication
    
    static let authSuccess = "true".data(using: .utf8)!
    static let authFailure = "false".data(using: .utf8)!
    
    // MARK: - Lines
    
    static let linesJSON = """
    [
        {
            "cl": 34041,
            "lc": false,
            "lt": "8000",
            "tl": 10,
            "sl": 1,
            "tp": "METRÔ JABAQUARA",
            "ts": "TERMINAL JOÃO DIAS"
        },
        {
            "cl": 34042,
            "lc": false,
            "lt": "8000",
            "tl": 10,
            "sl": 2,
            "tp": "TERMINAL JOÃO DIAS",
            "ts": "METRÔ JABAQUARA"
        }
    ]
    """.data(using: .utf8)!
    
    static let emptyLinesJSON = "[]".data(using: .utf8)!
    
    // MARK: - Positions
    
    static let positionsJSON = """
    {
        "hr": "14:30",
        "vs": [
            {
                "p": "74512",
                "a": true,
                "ta": "2026-05-21T14:28:00Z",
                "py": -23.660826,
                "px": -46.679442
            },
            {
                "p": "74513",
                "a": false,
                "ta": "2026-05-21T14:29:00Z",
                "py": -23.661000,
                "px": -46.680000
            }
        ]
    }
    """.data(using: .utf8)!
    
    static let emptyPositionsJSON = """
    {
        "hr": "14:30",
        "vs": null
    }
    """.data(using: .utf8)!
    
    // MARK: - Arrivals
    
    static let arrivalsJSON = """
    {
        "hr": "14:30",
        "ps": [
            {
                "cp": 12345,
                "np": "Av. Paulista, 1000",
                "py": -23.561414,
                "px": -46.655882,
                "vs": [
                    {
                        "p": "74512",
                        "a": true,
                        "ta": "14:30",
                        "py": -23.562,
                        "px": -46.656,
                        "t": "3 min"
                    }
                ]
            }
        ]
    }
    """.data(using: .utf8)!
    
    static let stopForecastJSON = """
    {
        "hr": "14:30",
        "p": {
            "cp": 12345,
            "np": "Av. Paulista, 1000",
            "py": -23.561414,
            "px": -46.655882,
            "vs": [
                {
                    "p": "74512",
                    "a": true,
                    "ta": "14:30",
                    "py": -23.562,
                    "px": -46.656,
                    "t": "3 min"
                }
            ]
        }
    }
    """.data(using: .utf8)!

    static let searchStopsJSON = """
    [
        {
            "cp": 12345,
            "np": "Av. Paulista, 1000",
            "py": -23.561414,
            "px": -46.655882
        },
        {
            "cp": 67890,
            "np": "Consolação",
            "py": -23.555,
            "px": -46.660
        }
    ]
    """.data(using: .utf8)!
}

// MARK: - URLs

extension MockResponses {
    
    static let baseURL = URL(string: "http://api.olhovivo.sptrans.com.br/v2.1")!
    
    static var authURL: URL {
        baseURL.appendingPathComponent("/Login/Autenticar")
    }
    
    static var searchLinesURL: URL {
        baseURL.appendingPathComponent("/Linha/Buscar")
    }
    
    static var positionsURL: URL {
        baseURL.appendingPathComponent("/Posicao/Linha")
    }
    
    static var arrivalsURL: URL {
        baseURL.appendingPathComponent("/Previsao/Linha")
    }
    
    static var stopForecastURL: URL {
        baseURL.appendingPathComponent("/Previsao/Parada")
    }

    static var searchStopsURL: URL {
        baseURL.appendingPathComponent("/Parada/Buscar")
    }
}
