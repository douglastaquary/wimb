# WIMB Packages (SPM)

Monorepo Swift Package Manager para os módulos do WIMB — **versionado junto com o app** (mesmo repositório, como [IceCubesApp](https://github.com/Dimillian/IceCubesApp)).

## Xcode 14 + iOS 16

O app referencia os packages locais em `Packages/` diretamente no Xcode (sem submodule ou repositório separado).

### Estrutura

```
Packages/
├── Package.swift          ← umbrella (usado pelo Xcode)
├── WIMBCore/
├── NetworkClient/
├── TransportEngine/
├── DesignSystem/
├── MapFeature/
└── AppShell/
```

### Build isolado (CLI)

```bash
cd Packages
swift build          # Swift 5.7+ (Xcode 14.2)
swift test
```

### Git

Alterações em `Packages/` entram no commit normal do projeto:

```bash
git add Packages/
git commit -m "feat: sua alteração no SPM"
git push
```
