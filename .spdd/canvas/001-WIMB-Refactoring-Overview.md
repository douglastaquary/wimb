# WIMB 2.0 - Structured Prompt-Driven Development

## Visão Geral do Projeto

**Data de Criação:** 2026-05-21  
**Versão:** 1.0  
**Autor:** AI Assistant + Douglas Taquary

---

## Contexto do Projeto

O **WhereIsMyBus (WIMB)** é um aplicativo iOS para rastreamento de ônibus em tempo real na cidade de São Paulo, utilizando a API pública da SPTrans (OlhoVivo). A refatoração evolui o app para uma experiência **estilo Moovit** (3 abas: Direções, Estações, Linhas), com:

- Arquitetura modular usando Swift Package Manager (SPM)
- Navegação por abas + planejador de viagens
- Localização em tempo real no mapa (rota amarela, múltiplos ônibus)
- Engine inteligente com previsões + clima + metrô

---

## Referências de Arquitetura

### IceCubesApp Pattern
- **Fonte:** [Thomas Ricouard - SwiftUI in 2025](https://dimillian.medium.com/swiftui-in-2025-forget-mvvm-262ff2bbd2ed)
- **Repo:** [IceCubesApp](https://github.com/Dimillian/IceCubesApp)
- **Padrão:** Environment-Driven Architecture com `@Observable`

### SPDD Methodology
- **Fonte:** [Martin Fowler - Structured-Prompt-Driven Development](https://martinfowler.com/articles/structured-prompt-driven/)
- **Princípio:** Prompts como artefatos de primeira classe, versionados e revisáveis

---

## Fases de Implementação

| Fase | Nome | Status | Descrição |
|------|------|--------|-----------|
| 1 | Fundação | ✅ Completo | WIMBCore + NetworkClient packages |
| 2 | Engine | ✅ Implementado | TransportEngine + Storage |
| 3 | UI/UX | ✅ Completo | MapFeature + DesignSystem + localização |
| 4 | Inteligência | ✅ Implementado | Previsões smart + clima + metrô próximo |
| 5 | Polish | ⏳ Parcial | Acessibilidade, animações finais |
| 6 | UX Moovit | 📋 Planejado | 3 abas, planejador, live tracking, estações, linhas |

> **Plano detalhado:** [.spdd/MOOVIT-EXECUTION-PLAN.md](../MOOVIT-EXECUTION-PLAN.md) · **Canvas:** [007-Moovit-UX-Refactoring.md](007-Moovit-UX-Refactoring.md)

---

## Estrutura de Documentação SPDD

```
.spdd/
├── canvas/
│   ├── 001-WIMB-Refactoring-Overview.md      # Este arquivo
│   ├── 002-WIMBCore-Package.md               # ✅ REASONS Canvas - Core
│   ├── 003-NetworkClient-Package.md          # ✅ REASONS Canvas - Network
│   ├── 004-TransportEngine-Package.md        # ✅ REASONS Canvas - Engine
│   ├── 005-MapFeature-Package.md             # ⏳ REASONS Canvas - Map
│   ├── 006-DesignSystem-Package.md           # ⏳ REASONS Canvas - UI
│   └── 007-Moovit-UX-Refactoring.md          # 📋 Fase 6 — UX Moovit
├── MOOVIT-EXECUTION-PLAN.md                  # 📋 Plano de execução Fase 6
├── analysis/
│   └── current-codebase-analysis.md          # ✅ Análise do código atual
├── prompts/
│   └── generation-prompts.md                 # ✅ Prompts reutilizáveis
└── INTEGRATION-GUIDE.md                      # ✅ Guia de integração Xcode
```

---

## API SPTrans - Endpoints Utilizados

| Endpoint | Método | Descrição |
|----------|--------|-----------|
| `/Login/Autenticar` | POST | Autenticação com token |
| `/Linha/Buscar` | GET | Buscar linhas por termo |
| `/Previsao/Linha` | GET | Previsão de chegada por linha |
| `/Posicao` | GET | Posição de todos os veículos |
| `/Posicao/Linha` | GET | Posição dos veículos de uma linha |
| `/Previsao/Parada` | GET | Previsão de chegada em uma parada |

**Base URL:** `http://api.olhovivo.sptrans.com.br/v2.1`

---

## Decisões Arquiteturais (ADRs)

### ADR-001: ObservableObject para compatibilidade iOS 16
- **Contexto:** Deployment target definido como iOS 16; `@Observable` requer iOS 17+
- **Decisão:** Usar `ObservableObject` + `@Published` em `TrackingState` e `LocationManager`
- **Consequência:** Compatível com iOS 16; migração para `@Observable` pode ocorrer quando o mínimo subir para iOS 17

### ADR-002: Actors para estado compartilhado
- **Contexto:** Rastreamento de múltiplos veículos é concorrente
- **Decisão:** Usar `actor` para `TransportEngine` e `VehicleTracker`
- **Consequência:** Thread-safety garantida pelo compilador

### ADR-003: async/await over Combine
- **Contexto:** Código atual mistura Combine e async/await
- **Decisão:** Padronizar em async/await para novos códigos
- **Consequência:** Código mais legível, melhor integração com SwiftUI

### ADR-004: SwiftUI Map nativo (iOS 16)
- **Contexto:** Código atual usa UIKit MapViewController
- **Decisão:** Usar SwiftUI `Map` + `MapAnnotation` (API iOS 16)
- **Consequência:** Código declarativo; `MapContentBuilder` fica reservado para quando o mínimo for iOS 17+

---

## Próximos Passos

1. ✅ Fases 1–4 concluídas (SPM, engine, UI Uber, inteligência)
2. 📋 **Fase 6 — Refatoração Moovit** (ver [MOOVIT-EXECUTION-PLAN.md](../MOOVIT-EXECUTION-PLAN.md))
3. ⏳ Subfase 6.1: Shell + tab bar + design tokens
4. ⏳ Subfases 6.2–6.6: Linhas → Live → Estações → Planejador → Docs
