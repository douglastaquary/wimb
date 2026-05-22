# Análise do Codebase Atual - WIMB

**Data:** 2026-05-21  
**Versão Analisada:** Commit atual (pré-refatoração)

---

## 1. Visão Geral

O WhereIsMyBus (WIMB) é um aplicativo iOS para rastreamento de ônibus em tempo real em São Paulo, usando a API SPTrans OlhoVivo.

### Estatísticas do Codebase

| Métrica | Valor |
|---------|-------|
| Arquivos Swift | 34 |
| Linhas de código (estimado) | ~2500 |
| Features principais | 3 (Lista, Detalhe, Mapa) |
| Plataformas | iOS, macOS (parcial) |

---

## 2. Arquitetura Atual

### 2.1 Padrão Identificado: MVVM Parcial

```
┌─────────────────────────────────────────────────────────────┐
│                    Arquitetura Atual                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌──────────────────┐    ┌───────────┐  │
│  │    View     │───>│    ViewModel     │───>│   API     │  │
│  │  (SwiftUI)  │<───│ (ObservableObject)│<───│ (Combine) │  │
│  └─────────────┘    └──────────────────┘    └───────────┘  │
│        │                    │                     │         │
│        │                    │                     │         │
│        ▼                    ▼                     ▼         │
│  TripListView         TripViewModel         APISPTrans     │
│  TripDetailView       TripDetailViewModel   WimbApiService │
│  TripMapView          TripMapViewModel                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Problemas Arquiteturais

| # | Problema | Impacto | Arquivos Afetados |
|---|----------|---------|-------------------|
| 1 | ViewModels acoplados à API | Não testável | TripViewModel, TripDetailViewModel |
| 2 | Sem camada de Repository | Sem cache | Todos os ViewModels |
| 3 | Combine + async/await misturados | Inconsistência | APISPTrans, ViewModels |
| 4 | UIKit dentro do SwiftUI | Complexidade | MapViewController, MapViewKit |
| 5 | Código duplicado | Manutenção | LocationService, BusRouterService |
| 6 | Token hardcoded | Segurança | APISPTrans.swift |

---

## 3. Análise por Camada

### 3.1 Camada de Rede (Backend)

**Arquivos:**
- `APISPTrans.swift` - Cliente API principal
- `WimbApiService.swift` - HTTP layer genérico

**Análise:**

```swift
// APISPTrans.swift - Problemas identificados:

// ❌ Token hardcoded (SEGURANÇA)
public static let token = "f89300e7615320c82cb1d9911d26c3dba054338ba9c39059bc2d9a414091ece8"

// ❌ Force unwrap sem tratamento
guard var components = URLComponents(...) else { 
    fatalError("Couldn't create URLComponents")  // ❌ Crash em produção
}

// ❌ Combine quando async/await seria melhor
static func fetchTrips(...) -> AnyPublisher<[Trip], Error>

// ❌ Sem retry ou rate limiting
// ❌ Sem cache
```

**Recomendações:**
1. Mover token para Keychain ou Environment
2. Usar `throws` ao invés de `fatalError`
3. Migrar para async/await
4. Adicionar camada de cache

### 3.2 Modelos (Models)

**Arquivos:**
- `Vehicle.swift` - Modelo de ônibus
- `Trip.swift` - Modelo de linha
- `StopBus.swift` - Modelo de parada
- `MapAnnotation.swift` - Annotations UIKit

**Análise:**

```swift
// Vehicle.swift - Pontos positivos e negativos:

// ✅ Codable com CodingKeys corretos
enum CodingKeys: String, CodingKey {
    case vehiclePrefix = "p"
    case arrivalForecast = "t"
    // ...
}

// ✅ Computed property para coordinate
var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
}

// ❌ Lógica de UI no modelo (angleFromCoordinate)
func angleFromCoordinate(...) -> Double  // Deveria estar em uma extension ou helper

// ❌ annotationType é opcional com default - gera confusão
var annotationType: AnnotationType? = .bus
```

**Recomendações:**
1. Separar lógica de cálculo de ângulo para helper
2. Tornar modelos `Sendable`
3. Remover referências a UI dos modelos

### 3.3 ViewModels

**Arquivos:**
- `TripViewModel.swift`
- `TripDetailViewModel.swift`
- `TripMapViewModel.swift`

**Análise:**

```swift
// TripViewModel.swift - Problemas:

// ❌ Acoplamento direto com API
func checkAuth() {
    anyCancellation = APISPTrans.checkAuth(.auth)  // Sem abstração
        .mapError(...)
        .sink(...)
}

// ❌ Estado mutável sem proteção
@Published var trips: [Trip] = []  // Pode ser modificado de qualquer lugar

// ❌ Mistura de responsabilidades
// ViewModel faz: auth + busca + estado de loading
```

```swift
// TripMapViewModel.swift - Problemas:

// ❌ Classe muito grande (>200 linhas)
// ❌ Múltiplas responsabilidades:
//    - Gerenciamento de localização
//    - Gerenciamento de annotations
//    - Timer para polling
//    - Cálculo de ângulos
//    - Estado do mapa

// ❌ Código morto (comentado)
//configStopAnnotations()
//self.setupTimerPublisher()

// ❌ Retain cycles potenciais
.sink { [weak self] (output) in
    guard let `self` = self else { return }  // ❌ Uso de `self` backticks
```

**Recomendações:**
1. Injetar dependências via protocolo
2. Dividir responsabilidades em services menores
3. Usar `@Observable` macro do Swift 6
4. Remover código morto

### 3.4 Views

**Arquivos:**
- `TripListView.swift`
- `TripDatailView.swift`
- `TripMapView.swift`
- `MapViewController.swift`

**Análise:**

```swift
// TripListView.swift - Pontos:

// ✅ Uso básico de SwiftUI
NavigationView {
    VStack {
        SearchBarView(...)
        List { ... }
    }
}

// ❌ ViewModel criado inline (não injetável)
@ObservedObject var viewModel = TripViewModel()

// ❌ UITableView appearance no init
init() {
    UITableView.appearance().backgroundColor = .clear  // ❌ Deprecated approach
}
```

```swift
// MapViewController.swift - Problemas:

// ❌ UIKit direto no projeto SwiftUI
final class MapViewController: UIViewController

// ❌ Timer manual (deveria usar async/await)
gameTimer = Timer.scheduledTimer(timeInterval: 10, ...)

// ❌ Force cast
let annotationView = mapView.view(for: myAnnotation) as! AnnotationView  // ❌ Crash potential
```

**Recomendações:**
1. Usar SwiftUI Map nativo
2. Injetar ViewModels
3. Substituir Timer por Task com sleep

### 3.5 Animação de Veículos

**Arquivos:**
- `LocationService.swift`
- `BusRouterService.swift`
- `TripMapViewModel.swift`

**Análise:**

```swift
// Lógica de animação duplicada em 3 arquivos:

// LocationService.swift:
func updateLocationOnMap(model: Vehicle, myAnnotation: BusMapAnnotation, mapView: MKMapView) {
    UIView.animate(withDuration: 2, ...) {
        myAnnotation.coordinate = newLocation
        annotationView.transform = CGAffineTransform(rotationAngle: ...)
    }
}

// BusRouterService.swift - MESMO CÓDIGO duplicado
// TripMapViewModel.swift - MESMO CÓDIGO duplicado
```

**Recomendações:**
1. Centralizar lógica de animação em um único `VehicleAnimator`
2. Usar SwiftUI animations ao invés de UIView.animate
3. Considerar `TimelineView` para atualizações contínuas

---

## 4. Dependências Externas

| Dependência | Tipo | Uso |
|-------------|------|-----|
| SwiftUI | Framework Apple | UI |
| Combine | Framework Apple | Networking |
| MapKit | Framework Apple | Mapas |
| CoreLocation | Framework Apple | Localização |

**Nota:** O app não usa dependências de terceiros, o que é positivo.

---

## 5. Mapeamento de Features para Refatoração

### 5.1 Feature: Busca de Linhas

| Componente Atual | Componente Novo |
|------------------|-----------------|
| `TripListView` | `SearchFeature/SearchView` |
| `TripViewModel` | `SearchFeature/SearchState` |
| `APISPTrans.fetchTrips` | `NetworkClient/SPTransClient.searchLines` |

### 5.2 Feature: Detalhes da Linha

| Componente Atual | Componente Novo |
|------------------|-----------------|
| `TripDatailView` | `RouteFeature/RouteDetailView` |
| `TripDetailViewModel` | `RouteFeature/RouteDetailState` |
| `APISPTrans.performTripArrives` | `NetworkClient/SPTransClient.fetchArrivals` |

### 5.3 Feature: Mapa em Tempo Real

| Componente Atual | Componente Novo |
|------------------|-----------------|
| `TripMapView` | `MapFeature/TransportMapView` |
| `MapViewController` | `MapFeature/VehicleAnnotation` (SwiftUI) |
| `TripMapViewModel` | `TransportEngine/VehicleTracker` |
| `BusRouterService` | `TransportEngine/RouteManager` |
| `LocationService` | `TransportEngine/LocationManager` |

---

## 6. Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| Token exposto | Alta | Crítico | Mover para Keychain |
| Crashes por force unwrap | Média | Alto | Refatorar para optional handling |
| Memory leaks em Combine | Média | Médio | Migrar para async/await |
| Performance do mapa | Baixa | Alto | Usar SwiftUI Map nativo |

---

## 7. Código a Preservar

### Lógica de negócio válida:

```swift
// Cálculo de ângulo - mover para Coordinate extension
func angleFromCoordinate(firstCoordinate: CLLocationCoordinate2D, 
                         secondCoordinate: CLLocationCoordinate2D) -> Double {
    let deltaLongitude = secondCoordinate.longitude - firstCoordinate.longitude
    let deltaLatitude = secondCoordinate.latitude - firstCoordinate.latitude
    let angle = (.pi * 0.5) - atan(deltaLatitude / deltaLongitude)
    // ...
}

// Truncate de coordenadas - mover para Double extension
func truncate(places: Int) -> Double {
    Double(floor(pow(10.0, Double(places)) * self) / pow(10.0, Double(places)))
}

// CodingKeys para API SPTrans - preservar mapeamento
enum CodingKeys: String, CodingKey {
    case vehiclePrefix = "p"
    case arrivalForecast = "t"
    // ...
}
```

### Assets a preservar:

- `bus_top.imageset` - Ícone do ônibus para mapa
- Todos os SF Symbols já em uso

---

## 8. Métricas de Sucesso da Refatoração

| Métrica | Valor Atual | Meta |
|---------|-------------|------|
| Cobertura de testes | 0% | >70% |
| Linhas por arquivo | >200 | <150 |
| Dependências por módulo | N/A | <3 |
| Warnings de compilação | Vários | 0 |
| Crashes conhecidos | 2+ (force unwrap) | 0 |

---

## 9. Conclusão

O codebase atual funciona, mas tem débito técnico significativo que impede:
- Adição de múltiplas linhas simultâneas
- Testes automatizados
- Manutenção fácil
- Evolução para features de AI

A refatoração proposta com SPM resolve esses problemas mantendo a funcionalidade existente.
