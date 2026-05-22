# Guia de Integração dos Packages SPM

**Data:** 2026-05-21  
**Fase:** 3 - UI/UX (MapFeature + DesignSystem)

---

## Requisito de Ferramentas

| Ferramenta | Versão mínima |
|------------|---------------|
| Xcode | **14.2+** |
| Swift | **5.7+** |
| iOS Deployment Target | **16.0** |

> **Nota:** Estado da UI via `ObservableObject` + `@Published` (iOS 16). Packages usam monorepo umbrella em `Packages/Package.swift` — requisito para Xcode 14.

## 1. Packages no Projeto Xcode

O app referencia **um package umbrella** (`Packages/`) que expõe todos os produtos:

| Produto | Módulo | Descrição |
|---------|--------|-----------|
| WIMBCore | `Packages/WIMBCore/` | Modelos e protocolos |
| NetworkClient | `Packages/NetworkClient/` | Cliente HTTP + SPTrans |
| TransportEngine | `Packages/TransportEngine/` | Polling, cache, `TrackingState` |
| DesignSystem | `Packages/DesignSystem/` | Cores, tipografia, bottom sheet |
| MapFeature | `Packages/MapFeature/` | Mapa full-screen + layout Uber |

Configuração em `WhereIsMyBus.xcodeproj`:

- `XCRemoteSwiftPackageReference` → `Packages` (branch `main`)
- Produtos vinculados aos targets **iOS** e **macOS**

> **Importante:** `Packages/` tem repositório git local próprio. Após editar código SPM, commitar dentro de `Packages/` para o Xcode resolver as mudanças.

Ver também: [Packages/README.md](../Packages/README.md)

### Adicionar manualmente (se necessário)

1. **File → Add Package Dependencies... → Add Local...**
2. Selecione a pasta **`Packages`** (não subpastas individuais)
3. Vincule os produtos desejados ao target **iOS**

---

## 2. Configuração do Token SPTrans

### Opção A: Variável de Ambiente (Recomendado para Desenvolvimento)

1. No Xcode, selecione **Product → Scheme → Edit Scheme...**
2. Vá para **Run → Arguments → Environment Variables**
3. Adicione:
   - Name: `SPTRANS_TOKEN`
   - Value: `seu-token-aqui`

### Opção B: Scheme File (Para compartilhar com equipe)

Edite `WhereIsMyBus.xcodeproj/xcshareddata/xcschemes/WhereIsMyBus.xcscheme`:

```xml
<EnvironmentVariables>
   <EnvironmentVariable
      key = "SPTRANS_TOKEN"
      value = "seu-token-aqui"
      isEnabled = "YES">
   </EnvironmentVariable>
</EnvironmentVariables>
```

### Opção C: Keychain (Recomendado para Produção)

```swift
// Adicionar ao app inicialização
import Security

func getTokenFromKeychain() -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "SPTransToken",
        kSecReturnData as String: true
    ]
    
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    
    guard status == errSecSuccess,
          let data = result as? Data,
          let token = String(data: data, encoding: .utf8) else {
        return nil
    }
    
    return token
}
```

---

## 3. Migração Gradual do Código

### Fase 1: Usar novos modelos lado a lado

```swift
// Antes (código existente)
import Foundation

// Depois (com novos packages)
import WIMBCore
import NetworkClient

// Usar novos tipos gradualmente
let coordinate = Coordinate(latitude: lat, longitude: lon)
let vehicle = Vehicle(prefix: "74512", accessible: true, ...)
```

### Fase 2: Substituir APISPTrans por SPTransClient

```swift
// Antes
APISPTrans.fetchTrips(text: text, .trips)
    .sink(...)

// Depois
Task {
    let client = SPTransClient(configuration: .init(token: token))
    let lines = try await client.searchLines(query: text)
}
```

### Fase 3: UI estilo Uber (implementado)

```swift
TripListView()
    .environmentObject(trackingState)

// Mapa full-screen + bottom sheet
TransportHomeView(trackingState: trackingState) {
    TripHomePanel() // busca ↔ detalhe da linha
}
```

Fluxo:
1. Buscar linha → rastrear automaticamente
2. Bottom sheet abre detalhe com paradas e previsões
3. Mapa exibe ônibus + paradas da linha selecionada
4. **Rota em azul** conectando paradas retornadas pela API (`/Previsao/Linha`)
5. **Enquadramento** com padding inferior (~42%) para ônibus não ficarem atrás do sheet
6. Overlay superior: contagem de veículos + botão atualizar

### Mapa (iOS 16)

SwiftUI `Map` não suporta polilinha nativa no iOS 16. A rota usa `MKMapView` via `TransportMapRepresentable` com `MKPolylineRenderer` azul.

### Localização

| Idioma | Arquivo |
|--------|---------|
| Português (Brasil) | `Shared/Resources/pt-BR.lproj/Localizable.strings` |
| English | `Shared/Resources/en.lproj/Localizable.strings` |

Textos pensados para público amplo (classe B/C/D): linguagem simples, sem jargão técnico. Helper: `WIMBL10n.swift`.

> Após alterar código em `Packages/`, commitar em `Packages/` **e** atualizar `Package.resolved` (ou rodar **File → Packages → Reset Package Caches** no Xcode).

---

## 4. Deployment Target (iOS 16)

Todos os packages e o app usam **iOS 16.0**:

- `IPHONEOS_DEPLOYMENT_TARGET = 16.0` no `WhereIsMyBus.xcodeproj`
- `platforms: [.iOS(.v16)]` em cada `Package.swift`

No Xcode: **General → Minimum Deployments → iOS 16.0**

---

## 5. Build e Teste

### Compilar packages isoladamente

```bash
cd /Users/douglastaquary/Documents/Projects/Github/iOS/wimb/Packages/WIMBCore
swift build

cd /Users/douglastaquary/Documents/Projects/Github/iOS/wimb/Packages/NetworkClient
swift build
```

### Rodar testes

```bash
cd /Users/douglastaquary/Documents/Projects/Github/iOS/wimb/Packages/WIMBCore
swift test

cd /Users/douglastaquary/Documents/Projects/Github/iOS/wimb/Packages/NetworkClient
swift test
```

### Build do app completo

No Xcode: **Product → Build** (⌘B)

---

## 6. Checklist de Integração

- [x] Packages referenciados no `WhereIsMyBus.xcodeproj` (WIMBCore, NetworkClient, TransportEngine, DesignSystem, MapFeature)
- [x] `WIMBAppEnvironment` criado
- [x] `TripHomePanel` + `TripLineDetailPanel` (detalhe com paradas)
- [x] Mapa com paradas, overlay de status e foco automático
- [x] Rota azul (MKPolyline) e enquadramento acima do bottom sheet
- [x] Localização pt-BR + en (`Localizable.strings`, `WIMBL10n`)
- [x] README com screenshots em `docs/screenshots/`
- [x] Código legado removido (`APISPTrans`, `TripMapView`, ViewModels antigos)
- [x] Deployment target **iOS 16.0**
- [ ] Token configurado via Environment Variable (`SPTRANS_TOKEN`)
- [x] Package umbrella `Packages/Package.swift` (compatível Xcode 14)
- [x] Build validado: Xcode 14.2 + iOS Simulator 16.2
- [x] Fase 4: previsões smart, clima Open-Meteo, metrô próximo

---

## 8. Fase 4 — Inteligência (implementado)

### Previsões smart (`SmartArrivalPredictor`)

Combina três fontes:

1. **SPTrans** — quando `arrivalForecast` vem da API ("3 min", "Chegando")
2. **Movimento** — velocidade observada entre posições de polling
3. **Clima** — fator de velocidade reduzido em chuva (via Open-Meteo)

```swift
let prediction = trackingState.smartPrediction(for: vehicle, at: stop)
// prediction.source: .spTrans | .estimated | .hybrid
```

### Clima (`WeatherClient`)

- API: [Open-Meteo](https://open-meteo.com/) — **sem API key**
- Atualizado em `TrackingState.refreshContext()` com base na localização
- Chip no mapa (`WIMBWeatherChip`) + aviso de chuva no detalhe da linha

### Metrô próximo (`MetroNearbyService`)

- Catálogo estático das principais estações de SP
- Exibido no bottom sheet quando o usuário não está vendo detalhe de linha
- Distância a pé estimada (~80 m/min)

### Checklist Fase 4

- [x] `WeatherSnapshot`, `MetroStation`, `NearbyMetroStop` (WIMBCore)
- [x] `WeatherClient` (NetworkClient)
- [x] `SmartArrivalPredictor` + parser SPTrans (TransportEngine)
- [x] `TrackingState.weather` + `nearbyMetro` + `refreshContext()`
- [x] UI: chip de clima, seção metrô, ETA inteligente
- [x] Localização pt-BR + en
- [x] Testes unitários

---

## 10. Fase 6 — UX Moovit (implementado)

Refatoração concluída: **3 abas** (Direções · Estações · Linhas), planejador heurístico e live tracking.

```swift
MainShellView(
    navigationState: navigationState,
    strings: .localized,
    directionsTab: { DirectionsTabRootView() },
    stationsTab: { StationsTabRootView() },
    linesTab: { LinesTabRootView() }
)
.environmentObject(trackingState)
.environmentObject(stationsState)
.environmentObject(directionsState)
```

| Documento | Conteúdo |
|-----------|----------|
| [MOOVIT-EXECUTION-PLAN.md](MOOVIT-EXECUTION-PLAN.md) | Plano de PRs, APIs, checklist |
| [canvas/007-Moovit-UX-Refactoring.md](canvas/007-Moovit-UX-Refactoring.md) | Canvas REASONS completo |
| [docs/screenshots/moovit/](../docs/screenshots/moovit/README.md) | Referências visuais |

**Subfases concluídas:** 6.1 Shell → 6.2 Linhas → 6.3 Live UI → 6.4 Estações → 6.5 Planejador → 6.6 Polish

> UI legada (`TripListView`, `TransportHomeView`, `TripHomePanel`) removida na 6.6.

---

## 9. Troubleshooting

### Erro: "No such module 'WIMBCore'"

**Solução:** Certifique-se de que o package foi adicionado ao target correto.

### Erro: "The package 'NetworkClient' requires minimum iOS version 16.0"

**Solução:** Atualize o deployment target do projeto para iOS 16.0+.

### Erro: "Cannot find type 'TransportLine' in scope"

**Solução:** Adicione `import WIMBCore` no arquivo.

### Erro de autenticação SPTrans

**Solução:** Verifique se a variável de ambiente `SPTRANS_TOKEN` está configurada corretamente.
