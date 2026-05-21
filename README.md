# Where Is My Bus (WIMB)

App iOS para acompanhar ônibus em tempo real em São Paulo, usando a API Olho Vivo da SPTrans.

## Capturas de tela

| Tela inicial | Linha selecionada |
|--------------|-------------------|
| ![Tela inicial](docs/screenshots/home-search.png) | ![Detalhe da linha](docs/screenshots/line-detail.png) |

O mapa centraliza ônibus e rota **acima do bottom sheet**, desenha a linha em azul e exibe paradas com previsões.

## Requisitos

| Ferramenta | Versão |
|------------|--------|
| Xcode | 14.2+ |
| Swift | 5.7+ |
| iOS | 16.0+ |

## Configuração

1. Clone o repositório e abra `WhereIsMyBus.xcodeproj`.
2. Configure o token da SPTrans em **Product → Scheme → Edit Scheme → Run → Environment Variables**:
   - `SPTRANS_TOKEN` = seu token Olho Vivo
3. Build e run no simulador ou dispositivo.

Os packages SPM ficam em `Packages/` (monorepo umbrella). Veja [Packages/README.md](Packages/README.md) e [.spdd/INTEGRATION-GUIDE.md](.spdd/INTEGRATION-GUIDE.md).

## Idiomas

O app segue o idioma do sistema:

- **Português (Brasil)** — textos diretos e acolhedores para uso no dia a dia
- **English** — mesma experiência em inglês

Arquivos em `Shared/Resources/en.lproj` e `Shared/Resources/pt-BR.lproj`.

## Arquitetura (Fase 3)

```
TripListView
 └── TransportHomeView (MapFeature)
      ├── TransportMapView — MKMapView + rota azul + foco acima do sheet
      ├── MapStatusOverlay — status e atualizar
      └── WIMBBottomSheet
           └── TripHomePanel — busca ↔ detalhe da linha
```

| Package | Função |
|---------|--------|
| WIMBCore | Modelos (`Vehicle`, `Stop`, `TransportLine`) |
| NetworkClient | HTTP + SPTransClient |
| TransportEngine | Polling, `TrackingState` |
| DesignSystem | Cores, tipografia, bottom sheet |
| MapFeature | Mapa, rota, animação de veículos |

## Funcionalidades

- Busca de linhas por número ou nome
- Rastreamento em tempo real com polling
- Mapa com ônibus animados, paradas e **rota desenhada em azul**
- Enquadramento automático considerando o bottom sheet (~42% da tela)
- Bottom sheet estilo Uber com previsões por parada

## Licença

Projeto pessoal — consulte o autor para uso.
