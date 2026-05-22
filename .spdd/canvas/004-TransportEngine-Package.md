# REASONS Canvas: TransportEngine Package

**ID:** WIMB-004  
**Data:** 2026-05-21  
**Fase:** 2 - Engine  
**Status:** ✅ Implementado

---

## R - Requirements (Requisitos)

### Objetivo
Criar o package `TransportEngine` que gerencia o rastreamento de múltiplas linhas de ônibus simultaneamente, com atualizações em tempo real e cache offline. Este é o "coração" do app, responsável por orquestrar todas as operações de transporte.

### User Stories

**US-001: Rastreamento de Múltiplas Linhas**
> Como usuário, quero acompanhar várias linhas de ônibus ao mesmo tempo no mapa para planejar minha viagem com múltiplas opções.

**US-002: Atualização em Tempo Real**
> Como usuário, quero ver os ônibus se movendo suavemente no mapa para saber exatamente onde eles estão.

**US-003: Funcionamento Offline**
> Como usuário, quero ver as últimas posições conhecidas mesmo sem internet para não ficar perdido.

**US-004: Previsão de Chegada Inteligente**
> Como usuário, quero previsões de chegada precisas que considerem o trânsito real para esperar o mínimo possível.

**US-005: Gerenciamento de Localização**
> Como usuário, quero que o app me localize automaticamente para ver ônibus próximos de mim.

### Acceptance Criteria

| # | Critério | Verificação |
|---|----------|-------------|
| AC1 | Suporta rastreamento de até 10 linhas simultâneas | Teste com 10 linhas diferentes |
| AC2 | Atualiza posições a cada 10 segundos | Timer configurável |
| AC3 | Mantém histórico de posições para animação | `previousCoordinate` preenchido |
| AC4 | Persiste últimas posições em cache | SwiftData ou UserDefaults |
| AC5 | Calcula ETA baseado em velocidade média | Algoritmo de previsão |
| AC6 | Notifica mudanças via `@Observable` | UI reativa |

### Definition of Done
- [ ] Actor principal (`TransportEngine`) implementado
- [ ] Suporte a múltiplas linhas simultâneas
- [ ] Sistema de polling configurável
- [ ] Cache offline funcional
- [ ] Testes unitários com cobertura > 80%
- [ ] Documentação DocC completa

---

## E - Entities (Entidades de Domínio)

### Diagrama de Componentes

```
┌─────────────────────────────────────────────────────────────────┐
│                     TransportEngine Package                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │               TransportEngine (actor)                   │    │
│  │                   [Orquestrador Principal]              │    │
│  ├────────────────────────────────────────────────────────┤    │
│  │ - trackedLines: Set<Int>                                │    │
│  │ - vehicles: [Int: [Vehicle]]                            │    │
│  │ - isPolling: Bool                                       │    │
│  │ - pollingInterval: TimeInterval                         │    │
│  ├────────────────────────────────────────────────────────┤    │
│  │ + startTracking(lineId:)                                │    │
│  │ + stopTracking(lineId:)                                 │    │
│  │ + startPolling()                                        │    │
│  │ + stopPolling()                                         │    │
│  │ + vehicles(for lineId:) -> [Vehicle]                    │    │
│  │ + allVehicles() -> [Vehicle]                            │    │
│  └────────────────────────────────────────────────────────┘    │
│                            │                                    │
│              ┌─────────────┼─────────────┐                      │
│              ▼             ▼             ▼                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │VehicleTracker│  │ CacheManager │  │LocationManager│          │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤          │
│  │ Gerencia     │  │ Persiste     │  │ Obtém        │          │
│  │ posições e   │  │ dados para   │  │ localização  │          │
│  │ histórico    │  │ modo offline │  │ do usuário   │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │               ArrivalPredictor (futuro)                 │    │
│  ├────────────────────────────────────────────────────────┤    │
│  │ - Calcula ETA baseado em:                               │    │
│  │   • Velocidade média histórica                          │    │
│  │   • Distância até parada                                │    │
│  │   • Condições de trânsito (futuro)                      │    │
│  │   • Clima (futuro)                                      │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                 │
│  States & Events:                                               │
│  ┌────────────────────────────────────────────────────────┐    │
│  │             TrackingState (@Observable)                 │    │
│  ├────────────────────────────────────────────────────────┤    │
│  │ + trackedLines: [TransportLine]                         │    │
│  │ + vehicles: [Vehicle]                                   │    │
│  │ + userLocation: Coordinate?                             │    │
│  │ + isLoading: Bool                                       │    │
│  │ + error: WIMBError?                                     │    │
│  │ + lastUpdate: Date                                      │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Fluxo de Dados

```
┌──────────┐     ┌─────────────────┐     ┌──────────────┐
│   View   │────>│ TransportEngine │────>│  SPTransAPI  │
│(SwiftUI) │<────│    (actor)      │<────│  (Network)   │
└──────────┘     └─────────────────┘     └──────────────┘
     │                   │                      │
     │                   ▼                      │
     │           ┌──────────────┐               │
     │           │ CacheManager │               │
     │           │  (SwiftData) │               │
     │           └──────────────┘               │
     │                   │                      │
     ▼                   ▼                      │
┌──────────┐     ┌──────────────┐               │
│  MapView │<────│TrackingState │<──────────────┘
│          │     │ (@Observable)│
└──────────┘     └──────────────┘
```

---

## A - Approach (Abordagem Técnica)

### Estratégia de Implementação

1. **Actor-based Engine**: `TransportEngine` como actor para thread-safety
2. **@Observable State**: `TrackingState` para reatividade com SwiftUI
3. **Polling com Task**: `Task.sleep` ao invés de Timer
4. **Cache First**: Tentar cache antes de rede quando offline
5. **Diff-based Updates**: Apenas atualizar veículos que mudaram

### Padrões Aplicados

| Padrão | Aplicação |
|--------|-----------|
| **Actor** | `TransportEngine` para estado thread-safe |
| **Observer** | `@Observable` para notificar Views |
| **Repository** | `CacheManager` abstrai persistência |
| **Strategy** | `ArrivalPredictor` com diferentes algoritmos |
| **Facade** | Engine esconde complexidade dos subsistemas |

### Algoritmo de Atualização

```
1. Iniciar polling
2. Para cada linha rastreada:
   a. Buscar posições da API
   b. Comparar com posições anteriores
   c. Atualizar `previousCoordinate` para animação
   d. Calcular heading baseado no movimento
   e. Persistir no cache
3. Notificar observers
4. Aguardar intervalo
5. Repetir
```

### Dependências

```swift
dependencies: [
    .package(path: "../WIMBCore"),
    .package(path: "../NetworkClient")
]
```

---

## S - Structure (Estrutura do Package)

### Estrutura de Diretórios

```
Packages/TransportEngine/
├── Package.swift
├── Sources/
│   └── TransportEngine/
│       ├── Engine/
│       │   ├── TransportEngine.swift       # Actor principal
│       │   ├── VehicleTracker.swift        # Gerencia veículos
│       │   └── PollingManager.swift        # Controla polling
│       ├── State/
│       │   ├── TrackingState.swift         # @Observable state
│       │   └── TrackingEvent.swift         # Eventos do engine
│       ├── Cache/
│       │   ├── CacheManager.swift          # Abstração de cache
│       │   └── SwiftDataCache.swift        # Implementação SwiftData
│       ├── Location/
│       │   └── LocationManager.swift       # CLLocationManager wrapper
│       ├── Predictions/
│       │   ├── ArrivalPredictor.swift      # Interface de previsão
│       │   └── SimpleArrivalPredictor.swift # Implementação básica
│       └── TransportEngine.swift           # Public exports
└── Tests/
    └── TransportEngineTests/
        ├── TransportEngineTests.swift
        ├── VehicleTrackerTests.swift
        └── Mocks/
            └── MockTransportService.swift
```

### Package.swift

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TransportEngine",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "TransportEngine",
            targets: ["TransportEngine"]
        )
    ],
    dependencies: [
        .package(path: "../WIMBCore"),
        .package(path: "../NetworkClient")
    ],
    targets: [
        .target(
            name: "TransportEngine",
            dependencies: ["WIMBCore", "NetworkClient"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "TransportEngineTests",
            dependencies: ["TransportEngine"]
        )
    ]
)
```

---

## O - Operations (Operações de Implementação)

### Task Breakdown

#### O1: TransportEngine Actor (Prioridade: Alta)

```
Subtasks:
├── O1.1: Criar estrutura base do actor
├── O1.2: Implementar gerenciamento de linhas rastreadas
├── O1.3: Implementar polling com Task.sleep
├── O1.4: Integrar com SPTransClient
└── O1.5: Implementar lógica de diff para updates
```

**Implementação O1 - TransportEngine.swift:**
```swift
import Foundation
import WIMBCore
import NetworkClient

/// Engine principal de rastreamento de transporte.
///
/// Gerencia o rastreamento de múltiplas linhas de ônibus simultaneamente,
/// com atualizações periódicas e suporte a cache offline.
public actor TransportEngine {
    
    // MARK: - Properties
    
    private let client: TransportService
    private let cacheManager: CacheManager
    private var trackedLineIds: Set<Int> = []
    private var vehiclesByLine: [Int: [Vehicle]] = [:]
    private var pollingTask: Task<Void, Never>?
    private var isPolling = false
    
    /// Intervalo de polling em segundos (default: 10).
    public var pollingInterval: TimeInterval = 10
    
    /// Callback para notificar atualizações de veículos.
    public var onVehiclesUpdated: (([Int: [Vehicle]]) -> Void)?
    
    // MARK: - Initialization
    
    public init(
        client: TransportService,
        cacheManager: CacheManager = InMemoryCacheManager()
    ) {
        self.client = client
        self.cacheManager = cacheManager
    }
    
    // MARK: - Public API
    
    /// Inicia o rastreamento de uma linha.
    /// - Parameter lineId: Código da linha.
    public func startTracking(lineId: Int) async throws {
        trackedLineIds.insert(lineId)
        
        // Buscar posições imediatamente
        let vehicles = try await client.fetchVehiclePositions(lineId: lineId)
        vehiclesByLine[lineId] = vehicles
        
        // Iniciar polling se ainda não estiver rodando
        if !isPolling {
            startPolling()
        }
        
        notifyUpdate()
    }
    
    /// Para o rastreamento de uma linha.
    /// - Parameter lineId: Código da linha.
    public func stopTracking(lineId: Int) {
        trackedLineIds.remove(lineId)
        vehiclesByLine.removeValue(forKey: lineId)
        
        // Parar polling se não houver mais linhas
        if trackedLineIds.isEmpty {
            stopPolling()
        }
        
        notifyUpdate()
    }
    
    /// Para o rastreamento de todas as linhas.
    public func stopAllTracking() {
        trackedLineIds.removeAll()
        vehiclesByLine.removeAll()
        stopPolling()
        notifyUpdate()
    }
    
    /// Retorna os veículos de uma linha específica.
    public func vehicles(for lineId: Int) -> [Vehicle] {
        vehiclesByLine[lineId] ?? []
    }
    
    /// Retorna todos os veículos de todas as linhas rastreadas.
    public func allVehicles() -> [Vehicle] {
        vehiclesByLine.values.flatMap { $0 }
    }
    
    /// Retorna as linhas atualmente rastreadas.
    public var trackedLines: Set<Int> {
        trackedLineIds
    }
    
    /// Indica se o engine está fazendo polling.
    public var polling: Bool {
        isPolling
    }
    
    // MARK: - Polling
    
    /// Inicia o polling de atualizações.
    public func startPolling() {
        guard !isPolling else { return }
        isPolling = true
        
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self = self else { break }
                
                await self.fetchAllPositions()
                
                try? await Task.sleep(for: .seconds(self.pollingInterval))
            }
        }
    }
    
    /// Para o polling de atualizações.
    public func stopPolling() {
        isPolling = false
        pollingTask?.cancel()
        pollingTask = nil
    }
    
    /// Força uma atualização imediata.
    public func refresh() async {
        await fetchAllPositions()
    }
    
    // MARK: - Private Methods
    
    private func fetchAllPositions() async {
        for lineId in trackedLineIds {
            do {
                let newVehicles = try await client.fetchVehiclePositions(lineId: lineId)
                updateVehicles(newVehicles, for: lineId)
            } catch {
                // Log error but continue with other lines
                print("[TransportEngine] Error fetching line \(lineId): \(error)")
            }
        }
        
        notifyUpdate()
    }
    
    private func updateVehicles(_ newVehicles: [Vehicle], for lineId: Int) {
        guard let existingVehicles = vehiclesByLine[lineId] else {
            vehiclesByLine[lineId] = newVehicles
            return
        }
        
        // Criar mapa de veículos existentes por prefixo
        var existingMap: [String: Vehicle] = [:]
        for vehicle in existingVehicles {
            existingMap[vehicle.prefix] = vehicle
        }
        
        // Atualizar posições mantendo histórico
        var updatedVehicles: [Vehicle] = []
        for var newVehicle in newVehicles {
            if let existing = existingMap[newVehicle.prefix] {
                // Manter posição anterior para animação
                if existing.coordinate != newVehicle.coordinate {
                    newVehicle = Vehicle(
                        id: existing.id,
                        prefix: newVehicle.prefix,
                        accessible: newVehicle.accessible,
                        lastUpdateTime: newVehicle.lastUpdateTime,
                        coordinate: newVehicle.coordinate,
                        previousCoordinate: existing.coordinate,
                        arrivalForecast: newVehicle.arrivalForecast
                    )
                } else {
                    // Manter veículo existente se não mudou
                    newVehicle = existing
                }
            }
            updatedVehicles.append(newVehicle)
        }
        
        vehiclesByLine[lineId] = updatedVehicles
        
        // Persistir no cache
        Task {
            await cacheManager.saveVehicles(updatedVehicles, for: lineId)
        }
    }
    
    private func notifyUpdate() {
        onVehiclesUpdated?(vehiclesByLine)
    }
}
```

---

#### O2: TrackingState Observable (Prioridade: Alta)

```
Subtasks:
├── O2.1: Criar classe @Observable
├── O2.2: Integrar com TransportEngine
├── O2.3: Expor propriedades para UI
└── O2.4: Implementar métodos de conveniência
```

**Implementação O2 - TrackingState.swift:**
```swift
import Foundation
import Observation
import WIMBCore
import NetworkClient

/// Estado observável do rastreamento de transporte.
///
/// Fornece uma interface reativa para Views SwiftUI consumirem
/// dados do TransportEngine.
@Observable
public final class TrackingState {
    
    // MARK: - Observable Properties
    
    /// Linhas atualmente rastreadas.
    public private(set) var trackedLines: [TransportLine] = []
    
    /// Todos os veículos de todas as linhas.
    public private(set) var vehicles: [Vehicle] = []
    
    /// Veículos agrupados por linha.
    public private(set) var vehiclesByLine: [Int: [Vehicle]] = [:]
    
    /// Localização atual do usuário.
    public private(set) var userLocation: Coordinate?
    
    /// Indica se está carregando dados.
    public private(set) var isLoading = false
    
    /// Erro atual (se houver).
    public private(set) var error: WIMBError?
    
    /// Data da última atualização.
    public private(set) var lastUpdate: Date?
    
    // MARK: - Private Properties
    
    private let engine: TransportEngine
    private let client: TransportService
    private var linesInfo: [Int: TransportLine] = [:]
    
    // MARK: - Initialization
    
    public init(
        client: TransportService,
        engine: TransportEngine? = nil
    ) {
        self.client = client
        self.engine = engine ?? TransportEngine(client: client)
        
        setupEngineCallbacks()
    }
    
    // MARK: - Public API
    
    /// Adiciona uma linha para rastreamento.
    /// - Parameter line: Linha a ser rastreada.
    @MainActor
    public func trackLine(_ line: TransportLine) async {
        isLoading = true
        error = nil
        
        do {
            linesInfo[line.id] = line
            trackedLines.append(line)
            
            try await engine.startTracking(lineId: line.id)
            
            isLoading = false
            lastUpdate = Date()
        } catch let wimbError as WIMBError {
            error = wimbError
            isLoading = false
        } catch {
            self.error = .networkError(underlying: error)
            isLoading = false
        }
    }
    
    /// Remove uma linha do rastreamento.
    /// - Parameter lineId: Código da linha.
    @MainActor
    public func untrackLine(_ lineId: Int) async {
        await engine.stopTracking(lineId: lineId)
        trackedLines.removeAll { $0.id == lineId }
        linesInfo.removeValue(forKey: lineId)
    }
    
    /// Para todo o rastreamento.
    @MainActor
    public func stopAll() async {
        await engine.stopAllTracking()
        trackedLines.removeAll()
        vehicles.removeAll()
        vehiclesByLine.removeAll()
        linesInfo.removeAll()
    }
    
    /// Força uma atualização.
    @MainActor
    public func refresh() async {
        isLoading = true
        await engine.refresh()
        isLoading = false
        lastUpdate = Date()
    }
    
    /// Busca linhas por termo.
    /// - Parameter query: Termo de busca.
    /// - Returns: Lista de linhas encontradas.
    @MainActor
    public func searchLines(query: String) async throws -> [TransportLine] {
        try await client.searchLines(query: query)
    }
    
    // MARK: - Computed Properties
    
    /// Número total de veículos rastreados.
    public var totalVehicleCount: Int {
        vehicles.count
    }
    
    /// Indica se há linhas sendo rastreadas.
    public var isTracking: Bool {
        !trackedLines.isEmpty
    }
    
    // MARK: - Private Methods
    
    private func setupEngineCallbacks() {
        Task { @MainActor in
            await engine.onVehiclesUpdated = { [weak self] vehiclesByLine in
                Task { @MainActor in
                    self?.vehiclesByLine = vehiclesByLine
                    self?.vehicles = vehiclesByLine.values.flatMap { $0 }
                    self?.lastUpdate = Date()
                }
            }
        }
    }
}
```

---

#### O3: LocationManager (Prioridade: Média)

**Implementação O3 - LocationManager.swift:**
```swift
import Foundation
import CoreLocation
import Observation
import WIMBCore

/// Gerenciador de localização do usuário.
@Observable
public final class LocationManager: NSObject {
    
    // MARK: - Observable Properties
    
    /// Localização atual do usuário.
    public private(set) var currentLocation: Coordinate?
    
    /// Status da autorização.
    public private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    /// Indica se a localização está sendo rastreada.
    public private(set) var isTracking = false
    
    /// Erro de localização (se houver).
    public private(set) var error: WIMBError?
    
    // MARK: - Private Properties
    
    private let locationManager = CLLocationManager()
    
    // MARK: - Initialization
    
    public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Public API
    
    /// Solicita permissão de localização.
    public func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Inicia o rastreamento de localização.
    public func startTracking() {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            error = .locationPermissionDenied
            return
        }
        
        isTracking = true
        locationManager.startUpdatingLocation()
    }
    
    /// Para o rastreamento de localização.
    public func stopTracking() {
        isTracking = false
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Computed Properties
    
    /// Indica se a localização está autorizada.
    public var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse ||
        authorizationStatus == .authorizedAlways
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    
    public func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }
        
        currentLocation = Coordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        error = nil
    }
    
    public func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        self.error = .networkError(underlying: error)
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            error = nil
        case .denied, .restricted:
            error = .locationPermissionDenied
        default:
            break
        }
    }
}
```

---

#### O4: CacheManager (Prioridade: Média)

**Implementação O4 - CacheManager.swift:**
```swift
import Foundation
import WIMBCore

/// Protocolo para gerenciamento de cache.
public protocol CacheManager: Sendable {
    
    /// Salva veículos para uma linha.
    func saveVehicles(_ vehicles: [Vehicle], for lineId: Int) async
    
    /// Recupera veículos de uma linha.
    func loadVehicles(for lineId: Int) async -> [Vehicle]?
    
    /// Limpa o cache de uma linha.
    func clearVehicles(for lineId: Int) async
    
    /// Limpa todo o cache.
    func clearAll() async
}

/// Implementação de cache em memória (para desenvolvimento).
public actor InMemoryCacheManager: CacheManager {
    
    private var cache: [Int: [Vehicle]] = [:]
    
    public init() {}
    
    public func saveVehicles(_ vehicles: [Vehicle], for lineId: Int) async {
        cache[lineId] = vehicles
    }
    
    public func loadVehicles(for lineId: Int) async -> [Vehicle]? {
        cache[lineId]
    }
    
    public func clearVehicles(for lineId: Int) async {
        cache.removeValue(forKey: lineId)
    }
    
    public func clearAll() async {
        cache.removeAll()
    }
}
```

---

#### O5: Testes (Prioridade: Alta)

**Implementação O5 - MockTransportService.swift:**
```swift
import Foundation
import WIMBCore

/// Mock do TransportService para testes.
public actor MockTransportService: TransportService {
    
    public var authenticateResult: Bool = true
    public var searchLinesResult: [TransportLine] = []
    public var vehiclePositionsResult: [Int: [Vehicle]] = [:]
    public var arrivalsResult: [Int: [Stop]] = [:]
    public var stopForecastResult: [Int: Stop] = [:]
    
    public var authenticateCalled = false
    public var searchLinesCalled = false
    public var fetchVehiclePositionsCalled = false
    
    public init() {}
    
    public func authenticate() async throws -> Bool {
        authenticateCalled = true
        return authenticateResult
    }
    
    public func searchLines(query: String) async throws -> [TransportLine] {
        searchLinesCalled = true
        return searchLinesResult
    }
    
    public func fetchVehiclePositions(lineId: Int) async throws -> [Vehicle] {
        fetchVehiclePositionsCalled = true
        return vehiclePositionsResult[lineId] ?? []
    }
    
    public func fetchArrivals(lineId: Int) async throws -> [Stop] {
        return arrivalsResult[lineId] ?? []
    }
    
    public func fetchStopForecast(stopId: Int) async throws -> Stop {
        guard let stop = stopForecastResult[stopId] else {
            throw WIMBError.stopNotFound(id: stopId)
        }
        return stop
    }
}
```

**Implementação O5 - TransportEngineTests.swift:**
```swift
import XCTest
@testable import TransportEngine
import WIMBCore

final class TransportEngineTests: XCTestCase {
    
    var sut: TransportEngine!
    var mockService: MockTransportService!
    
    override func setUp() async throws {
        mockService = MockTransportService()
        sut = TransportEngine(client: mockService)
    }
    
    // MARK: - Tracking Tests
    
    func test_startTracking_addsLineToTracked() async throws {
        // Given
        let lineId = 34041
        await mockService.setVehiclePositions([
            Vehicle(prefix: "74512", accessible: true, lastUpdateTime: "14:30",
                   coordinate: Coordinate(latitude: -23.55, longitude: -46.63))
        ], for: lineId)
        
        // When
        try await sut.startTracking(lineId: lineId)
        
        // Then
        let tracked = await sut.trackedLines
        XCTAssertTrue(tracked.contains(lineId))
    }
    
    func test_stopTracking_removesLineFromTracked() async throws {
        // Given
        let lineId = 34041
        await mockService.setVehiclePositions([], for: lineId)
        try await sut.startTracking(lineId: lineId)
        
        // When
        await sut.stopTracking(lineId: lineId)
        
        // Then
        let tracked = await sut.trackedLines
        XCTAssertFalse(tracked.contains(lineId))
    }
    
    func test_allVehicles_returnsVehiclesFromAllLines() async throws {
        // Given
        let vehicle1 = Vehicle(prefix: "74512", accessible: true, lastUpdateTime: "14:30",
                              coordinate: Coordinate(latitude: -23.55, longitude: -46.63))
        let vehicle2 = Vehicle(prefix: "74513", accessible: false, lastUpdateTime: "14:31",
                              coordinate: Coordinate(latitude: -23.56, longitude: -46.64))
        
        await mockService.setVehiclePositions([vehicle1], for: 34041)
        await mockService.setVehiclePositions([vehicle2], for: 34042)
        
        try await sut.startTracking(lineId: 34041)
        try await sut.startTracking(lineId: 34042)
        
        // When
        let allVehicles = await sut.allVehicles()
        
        // Then
        XCTAssertEqual(allVehicles.count, 2)
    }
    
    // MARK: - Position Update Tests
    
    func test_updatePreservesPreviousCoordinate() async throws {
        // Given
        let lineId = 34041
        let initialCoord = Coordinate(latitude: -23.55, longitude: -46.63)
        let newCoord = Coordinate(latitude: -23.56, longitude: -46.64)
        
        let vehicle1 = Vehicle(prefix: "74512", accessible: true, lastUpdateTime: "14:30",
                              coordinate: initialCoord)
        let vehicle2 = Vehicle(prefix: "74512", accessible: true, lastUpdateTime: "14:31",
                              coordinate: newCoord)
        
        await mockService.setVehiclePositions([vehicle1], for: lineId)
        try await sut.startTracking(lineId: lineId)
        
        // When - simulate position update
        await mockService.setVehiclePositions([vehicle2], for: lineId)
        await sut.refresh()
        
        // Then
        let vehicles = await sut.vehicles(for: lineId)
        XCTAssertEqual(vehicles.first?.previousCoordinate, initialCoord)
        XCTAssertEqual(vehicles.first?.coordinate, newCoord)
    }
}

// MARK: - Test Helpers

extension MockTransportService {
    func setVehiclePositions(_ vehicles: [Vehicle], for lineId: Int) async {
        vehiclePositionsResult[lineId] = vehicles
    }
}
```

---

## N - Norms (Normas de Desenvolvimento)

### Convenções de Código

| Regra | Descrição |
|-------|-----------|
| Actor Isolation | Usar `actor` para estado compartilhado mutável |
| @Observable | Usar para estado que Views observam |
| Task-based Polling | Usar `Task.sleep` ao invés de Timer |
| Weak References | Usar `[weak self]` em closures de longa duração |
| Error Handling | Converter todos os erros para `WIMBError` |

### Checklist de Review

- [ ] Engine é thread-safe via actor
- [ ] State é @Observable
- [ ] Polling pode ser iniciado/parado
- [ ] Suporta múltiplas linhas
- [ ] Preserva histórico de posições
- [ ] Testes cobrem cenários principais

---

## S - Safeguards (Salvaguardas)

### Restrições Técnicas

| Restrição | Motivo |
|-----------|--------|
| ❌ Não usar Timer | Preferir Task.sleep para cancelamento |
| ❌ Não fazer polling sem linhas | Evitar requests desnecessários |
| ❌ Não expor estado mutável | Encapsular via actor |
| ✅ Máximo 10 linhas simultâneas | Limite de performance |
| ✅ Mínimo 5s entre atualizações | Evitar rate limiting |

### Limites de Performance

```swift
// Configurações recomendadas
let maxTrackedLines = 10
let minPollingInterval: TimeInterval = 5
let defaultPollingInterval: TimeInterval = 10
```

---

## Anexos

### A1: Diagrama de Sequência - Atualização de Posições

```
┌────────┐     ┌───────────────┐     ┌──────────────┐     ┌─────────┐
│  View  │     │TrackingState  │     │TransportEngine│    │SPTransAPI│
└───┬────┘     └──────┬────────┘     └──────┬───────┘     └────┬────┘
    │                 │                     │                   │
    │ trackLine(line) │                     │                   │
    │────────────────>│                     │                   │
    │                 │ startTracking()     │                   │
    │                 │────────────────────>│                   │
    │                 │                     │ fetchPositions()  │
    │                 │                     │──────────────────>│
    │                 │                     │    [vehicles]     │
    │                 │                     │<──────────────────│
    │                 │                     │                   │
    │                 │ onVehiclesUpdated   │                   │
    │                 │<────────────────────│                   │
    │                 │                     │                   │
    │  vehicles[]     │                     │                   │
    │<────────────────│                     │                   │
    │                 │                     │                   │
    │                 │     ... polling ... │                   │
```

### A2: Checklist de Implementação

- [ ] O1: TransportEngine Actor
- [ ] O2: TrackingState Observable
- [ ] O3: LocationManager
- [ ] O4: CacheManager
- [ ] O5: Testes unitários
- [ ] Documentação DocC
- [ ] Integração com app
