# Plano de Execução — Refatoração Moovit (Fase 6)

**Projeto:** WhereIsMyBus (WIMB)  
**Metodologia:** [SPDD](https://martinfowler.com/articles/structured-prompt-driven/)  
**Canvas:** [007-Moovit-UX-Refactoring.md](canvas/007-Moovit-UX-Refactoring.md)  
**Referência:** [TechTudo — Moovit rastreamento](https://www.techtudo.com.br/dicas-e-tutoriais/2022/12/moovit-como-usar-rastreamento-e-descobrir-onde-seu-onibus-esta-agora.ghtml)

---

## 1. Visão geral

### O que muda

| Antes (Fase 3–5) | Depois (Fase 6) |
|------------------|-----------------|
| Uma tela: mapa + bottom sheet | **3 abas**: Direções, Estações, Linhas |
| Busca só por linha | Busca por **destino** + planejador |
| Rota azul no mapa | Rota **amarela** no live tracking |
| Detalhe inline no sheet | **Navegação em pilha** por fluxo |
| Foco Uber | Foco **Moovit / transporte público SP** |

### O que permanece

- Packages SPM (`WIMBCore`, `NetworkClient`, `TransportEngine`, `DesignSystem`, `MapFeature`)
- `TrackingState`, polling, `SmartArrivalPredictor`, clima, metrô
- iOS 16, Xcode 14.2, localização pt-BR/en

---

## 2. Funcionalidades × telas × APIs

### F1 — Direções (home + busca)

**Referência:** imagem 1

| UI | Componente | API / serviço |
|----|------------|---------------|
| “Para onde você quer ir?” | `DirectionsHomeView` | — |
| Barra busca + botão laranja | `WIMBDestinationSearchBar` | `MKLocalSearch` |
| Visualizado recentemente | `RecentTripsCarousel` | UserDefaults / SwiftData |
| Favoritos (Casa…) | `FavoritesSection` | `AppNavigationState` |
| Metrô perto (SP extra) | `MetroAlternativesSection` | `MetroNearbyService` ✅ |

**Ação usuário:** digitar destino → abre Planejador (F1b).

---

### F1b / F2 — Planejador + rotas sugeridas + detalhe

**Referência:** imagens 2 e 3

| UI | Componente | API / serviço |
|----|------------|---------------|
| Origem / destino + swap | `TripPlannerView` | `PlaceSearchService` |
| “Sair agora” / ±15 min | `DepartureTimePicker` | local (MVP) |
| Lista “Rotas sugeridas” | `SuggestedRoutesView` | `RouteSuggestionEngine` |
| Card: duração, tarifa, linha | `WIMBRouteSuggestionCard` | SPTrans + Bilhete Único |
| Detalhe passo a passo | `RouteDirectionsView` | paradas `/Previsao/Linha` |
| Botão **Localização em tempo real** | navega → F3 | `TransportEngine.startTracking` |

**Heurística MVP (`RouteSuggestionEngine`):**

1. Geocodificar origem e destino  
2. Para cada linha candidata (busca por termo ou cache):  
   - Obter paradas (`fetchArrivals`)  
   - Calcular distância origem→parada embarque e parada→destino  
   - Score = tempo caminhada + ETA ônibus (`SmartArrivalPredictor`)  
3. Retornar top 5 rotas ordenadas por score  

---

### F3 — Localização em tempo real (linha)

**Referência:** imagens 4, 5, 6

| UI | Componente | API / serviço |
|----|------------|---------------|
| Mapa full-screen | `LiveLineTrackingView` | `TransportMapRepresentable` |
| Rota amarela + setas | `RoutePolylineWithArrows` | paradas linha |
| Ícones ônibus (múltiplos) | animação existente | `/Posicao/Linha` |
| Header flutuante | `LiveTrackingHeader` | — |
| Card inferior | `WIMBLiveTrackingCard` | ETA + paradas distância |
| Timer refresh | `PollingCountdownView` | `TransportEngine` polling |

**Cálculo “N paradas de distância”:**

- Ordenar paradas da linha  
- Encontrar parada mais próxima do veículo selecionado  
- Contar paradas até parada de referência (origem do usuário ou parada escolhida)

---

### F4 — Estações

**Referência:** imagens 7, 8, 9, 10

| UI | Componente | API / serviço |
|----|------------|---------------|
| Mapa + pins parada | `StationsMapView` | **NOVO** `/Parada/Buscar` |
| Busca endereço topo | `WIMBPlaceSearchField` | `MKLocalSearch` |
| “Ver estações ao redor” | botão | GPS + busca paradas |
| Detalhe parada | `StopArrivalsView` | `/Previsao/Parada` ✅ |
| Lista linhas + ETA verde | `StopLineArrivalRow` | forecast por veículo |
| **Localização em tempo real** | → `LiveStopTrackingView` | F3 contextualizado |

**Endpoint a implementar:**

```
GET /Parada/Buscar?termosBusca={texto}
```

---

### F5 — Linhas

**Referência:** imagens 11, 12

| UI | Componente | API / serviço |
|----|------------|---------------|
| Busca “Pesquise uma linha” | `LinesHomeView` | `/Linha/Buscar` ✅ |
| Filtro Ônibus / Recentes | chips + lista | local |
| Detalhe linha + mapa | `LineRouteView` | `/Previsao/Linha` + `/Posicao/Linha` |
| Timeline paradas | `LineTimelineView` | arrivals |
| Trocar sentido | toggle | `TransportLine` direction |
| **Localização em tempo real** | → F3 | tracking |

---

## 3. Cronograma de PRs (recomendado)

```
main
 ├── feat/6.1-moovit-shell          ← Tab bar + tokens + placeholders
 ├── feat/6.2-lines-tab             ← F5 (mais rápido, reusa código)
 ├── feat/6.3-live-tracking-ui      ← F3 (impacto visual alto)
 ├── feat/6.4-stations-tab          ← F4 + API paradas
 ├── feat/6.5-trip-planner          ← F1 + F2 (maior complexidade)
 └── feat/6.6-polish-docs           ← README, screenshots, cleanup legado
```

Cada PR deve:

1. Atualizar canvas/checklist em `.spdd/`  
2. Adicionar screenshots em `docs/screenshots/moovit/`  
3. Commit em `Packages/` + `Package.resolved` se SPM mudou  
4. Build iOS 16.2 validado  

---

## 4. Checklist de documentação por etapa

| Etapa | Arquivos a atualizar |
|-------|---------------------|
| 6.1 | `007-Moovit-UX-Refactoring.md`, `001` overview, `INTEGRATION-GUIDE.md` §6 |
| 6.2 | `README.md` (aba Linhas), screenshot 11–12 |
| 6.3 | `MapFeature` canvas (criar `005`), screenshots 4–6 |
| 6.4 | `003-NetworkClient` (endpoint paradas), screenshots 7–10 |
| 6.5 | `TripPlannerFeature` canvas (criar `008`), screenshots 1–3 |
| 6.6 | `README.md` completo, `current-codebase-analysis.md` |

---

## 5. Strings de localização (amostra)

| Key | pt-BR | en |
|-----|-------|-----|
| `tab.directions` | Direções | Directions |
| `tab.stations` | Estações | Stations |
| `tab.lines` | Linhas | Lines |
| `directions.prompt` | Para onde você quer ir? | Where do you want to go? |
| `planner.title` | Rotas sugeridas | Suggested routes |
| `liveTracking.button` | Localização em tempo real | Real-time location |
| `liveTracking.stopsAway` | %d paradas de distância | %d stops away |
| `lines.search` | Pesquise uma linha | Search for a line |
| `stations.nearby` | Ver estações ao redor | View nearby stations |

---

## 6. Sugestões SP — prioridade de produto

Com base no uso real em São Paulo e no artigo TechTudo:

| Prioridade | Feature | Motivo |
|------------|---------|--------|
| P0 | Live tracking no mapa (F3) | Principal motivo de download |
| P0 | Consulta por parada (F4) | Usuário no ponto quer “quem chega aqui” |
| P1 | Busca por linha (F5) | Quem já sabe o número (8000, 875T…) |
| P1 | Sentido / terminal | Erro comum em SP |
| P2 | Planejador A→B (F1–F2) | SPTrans limitado; MVP heurístico |
| P2 | Favoritos Casa/Trabalho | Retenção diária |
| P3 | Tarifa Bilhete Único no card | Transparência custo |

---

## 7. Primeira tarefa de implementação (6.1)

Arquivos mínimos para o primeiro PR:

```
Packages/DesignSystem/.../WIMBShellColors.swift
Packages/DesignSystem/.../WIMBMainTabBar.swift
Packages/AppShell/.../MainShellView.swift
Packages/AppShell/.../AppNavigationState.swift
Shared/WhereIsMyBusApp.swift          → MainShellView()
Shared/Localization/                  → tab.* strings
docs/screenshots/moovit/01-tab-shell.png
```

**Critério de done 6.1:** app abre em Direções, tab bar funcional, 3 placeholders navegáveis.

---

## 8. Assets de referência

Screenshots Moovit fornecidos (ordem do prompt):

| Arquivo | Fluxo |
|---------|-------|
| `assets/Captura...23.27.09.png` | F1 home Direções |
| `assets/Captura...23.27.32.png` | F2 planejador |
| `assets/Captura...23.31.17.png` | F2 detalhe direções |
| `assets/Captura...23.33.35.png` | F3 live (1 ônibus) |
| `assets/Captura...23.34.42.png` | F3 multi-ônibus |
| `assets/Captura...23.35.07.png` | F3 countdown |
| `assets/Captura...23.36.15.png` | F4 mapa estações |
| `assets/Captura...23.36.49.png` | F4 detalhe parada |
| `assets/Captura...23.38.37.png` | F4→F3 live parada |
| `assets/Captura...23.38.50.png` | F4→F3 variant |
| `assets/Captura...23.40.20.png` | F5 lista linhas |
| `assets/Captura...23.40.33.png` | F5 detalhe linha |

Copiar para `docs/screenshots/moovit/reference/` como guia visual durante implementação.
