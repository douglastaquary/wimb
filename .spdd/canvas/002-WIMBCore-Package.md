# REASONS Canvas: WIMBCore Package

**ID:** WIMB-002  
**Data:** 2026-05-21  
**Fase:** 1 - Fundação  
**Status:** 📋 Especificado

---

## R - Requirements (Requisitos)

### Objetivo
Criar o package fundacional `WIMBCore` contendo todos os modelos de domínio, protocolos e extensões compartilhados entre os demais packages do app WIMB.

### User Stories

**US-001: Modelos de Domínio**
> Como desenvolvedor, quero modelos de domínio bem definidos e tipados para que todas as features usem uma linguagem ubíqua consistente.

**US-002: Protocolos de Abstração**
> Como desenvolvedor, quero protocolos que abstraiam serviços externos para que eu possa testar o código de forma isolada.

**US-003: Extensões Utilitárias**
> Como desenvolvedor, quero extensões úteis para tipos nativos para evitar código duplicado entre packages.

### Acceptance Criteria

| # | Critério | Verificação |
|---|----------|-------------|
| AC1 | Modelo `TransportLine` mapeia todos os campos da API SPTrans | Decodifica JSON de `/Linha/Buscar` |
| AC2 | Modelo `Vehicle` suporta coordenadas anteriores para animação | Propriedades `oldLatitude`, `oldLongitude` |
| AC3 | Modelo `Stop` contém veículos associados | Array opcional de `Vehicle` |
| AC4 | Protocolo `Coordinatable` permite uso genérico em mapas | Conformidade com tipos de mapa |
| AC5 | Todos os modelos são `Sendable` | Compilação sem warnings de concorrência |

### Definition of Done
- [ ] Todos os modelos criados e documentados
- [ ] Testes unitários com cobertura > 80%
- [ ] Package compila sem warnings
- [ ] Documentação inline com DocC

---

## E - Entities (Entidades de Domínio)

### Diagrama de Entidades

```
┌─────────────────────────────────────────────────────────────────┐
│                         WIMBCore                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐       ┌──────────────────┐                │
│  │  TransportLine   │       │     Vehicle      │                │
│  ├──────────────────┤       ├──────────────────┤                │
│  │ + id: Int        │       │ + id: UUID       │                │
│  │ + code: String   │       │ + prefix: String │                │
│  │ + number: String │       │ + coordinate: Coordinate         │
│  │ + direction: Int │       │ + previousCoordinate: Coordinate?│
│  │ + mainTerminal   │       │ + heading: Double│                │
│  │ + secondTerminal │       │ + accessible: Bool               │
│  │ + accessible: Bool       │ + lastUpdate: Date               │
│  └──────────────────┘       │ + arrivalForecast: String?       │
│           │                 └──────────────────┘                │
│           │                          │                          │
│           ▼                          │                          │
│  ┌──────────────────┐                │                          │
│  │      Stop        │◄───────────────┘                          │
│  ├──────────────────┤                                           │
│  │ + id: Int        │                                           │
│  │ + name: String   │                                           │
│  │ + coordinate: Coordinate                                     │
│  │ + vehicles: [Vehicle]?                                       │
│  └──────────────────┘                                           │
│           │                                                     │
│           ▼                                                     │
│  ┌──────────────────┐                                           │
│  │   Coordinate     │ ◄─── Value Type (struct)                  │
│  ├──────────────────┤                                           │
│  │ + latitude: Double                                           │
│  │ + longitude: Double                                          │
│  │ + clLocationCoordinate: CLLocationCoordinate2D              │
│  └──────────────────┘                                           │
│                                                                 │
│  Protocols:                                                     │
│  ┌──────────────────┐  ┌──────────────────┐                     │
│  │  Coordinatable   │  │ TransportService │                     │
│  ├──────────────────┤  ├──────────────────┤                     │
│  │ coordinate: Coord│  │ authenticate()   │                     │
│  │ heading: Double? │  │ fetchLines()     │                     │
│  └──────────────────┘  │ fetchPositions() │                     │
│                        │ fetchArrivals()  │                     │
│                        └──────────────────┘                     │
└─────────────────────────────────────────────────────────────────┘
```

### Mapeamento API → Modelo

| Campo API | Tipo API | Modelo WIMB | Propriedade |
|-----------|----------|-------------|-------------|
| `cl` | Int | TransportLine | `id` |
| `lt` | String | TransportLine | `firstPartOfSign` |
| `tl` | Int | TransportLine | `secondPartOfSign` |
| `sl` | Int | TransportLine | `direction` |
| `tp` | String | TransportLine | `mainTerminal` |
| `ts` | String | TransportLine | `secondaryTerminal` |
| `lc` | Bool | TransportLine | `circular` |
| `p` | String | Vehicle | `prefix` |
| `a` | Bool | Vehicle | `accessible` |
| `ta` | String | Vehicle | `lastUpdateTime` |
| `py` | Double | Vehicle | `coordinate.latitude` |
| `px` | Double | Vehicle | `coordinate.longitude` |
| `t` | String? | Vehicle | `arrivalForecast` |
| `cp` | Int | Stop | `id` |
| `np` | String | Stop | `name` |
| `vs` | [Vehicle]? | Stop | `vehicles` |

---

## A - Approach (Abordagem Técnica)

### Estratégia de Implementação

1. **Value Types First**: Usar `struct` para todos os modelos
2. **Sendable Compliance**: Garantir thread-safety para concorrência
3. **Codable Separation**: DTOs separados dos modelos de domínio
4. **Protocol-Oriented**: Abstrações para testabilidade

### Padrões Aplicados

| Padrão | Aplicação |
|--------|-----------|
| **Value Object** | `Coordinate` como tipo imutável |
| **DTO Pattern** | Separar modelos de rede dos de domínio |
| **Type Erasure** | Não necessário (usar generics) |
| **Protocol Witness** | Conformidades injetáveis |

### Dependências

```swift
// Package.swift dependencies
dependencies: []  // Zero dependencies - pure Swift
```

---

## S - Structure (Estrutura do Package)

### Estrutura de Diretórios

```
Packages/WIMBCore/
├── Package.swift
├── Sources/
│   └── WIMBCore/
│       ├── Models/
│       │   ├── TransportLine.swift
│       │   ├── Vehicle.swift
│       │   ├── Stop.swift
│       │   ├── Coordinate.swift
│       │   ├── Route.swift
│       │   └── Prediction.swift
│       ├── Protocols/
│       │   ├── Coordinatable.swift
│       │   ├── TransportService.swift
│       │   └── LocationTracking.swift
│       ├── Extensions/
│       │   ├── Double+Truncate.swift
│       │   ├── CLLocationCoordinate2D+Extensions.swift
│       │   └── Date+Formatting.swift
│       ├── Errors/
│       │   └── WIMBError.swift
│       └── WIMBCore.swift  // Public exports
└── Tests/
    └── WIMBCoreTests/
        ├── Models/
        │   ├── TransportLineTests.swift
        │   ├── VehicleTests.swift
        │   └── CoordinateTests.swift
        └── Fixtures/
            └── TestData.swift
```

### Package.swift

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WIMBCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "WIMBCore",
            targets: ["WIMBCore"]
        )
    ],
    targets: [
        .target(
            name: "WIMBCore",
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "WIMBCoreTests",
            dependencies: ["WIMBCore"]
        )
    ]
)
```

---

## O - Operations (Operações de Implementação)

### Task Breakdown

#### O1: Setup do Package (Prioridade: Alta)

```
Subtasks:
├── O1.1: Criar estrutura de diretórios
├── O1.2: Configurar Package.swift com Swift 6
├── O1.3: Criar arquivo de exports WIMBCore.swift
└── O1.4: Configurar target de testes
```

**Implementação O1.2 - Package.swift:**
```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WIMBCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "WIMBCore", targets: ["WIMBCore"])
    ],
    targets: [
        .target(
            name: "WIMBCore",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "WIMBCoreTests",
            dependencies: ["WIMBCore"]
        )
    ]
)
```

---

#### O2: Modelo Coordinate (Prioridade: Alta)

```
Subtasks:
├── O2.1: Criar struct Coordinate
├── O2.2: Implementar Codable
├── O2.3: Implementar Hashable e Equatable
├── O2.4: Adicionar computed property para CLLocationCoordinate2D
└── O2.5: Implementar cálculo de ângulo entre coordenadas
```

**Implementação O2 - Coordinate.swift:**
```swift
import Foundation
import CoreLocation

/// Representa uma coordenada geográfica imutável.
public struct Coordinate: Sendable, Hashable, Codable {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    /// Converte para CLLocationCoordinate2D do CoreLocation.
    public var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// Calcula o ângulo de direção para outra coordenada (em radianos).
    public func bearing(to destination: Coordinate) -> Double {
        let deltaLongitude = destination.longitude - longitude
        let deltaLatitude = destination.latitude - latitude
        let angle = (.pi * 0.5) - atan(deltaLatitude / deltaLongitude)
        
        if deltaLongitude > 0 {
            return angle
        } else if deltaLongitude < 0 {
            return angle + .pi
        } else if deltaLatitude < 0 {
            return .pi
        }
        return 0.0
    }
    
    /// Trunca coordenadas para precisão específica.
    public func truncated(places: Int = 6) -> Coordinate {
        Coordinate(
            latitude: latitude.truncated(places: places),
            longitude: longitude.truncated(places: places)
        )
    }
}

extension Coordinate {
    /// Coordenada padrão de São Paulo (Praça da Sé).
    public static let saoPauloDefault = Coordinate(
        latitude: -23.550520,
        longitude: -46.633308
    )
}
```

---

#### O3: Modelo Vehicle (Prioridade: Alta)

```
Subtasks:
├── O3.1: Criar struct Vehicle
├── O3.2: Mapear CodingKeys para API SPTrans
├── O3.3: Adicionar propriedade previousCoordinate para animação
├── O3.4: Implementar conformidade com Coordinatable
└── O3.5: Criar método para atualizar posição mantendo histórico
```

**Implementação O3 - Vehicle.swift:**
```swift
import Foundation

/// Representa um veículo (ônibus) em operação.
public struct Vehicle: Sendable, Identifiable, Hashable, Codable {
    public let id: UUID
    public let prefix: String
    public let accessible: Bool
    public let lastUpdateTime: String
    public var coordinate: Coordinate
    public var previousCoordinate: Coordinate?
    public var arrivalForecast: String?
    
    public init(
        id: UUID = UUID(),
        prefix: String,
        accessible: Bool,
        lastUpdateTime: String,
        coordinate: Coordinate,
        previousCoordinate: Coordinate? = nil,
        arrivalForecast: String? = nil
    ) {
        self.id = id
        self.prefix = prefix
        self.accessible = accessible
        self.lastUpdateTime = lastUpdateTime
        self.coordinate = coordinate
        self.previousCoordinate = previousCoordinate
        self.arrivalForecast = arrivalForecast
    }
    
    // MARK: - Codable (API SPTrans mapping)
    
    enum CodingKeys: String, CodingKey {
        case prefix = "p"
        case accessible = "a"
        case lastUpdateTime = "ta"
        case latitude = "py"
        case longitude = "px"
        case arrivalForecast = "t"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.prefix = try container.decode(String.self, forKey: .prefix)
        self.accessible = try container.decode(Bool.self, forKey: .accessible)
        self.lastUpdateTime = try container.decode(String.self, forKey: .lastUpdateTime)
        let lat = try container.decode(Double.self, forKey: .latitude)
        let lon = try container.decode(Double.self, forKey: .longitude)
        self.coordinate = Coordinate(latitude: lat, longitude: lon)
        self.previousCoordinate = nil
        self.arrivalForecast = try container.decodeIfPresent(String.self, forKey: .arrivalForecast)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(prefix, forKey: .prefix)
        try container.encode(accessible, forKey: .accessible)
        try container.encode(lastUpdateTime, forKey: .lastUpdateTime)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encodeIfPresent(arrivalForecast, forKey: .arrivalForecast)
    }
    
    // MARK: - Business Logic
    
    /// Calcula o ângulo de direção baseado no movimento.
    public var heading: Double {
        guard let previous = previousCoordinate else { return 0 }
        return previous.bearing(to: coordinate)
    }
    
    /// Atualiza a posição mantendo a coordenada anterior para animação.
    public mutating func updatePosition(to newCoordinate: Coordinate) {
        previousCoordinate = coordinate
        coordinate = newCoordinate
    }
    
    /// Verifica se o veículo se moveu desde a última atualização.
    public var hasMoved: Bool {
        guard let previous = previousCoordinate else { return false }
        return previous != coordinate
    }
}

// MARK: - Coordinatable

extension Vehicle: Coordinatable {
    public var displayTitle: String { prefix }
    public var displaySubtitle: String? { arrivalForecast }
}
```

---

#### O4: Modelo TransportLine (Prioridade: Alta)

```
Subtasks:
├── O4.1: Criar struct TransportLine
├── O4.2: Mapear CodingKeys para API SPTrans
├── O4.3: Criar computed property para número formatado
└── O4.4: Implementar Hashable e Equatable
```

**Implementação O4 - TransportLine.swift:**
```swift
import Foundation

/// Representa uma linha de transporte público.
public struct TransportLine: Sendable, Identifiable, Hashable, Codable {
    public let id: Int
    public let firstPartOfSign: String
    public let secondPartOfSign: Int
    public let direction: Int
    public let mainTerminal: String
    public let secondaryTerminal: String
    public let circular: Bool
    
    public init(
        id: Int,
        firstPartOfSign: String,
        secondPartOfSign: Int,
        direction: Int,
        mainTerminal: String,
        secondaryTerminal: String,
        circular: Bool
    ) {
        self.id = id
        self.firstPartOfSign = firstPartOfSign
        self.secondPartOfSign = secondPartOfSign
        self.direction = direction
        self.mainTerminal = mainTerminal
        self.secondaryTerminal = secondaryTerminal
        self.circular = circular
    }
    
    // MARK: - Codable (API SPTrans mapping)
    
    enum CodingKeys: String, CodingKey {
        case id = "cl"
        case firstPartOfSign = "lt"
        case secondPartOfSign = "tl"
        case direction = "sl"
        case mainTerminal = "tp"
        case secondaryTerminal = "ts"
        case circular = "lc"
    }
    
    // MARK: - Computed Properties
    
    /// Número completo da linha formatado (ex: "8000-10").
    public var formattedNumber: String {
        "\(firstPartOfSign)-\(secondPartOfSign)"
    }
    
    /// Descrição completa da rota.
    public var routeDescription: String {
        "\(mainTerminal) → \(secondaryTerminal)"
    }
    
    /// Descrição curta para exibição em lista.
    public var shortDescription: String {
        "\(formattedNumber) - \(mainTerminal)"
    }
}
```

---

#### O5: Modelo Stop (Prioridade: Alta)

```
Subtasks:
├── O5.1: Criar struct Stop
├── O5.2: Mapear CodingKeys para API SPTrans
├── O5.3: Incluir array de veículos associados
└── O5.4: Implementar Coordinatable
```

**Implementação O5 - Stop.swift:**
```swift
import Foundation

/// Representa uma parada de ônibus.
public struct Stop: Sendable, Identifiable, Hashable, Codable {
    public let id: Int
    public let name: String
    public let coordinate: Coordinate
    public var vehicles: [Vehicle]?
    
    public init(
        id: Int,
        name: String,
        coordinate: Coordinate,
        vehicles: [Vehicle]? = nil
    ) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.vehicles = vehicles
    }
    
    // MARK: - Codable (API SPTrans mapping)
    
    enum CodingKeys: String, CodingKey {
        case id = "cp"
        case name = "np"
        case latitude = "py"
        case longitude = "px"
        case vehicles = "vs"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        let lat = try container.decode(Double.self, forKey: .latitude)
        let lon = try container.decode(Double.self, forKey: .longitude)
        self.coordinate = Coordinate(latitude: lat, longitude: lon)
        self.vehicles = try container.decodeIfPresent([Vehicle].self, forKey: .vehicles)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encodeIfPresent(vehicles, forKey: .vehicles)
    }
    
    // MARK: - Computed Properties
    
    /// Número de veículos próximos.
    public var vehicleCount: Int {
        vehicles?.count ?? 0
    }
    
    /// Verifica se há veículos próximos.
    public var hasVehicles: Bool {
        vehicleCount > 0
    }
}

// MARK: - Coordinatable

extension Stop: Coordinatable {
    public var displayTitle: String { name }
    public var displaySubtitle: String? {
        hasVehicles ? "\(vehicleCount) ônibus próximo(s)" : nil
    }
    public var heading: Double? { nil }
}
```

---

#### O6: Protocolos (Prioridade: Média)

**Implementação O6 - Coordinatable.swift:**
```swift
import Foundation

/// Protocolo para elementos que podem ser exibidos em um mapa.
public protocol Coordinatable: Identifiable, Sendable {
    var coordinate: Coordinate { get }
    var heading: Double? { get }
    var displayTitle: String { get }
    var displaySubtitle: String? { get }
}

extension Coordinatable {
    public var heading: Double? { nil }
    public var displaySubtitle: String? { nil }
}
```

**Implementação O6 - TransportService.swift:**
```swift
import Foundation

/// Protocolo para serviços de transporte público.
public protocol TransportService: Sendable {
    /// Autentica com a API.
    func authenticate() async throws -> Bool
    
    /// Busca linhas por termo.
    func searchLines(query: String) async throws -> [TransportLine]
    
    /// Busca posições de veículos de uma linha.
    func fetchVehiclePositions(lineId: Int) async throws -> [Vehicle]
    
    /// Busca previsão de chegada para uma linha.
    func fetchArrivals(lineId: Int) async throws -> [Stop]
    
    /// Busca previsão para uma parada específica.
    func fetchStopForecast(stopId: Int) async throws -> Stop
}
```

---

#### O7: Extensions (Prioridade: Média)

**Implementação O7 - Double+Truncate.swift:**
```swift
import Foundation

extension Double {
    /// Trunca o número para um número específico de casas decimais.
    public func truncated(places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return floor(multiplier * self) / multiplier
    }
}
```

---

#### O8: Erros (Prioridade: Média)

**Implementação O8 - WIMBError.swift:**
```swift
import Foundation

/// Erros do domínio WIMB.
public enum WIMBError: Error, Sendable, LocalizedError {
    case authenticationFailed
    case networkError(underlying: Error)
    case decodingError(underlying: Error)
    case invalidResponse
    case lineNotFound(id: Int)
    case stopNotFound(id: Int)
    case noVehiclesAvailable
    case locationPermissionDenied
    
    public var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "Falha na autenticação com a API SPTrans"
        case .networkError(let error):
            return "Erro de rede: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Erro ao processar dados: \(error.localizedDescription)"
        case .invalidResponse:
            return "Resposta inválida do servidor"
        case .lineNotFound(let id):
            return "Linha \(id) não encontrada"
        case .stopNotFound(let id):
            return "Parada \(id) não encontrada"
        case .noVehiclesAvailable:
            return "Nenhum veículo disponível"
        case .locationPermissionDenied:
            return "Permissão de localização negada"
        }
    }
}
```

---

## N - Norms (Normas de Desenvolvimento)

### Convenções de Código

| Regra | Descrição |
|-------|-----------|
| Naming | CamelCase para tipos, lowerCamelCase para propriedades |
| Access Control | `public` para API exposta, `internal` para implementação |
| Documentation | DocC comments para todos os tipos públicos |
| Immutability | Preferir `let` sobre `var`, structs sobre classes |
| Optionals | Evitar force unwrap, usar `guard let` ou `if let` |

### Checklist de Review

- [ ] Todos os tipos públicos têm documentação DocC
- [ ] Nenhum `!` (force unwrap) no código
- [ ] Todos os tipos são `Sendable`
- [ ] Testes unitários para cada modelo
- [ ] Sem dependências externas

---

## S - Safeguards (Salvaguardas)

### Restrições Técnicas

| Restrição | Motivo |
|-----------|--------|
| ❌ Não usar classes | Preferir value types para thread-safety |
| ❌ Não importar UIKit | Package deve ser multiplataforma |
| ❌ Não fazer I/O | Responsabilidade do NetworkClient |
| ❌ Não usar singletons | Injetar dependências |
| ✅ CoreLocation apenas para tipos | CLLocationCoordinate2D é permitido |

### Validações Automáticas

```swift
// Exemplo de validação em Coordinate
public init(latitude: Double, longitude: Double) {
    precondition((-90...90).contains(latitude), "Latitude deve estar entre -90 e 90")
    precondition((-180...180).contains(longitude), "Longitude deve estar entre -180 e 180")
    self.latitude = latitude
    self.longitude = longitude
}
```

---

## Anexos

### A1: JSON de Exemplo - API SPTrans

**Resposta `/Linha/Buscar?termosBusca=8000`:**
```json
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
```

**Resposta `/Posicao/Linha?codigoLinha=34041`:**
```json
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
```

### A2: Checklist de Implementação

- [ ] O1: Setup do Package
- [ ] O2: Modelo Coordinate
- [ ] O3: Modelo Vehicle
- [ ] O4: Modelo TransportLine
- [ ] O5: Modelo Stop
- [ ] O6: Protocolos
- [ ] O7: Extensions
- [ ] O8: Erros
- [ ] Testes unitários
- [ ] Documentação DocC
