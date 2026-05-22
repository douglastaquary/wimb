# REASONS Canvas: NetworkClient Package

**ID:** WIMB-003  
**Data:** 2026-05-21  
**Fase:** 1 - Fundação  
**Status:** 📋 Especificado

---

## R - Requirements (Requisitos)

### Objetivo
Criar o package `NetworkClient` responsável por toda comunicação com APIs externas, incluindo SPTrans, serviços de clima e futuramente Metrô/CPTM. O cliente deve ser baseado em async/await, type-safe e facilmente testável.

### User Stories

**US-001: Cliente SPTrans**
> Como app, quero consumir a API SPTrans de forma type-safe para que eu tenha garantias em tempo de compilação.

**US-002: Autenticação Segura**
> Como app, quero que o token de autenticação seja gerenciado de forma segura para evitar exposição em código.

**US-003: Tratamento de Erros**
> Como app, quero erros bem tipados e descritivos para fornecer feedback útil ao usuário.

**US-004: Testabilidade**
> Como desenvolvedor, quero poder mockar as chamadas de rede para testar sem dependência de APIs reais.

### Acceptance Criteria

| # | Critério | Verificação |
|---|----------|-------------|
| AC1 | Cliente autentica automaticamente antes de requests | Token refresh automático |
| AC2 | Todos os endpoints SPTrans estão mapeados | Compile-time safety |
| AC3 | Erros de rede são convertidos para WIMBError | Tratamento unificado |
| AC4 | Protocolo permite injeção de mock client | Testes unitários passam |
| AC5 | Suporta timeout configurável | Requests não travam |

### Definition of Done
- [ ] Todos os endpoints SPTrans implementados
- [ ] Testes com mock client
- [ ] Documentação de uso
- [ ] Token não exposto em código-fonte

---

## E - Entities (Entidades)

### Diagrama de Componentes

```
┌─────────────────────────────────────────────────────────────────┐
│                       NetworkClient                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │                  SPTransClient (actor)                  │    │
│  ├────────────────────────────────────────────────────────┤    │
│  │ - session: URLSession                                   │    │
│  │ - authToken: String?                                    │    │
│  │ - baseURL: URL                                          │    │
│  ├────────────────────────────────────────────────────────┤    │
│  │ + authenticate() async throws -> Bool                   │    │
│  │ + searchLines(query:) async throws -> [TransportLine]   │    │
│  │ + fetchPositions(lineId:) async throws -> [Vehicle]     │    │
│  │ + fetchArrivals(lineId:) async throws -> [Stop]         │    │
│  │ + fetchStopForecast(stopId:) async throws -> Stop       │    │
│  └────────────────────────────────────────────────────────┘    │
│                            │                                    │
│                            ▼                                    │
│  ┌────────────────────────────────────────────────────────┐    │
│  │                   SPTransEndpoint                       │    │
│  ├────────────────────────────────────────────────────────┤    │
│  │ case authenticate(token: String)                        │    │
│  │ case searchLines(query: String)                         │    │
│  │ case positions(lineId: Int)                             │    │
│  │ case arrivals(lineId: Int)                              │    │
│  │ case stopForecast(stopId: Int)                          │    │
│  ├────────────────────────────────────────────────────────┤    │
│  │ + path: String                                          │    │
│  │ + method: HTTPMethod                                    │    │
│  │ + queryItems: [URLQueryItem]                            │    │
│  │ + urlRequest(baseURL:) -> URLRequest                    │    │
│  └────────────────────────────────────────────────────────┘    │
│                            │                                    │
│                            ▼                                    │
│  ┌────────────────────────────────────────────────────────┐    │
│  │                   Response DTOs                         │    │
│  ├────────────────────────────────────────────────────────┤    │
│  │ • LinesResponse: [TransportLine]                        │    │
│  │ • PositionsResponse: { hr: String, vs: [Vehicle] }      │    │
│  │ • ArrivalsResponse: { hr: String, ps: [Stop] }          │    │
│  │ • StopForecastResponse: { hr: String, p: Stop }         │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │              NetworkError (enum)                        │    │
│  ├────────────────────────────────────────────────────────┤    │
│  │ case unauthorized                                       │    │
│  │ case badRequest(message: String)                        │    │
│  │ case serverError(statusCode: Int)                       │    │
│  │ case decodingError(Error)                               │    │
│  │ case networkError(Error)                                │    │
│  │ case timeout                                            │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                 │
│  Protocols:                                                     │
│  ┌────────────────────────────────────────────────────────┐    │
│  │              HTTPClient (protocol)                      │    │
│  ├────────────────────────────────────────────────────────┤    │
│  │ + data(for:) async throws -> (Data, URLResponse)        │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

### Mapeamento de Endpoints

| Endpoint | Método | Path | Query Params |
|----------|--------|------|--------------|
| Autenticar | POST | `/Login/Autenticar` | `token` |
| Buscar Linhas | GET | `/Linha/Buscar` | `termosBusca` |
| Posições | GET | `/Posicao/Linha` | `codigoLinha` |
| Previsão Linha | GET | `/Previsao/Linha` | `codigoLinha` |
| Previsão Parada | GET | `/Previsao/Parada` | `codigoParada` |

---

## A - Approach (Abordagem Técnica)

### Estratégia de Implementação

1. **Actor-based Client**: `SPTransClient` como actor para thread-safety
2. **Type-safe Endpoints**: Enum `SPTransEndpoint` com associated values
3. **Protocol Abstraction**: `HTTPClient` para injeção de mock
4. **Automatic Auth**: Interceptor que renova token automaticamente

### Padrões Aplicados

| Padrão | Aplicação |
|--------|-----------|
| **Actor** | `SPTransClient` para estado seguro |
| **Builder** | `SPTransEndpoint.urlRequest()` |
| **Strategy** | `HTTPClient` protocol para diferentes implementações |
| **Decorator** | Auth interceptor wrapping URLSession |

### Dependências

```swift
// Package.swift dependencies
dependencies: [
    .package(path: "../WIMBCore")
]
```

---

## S - Structure (Estrutura do Package)

### Estrutura de Diretórios

```
Packages/NetworkClient/
├── Package.swift
├── Sources/
│   └── NetworkClient/
│       ├── Core/
│       │   ├── HTTPClient.swift           # Protocol
│       │   ├── HTTPMethod.swift           # Enum
│       │   ├── NetworkError.swift         # Errors
│       │   └── URLSessionHTTPClient.swift # Implementation
│       ├── SPTrans/
│       │   ├── SPTransClient.swift        # Main client actor
│       │   ├── SPTransEndpoint.swift      # Endpoints enum
│       │   ├── SPTransConfiguration.swift # Config
│       │   └── DTOs/
│       │       ├── PositionsResponse.swift
│       │       ├── ArrivalsResponse.swift
│       │       └── StopForecastResponse.swift
│       ├── Weather/
│       │   └── WeatherClient.swift        # Futuro
│       └── NetworkClient.swift            # Public exports
└── Tests/
    └── NetworkClientTests/
        ├── SPTransClientTests.swift
        ├── Mocks/
        │   └── MockHTTPClient.swift
        └── Fixtures/
            └── MockResponses.swift
```

### Package.swift

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NetworkClient",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "NetworkClient",
            targets: ["NetworkClient"]
        )
    ],
    dependencies: [
        .package(path: "../WIMBCore")
    ],
    targets: [
        .target(
            name: "NetworkClient",
            dependencies: ["WIMBCore"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "NetworkClientTests",
            dependencies: ["NetworkClient"]
        )
    ]
)
```

---

## O - Operations (Operações de Implementação)

### Task Breakdown

#### O1: Core HTTP Layer (Prioridade: Alta)

```
Subtasks:
├── O1.1: Criar HTTPMethod enum
├── O1.2: Criar HTTPClient protocol
├── O1.3: Implementar URLSessionHTTPClient
├── O1.4: Criar NetworkError enum
└── O1.5: Testes unitários do HTTP layer
```

**Implementação O1.1 - HTTPMethod.swift:**
```swift
import Foundation

/// Métodos HTTP suportados.
public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
```

**Implementação O1.2 - HTTPClient.swift:**
```swift
import Foundation

/// Protocolo para abstração de cliente HTTP.
public protocol HTTPClient: Sendable {
    /// Executa uma requisição e retorna os dados.
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}
```

**Implementação O1.3 - URLSessionHTTPClient.swift:**
```swift
import Foundation

/// Implementação padrão usando URLSession.
public struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}
```

**Implementação O1.4 - NetworkError.swift:**
```swift
import Foundation

/// Erros de rede do NetworkClient.
public enum NetworkError: Error, Sendable, LocalizedError {
    case unauthorized
    case badRequest(message: String)
    case notFound
    case serverError(statusCode: Int)
    case decodingError(underlying: Error)
    case networkError(underlying: Error)
    case timeout
    case invalidURL
    case noData
    
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
    
    /// Cria erro apropriado baseado no status code HTTP.
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
        case 500..<600:
            return .serverError(statusCode: statusCode)
        default:
            return .serverError(statusCode: statusCode)
        }
    }
}
```

---

#### O2: SPTrans Endpoint (Prioridade: Alta)

```
Subtasks:
├── O2.1: Criar SPTransEndpoint enum
├── O2.2: Implementar path para cada endpoint
├── O2.3: Implementar queryItems para cada endpoint
├── O2.4: Implementar urlRequest builder
└── O2.5: Criar SPTransConfiguration
```

**Implementação O2.1-O2.4 - SPTransEndpoint.swift:**
```swift
import Foundation

/// Endpoints da API SPTrans OlhoVivo.
public enum SPTransEndpoint: Sendable {
    case authenticate(token: String)
    case searchLines(query: String)
    case positions(lineId: Int)
    case arrivals(lineId: Int)
    case stopForecast(stopId: Int)
    case allPositions
    
    /// Path do endpoint.
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
        case .allPositions:
            return []
        }
    }
    
    /// Constrói URLRequest para este endpoint.
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
        
        return request
    }
}
```

**Implementação O2.5 - SPTransConfiguration.swift:**
```swift
import Foundation

/// Configuração do cliente SPTrans.
public struct SPTransConfiguration: Sendable {
    public let baseURL: URL
    public let token: String
    public let timeout: TimeInterval
    
    public init(
        baseURL: URL = URL(string: "http://api.olhovivo.sptrans.com.br/v2.1")!,
        token: String,
        timeout: TimeInterval = 30
    ) {
        self.baseURL = baseURL
        self.token = token
        self.timeout = timeout
    }
    
    /// Configuração de desenvolvimento (não use em produção!)
    public static func development() -> SPTransConfiguration {
        SPTransConfiguration(
            token: ProcessInfo.processInfo.environment["SPTRANS_TOKEN"] ?? ""
        )
    }
}
```

---

#### O3: Response DTOs (Prioridade: Alta)

```
Subtasks:
├── O3.1: Criar PositionsResponse
├── O3.2: Criar ArrivalsResponse
└── O3.3: Criar StopForecastResponse
```

**Implementação O3.1 - PositionsResponse.swift:**
```swift
import Foundation
import WIMBCore

/// Resposta do endpoint de posições.
public struct PositionsResponse: Codable, Sendable {
    public let hour: String
    public let vehicles: [Vehicle]?
    
    enum CodingKeys: String, CodingKey {
        case hour = "hr"
        case vehicles = "vs"
    }
}
```

**Implementação O3.2 - ArrivalsResponse.swift:**
```swift
import Foundation
import WIMBCore

/// Resposta do endpoint de previsão de chegada.
public struct ArrivalsResponse: Codable, Sendable {
    public let hour: String
    public let stops: [Stop]?
    
    enum CodingKeys: String, CodingKey {
        case hour = "hr"
        case stops = "ps"
    }
}
```

**Implementação O3.3 - StopForecastResponse.swift:**
```swift
import Foundation
import WIMBCore

/// Resposta do endpoint de previsão de parada.
public struct StopForecastResponse: Codable, Sendable {
    public let hour: String
    public let stop: Stop
    
    enum CodingKeys: String, CodingKey {
        case hour = "hr"
        case stop = "p"
    }
}
```

---

#### O4: SPTransClient Actor (Prioridade: Alta)

```
Subtasks:
├── O4.1: Criar estrutura do actor
├── O4.2: Implementar authenticate
├── O4.3: Implementar searchLines
├── O4.4: Implementar fetchPositions
├── O4.5: Implementar fetchArrivals
├── O4.6: Implementar fetchStopForecast
├── O4.7: Implementar auto-auth interceptor
└── O4.8: Conformar com TransportService
```

**Implementação O4 - SPTransClient.swift:**
```swift
import Foundation
import WIMBCore

/// Cliente da API SPTrans baseado em actor para thread-safety.
public actor SPTransClient: TransportService {
    
    // MARK: - Properties
    
    private let httpClient: HTTPClient
    private let configuration: SPTransConfiguration
    private var isAuthenticated: Bool = false
    private let decoder: JSONDecoder
    
    // MARK: - Initialization
    
    public init(
        configuration: SPTransConfiguration,
        httpClient: HTTPClient = URLSessionHTTPClient()
    ) {
        self.configuration = configuration
        self.httpClient = httpClient
        self.decoder = JSONDecoder()
    }
    
    // MARK: - TransportService
    
    /// Autentica com a API SPTrans.
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
            
            // SPTrans retorna "true" ou "false" como string
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
    public func searchLines(query: String) async throws -> [TransportLine] {
        try await ensureAuthenticated()
        
        let endpoint = SPTransEndpoint.searchLines(query: query)
        return try await performRequest(endpoint: endpoint)
    }
    
    /// Busca posições de veículos de uma linha.
    public func fetchVehiclePositions(lineId: Int) async throws -> [Vehicle] {
        try await ensureAuthenticated()
        
        let endpoint = SPTransEndpoint.positions(lineId: lineId)
        let response: PositionsResponse = try await performRequest(endpoint: endpoint)
        return response.vehicles ?? []
    }
    
    /// Busca previsão de chegada para uma linha.
    public func fetchArrivals(lineId: Int) async throws -> [Stop] {
        try await ensureAuthenticated()
        
        let endpoint = SPTransEndpoint.arrivals(lineId: lineId)
        let response: ArrivalsResponse = try await performRequest(endpoint: endpoint)
        return response.stops ?? []
    }
    
    /// Busca previsão para uma parada específica.
    public func fetchStopForecast(stopId: Int) async throws -> Stop {
        try await ensureAuthenticated()
        
        let endpoint = SPTransEndpoint.stopForecast(stopId: stopId)
        let response: StopForecastResponse = try await performRequest(endpoint: endpoint)
        return response.stop
    }
    
    // MARK: - Private Helpers
    
    /// Garante que o cliente está autenticado antes de fazer requisições.
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
                // Se não autorizado, tenta re-autenticar uma vez
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

// MARK: - Convenience Initializer

extension SPTransClient {
    /// Cria cliente com token do environment.
    public static func fromEnvironment() -> SPTransClient {
        SPTransClient(configuration: .development())
    }
}
```

---

#### O5: Mock Client para Testes (Prioridade: Média)

```
Subtasks:
├── O5.1: Criar MockHTTPClient
├── O5.2: Criar MockResponses com fixtures
└── O5.3: Implementar testes do SPTransClient
```

**Implementação O5.1 - MockHTTPClient.swift:**
```swift
import Foundation
@testable import NetworkClient

/// Mock HTTP client para testes.
final class MockHTTPClient: HTTPClient, @unchecked Sendable {
    var responses: [URL: (Data, URLResponse)] = [:]
    var errors: [URL: Error] = [:]
    var requestsReceived: [URLRequest] = []
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        requestsReceived.append(request)
        
        guard let url = request.url else {
            throw NetworkError.invalidURL
        }
        
        if let error = errors[url] {
            throw error
        }
        
        if let response = responses[url] {
            return response
        }
        
        throw NetworkError.notFound
    }
    
    // MARK: - Helpers
    
    func setResponse(_ data: Data, statusCode: Int = 200, for url: URL) {
        let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!
        responses[url] = (data, response)
    }
    
    func setJSONResponse<T: Encodable>(_ value: T, statusCode: Int = 200, for url: URL) throws {
        let data = try JSONEncoder().encode(value)
        setResponse(data, statusCode: statusCode, for: url)
    }
}
```

**Implementação O5.2 - MockResponses.swift:**
```swift
import Foundation
import WIMBCore

enum MockResponses {
    static let authSuccess = "true".data(using: .utf8)!
    static let authFailure = "false".data(using: .utf8)!
    
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
        }
    ]
    """.data(using: .utf8)!
    
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
            }
        ]
    }
    """.data(using: .utf8)!
}
```

**Implementação O5.3 - SPTransClientTests.swift:**
```swift
import XCTest
@testable import NetworkClient
import WIMBCore

final class SPTransClientTests: XCTestCase {
    
    var sut: SPTransClient!
    var mockHTTPClient: MockHTTPClient!
    var configuration: SPTransConfiguration!
    
    override func setUp() {
        super.setUp()
        mockHTTPClient = MockHTTPClient()
        configuration = SPTransConfiguration(token: "test-token")
        sut = SPTransClient(configuration: configuration, httpClient: mockHTTPClient)
    }
    
    override func tearDown() {
        sut = nil
        mockHTTPClient = nil
        configuration = nil
        super.tearDown()
    }
    
    // MARK: - Authentication Tests
    
    func test_authenticate_success() async throws {
        // Given
        let authURL = URL(string: "http://api.olhovivo.sptrans.com.br/v2.1/Login/Autenticar?token=test-token")!
        mockHTTPClient.setResponse(MockResponses.authSuccess, for: authURL)
        
        // When
        let result = try await sut.authenticate()
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_authenticate_failure() async throws {
        // Given
        let authURL = URL(string: "http://api.olhovivo.sptrans.com.br/v2.1/Login/Autenticar?token=test-token")!
        mockHTTPClient.setResponse(MockResponses.authFailure, for: authURL)
        
        // When
        let result = try await sut.authenticate()
        
        // Then
        XCTAssertFalse(result)
    }
    
    // MARK: - Search Lines Tests
    
    func test_searchLines_returnsLines() async throws {
        // Given
        let authURL = URL(string: "http://api.olhovivo.sptrans.com.br/v2.1/Login/Autenticar?token=test-token")!
        let searchURL = URL(string: "http://api.olhovivo.sptrans.com.br/v2.1/Linha/Buscar?termosBusca=8000")!
        
        mockHTTPClient.setResponse(MockResponses.authSuccess, for: authURL)
        mockHTTPClient.setResponse(MockResponses.linesJSON, for: searchURL)
        
        // When
        let lines = try await sut.searchLines(query: "8000")
        
        // Then
        XCTAssertEqual(lines.count, 1)
        XCTAssertEqual(lines.first?.formattedNumber, "8000-10")
    }
    
    // MARK: - Positions Tests
    
    func test_fetchPositions_returnsVehicles() async throws {
        // Given
        let authURL = URL(string: "http://api.olhovivo.sptrans.com.br/v2.1/Login/Autenticar?token=test-token")!
        let positionsURL = URL(string: "http://api.olhovivo.sptrans.com.br/v2.1/Posicao/Linha?codigoLinha=34041")!
        
        mockHTTPClient.setResponse(MockResponses.authSuccess, for: authURL)
        mockHTTPClient.setResponse(MockResponses.positionsJSON, for: positionsURL)
        
        // When
        let vehicles = try await sut.fetchVehiclePositions(lineId: 34041)
        
        // Then
        XCTAssertEqual(vehicles.count, 1)
        XCTAssertEqual(vehicles.first?.prefix, "74512")
    }
}
```

---

## N - Norms (Normas de Desenvolvimento)

### Convenções de Código

| Regra | Descrição |
|-------|-----------|
| Actor Isolation | Usar `actor` para clientes com estado mutável |
| Error Handling | Sempre converter erros para `NetworkError` |
| Async/Await | Nunca usar callbacks ou Combine para networking |
| Timeout | Sempre definir timeout nas requisições |
| Logging | Usar `os_log` para debug, não `print` |

### Checklist de Review

- [ ] Todos os endpoints testados com mock
- [ ] Erros mapeados corretamente
- [ ] Timeout configurado
- [ ] Token não hardcoded no código
- [ ] Auto-auth implementado

---

## S - Safeguards (Salvaguardas)

### Restrições Técnicas

| Restrição | Motivo |
|-----------|--------|
| ❌ Não expor token em logs | Segurança |
| ❌ Não usar force unwrap em URLs | Crashes |
| ❌ Não fazer retry infinito | DoS prevention |
| ❌ Não ignorar status codes | Erros silenciosos |
| ✅ Usar HTTPS em produção | SPTrans usa HTTP, mas documentar |

### Validações

```swift
// Exemplo de validação de resposta
guard let httpResponse = response as? HTTPURLResponse else {
    throw NetworkError.noData
}

if let error = NetworkError.from(statusCode: httpResponse.statusCode, data: data) {
    throw error
}
```

### Segurança do Token

```swift
// Recomendação: usar Keychain
// O token NÃO deve ser commitado no código
public static func fromEnvironment() -> SPTransClient {
    guard let token = ProcessInfo.processInfo.environment["SPTRANS_TOKEN"],
          !token.isEmpty else {
        fatalError("SPTRANS_TOKEN environment variable not set")
    }
    return SPTransClient(configuration: SPTransConfiguration(token: token))
}
```

---

## Anexos

### A1: Fluxo de Autenticação

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Client    │     │ SPTransClient│     │  SPTrans    │
│   (View)    │     │   (Actor)    │     │    API      │
└──────┬──────┘     └──────┬───────┘     └──────┬──────┘
       │                   │                    │
       │ searchLines()     │                    │
       │──────────────────>│                    │
       │                   │                    │
       │                   │ isAuthenticated?   │
       │                   │────────┐           │
       │                   │<───────┘ No        │
       │                   │                    │
       │                   │ POST /Login/Auth   │
       │                   │───────────────────>│
       │                   │                    │
       │                   │      "true"        │
       │                   │<───────────────────│
       │                   │                    │
       │                   │ GET /Linha/Buscar  │
       │                   │───────────────────>│
       │                   │                    │
       │                   │    [Lines]         │
       │                   │<───────────────────│
       │                   │                    │
       │  [TransportLine]  │                    │
       │<──────────────────│                    │
       │                   │                    │
```

### A2: Checklist de Implementação

- [ ] O1: Core HTTP Layer
- [ ] O2: SPTrans Endpoint
- [ ] O3: Response DTOs
- [ ] O4: SPTransClient Actor
- [ ] O5: Mock Client para Testes
- [ ] Documentação DocC
- [ ] Integration tests (opcional)
