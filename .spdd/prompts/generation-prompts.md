# Prompts Reutilizáveis - WIMB SPDD

**Data:** 2026-05-21  
**Uso:** Copiar e adaptar para gerar código consistente

---

## 1. Prompt: Criar Package SPM

```markdown
Crie um Swift Package com as seguintes especificações:

**Nome:** [PACKAGE_NAME]
**Plataformas:** iOS 17+, macOS 14+
**Swift Version:** 6.0

**Estrutura:**
- Sources/[PACKAGE_NAME]/
- Tests/[PACKAGE_NAME]Tests/

**Dependências:**
- [LISTA DE DEPENDÊNCIAS]

**Requisitos:**
- Usar .swiftLanguageMode(.v6)
- Todos os tipos devem ser Sendable
- Documentação DocC para tipos públicos

Gere o Package.swift e a estrutura de diretórios.
```

---

## 2. Prompt: Criar Modelo de Domínio

```markdown
Crie um modelo Swift seguindo estas especificações:

**Nome:** [MODEL_NAME]
**Propósito:** [DESCRIÇÃO]

**Propriedades:**
- [LISTA DE PROPRIEDADES COM TIPOS]

**Mapeamento API (se aplicável):**
- Campo API `[api_field]` → Propriedade `[swiftProperty]`

**Conformances necessárias:**
- Sendable
- Identifiable
- Hashable
- Codable (com CodingKeys customizados se necessário)

**Computed Properties:**
- [LISTA DE COMPUTED PROPERTIES]

**Requisitos:**
- Usar struct (value type)
- Documentação DocC
- Sem force unwrap
- Valores default para optionals quando fizer sentido

Gere o código completo do modelo.
```

---

## 3. Prompt: Criar Protocolo de Serviço

```markdown
Crie um protocolo Swift para abstração de serviço:

**Nome:** [PROTOCOL_NAME]
**Propósito:** [DESCRIÇÃO]

**Métodos:**
- [ASSINATURA DO MÉTODO 1]
- [ASSINATURA DO MÉTODO 2]
- ...

**Requisitos:**
- Sendable
- Todos os métodos async throws
- Tipos de retorno bem definidos
- Documentação DocC

Gere o protocolo e um exemplo de implementação mock para testes.
```

---

## 4. Prompt: Criar Actor para Estado Compartilhado

```markdown
Crie um actor Swift para gerenciamento de estado:

**Nome:** [ACTOR_NAME]
**Propósito:** [DESCRIÇÃO]

**Estado interno:**
- [PROPRIEDADES PRIVADAS]

**Interface pública:**
- [MÉTODOS PÚBLICOS]

**Dependências:**
- [PROTOCOLOS QUE DEVE RECEBER VIA INIT]

**Requisitos:**
- Usar actor para thread-safety
- Injeção de dependências no init
- Métodos async para operações I/O
- Não expor estado mutável diretamente

Gere o código completo do actor.
```

---

## 5. Prompt: Criar View SwiftUI

```markdown
Crie uma View SwiftUI seguindo estas especificações:

**Nome:** [VIEW_NAME]
**Propósito:** [DESCRIÇÃO]

**Estado:**
- [PROPRIEDADES @State, @Binding, etc.]

**Layout:**
- [DESCRIÇÃO DO LAYOUT]

**Componentes filhos:**
- [LISTA DE SUBVIEWS]

**Requisitos:**
- Usar componentes nativos iOS (SF Symbols, cores do sistema)
- Suportar Dynamic Type
- Acessibilidade básica
- Preview com múltiplos estados
- Sem bibliotecas de terceiros

Gere o código completo da View.
```

---

## 6. Prompt: Criar Testes Unitários

```markdown
Crie testes unitários para:

**Alvo:** [NOME DO TIPO/FUNÇÃO]
**Arquivo de teste:** [NOME]Tests.swift

**Cenários a testar:**
1. [CENÁRIO 1 - caso de sucesso]
2. [CENÁRIO 2 - caso de erro]
3. [CENÁRIO 3 - edge case]
...

**Requisitos:**
- Usar XCTest
- Mocks para dependências externas
- Naming: test_[unidade]_[cenário]_[esperado]
- Arrange-Act-Assert pattern
- Testes async quando necessário

Gere o código completo dos testes.
```

---

## 7. Prompt: Migrar Código Existente

```markdown
Migre o seguinte código para a nova arquitetura:

**Código original:**
```swift
[COLE O CÓDIGO AQUI]
```

**De:** [LOCALIZAÇÃO ATUAL]
**Para:** [PACKAGE/MÓDULO DESTINO]

**Mudanças necessárias:**
- Remover dependência de [X]
- Adicionar conformance com [PROTOCOLO]
- Usar async/await ao invés de Combine
- [OUTRAS MUDANÇAS]

**Requisitos:**
- Preservar lógica de negócio
- Melhorar tratamento de erros
- Adicionar documentação
- Tornar testável

Gere o código migrado.
```

---

## 8. Prompt: Refatorar para Testabilidade

```markdown
Refatore o seguinte código para torná-lo testável:

**Código original:**
```swift
[COLE O CÓDIGO AQUI]
```

**Problemas atuais:**
- [PROBLEMA 1: ex. dependência hardcoded]
- [PROBLEMA 2: ex. singleton]
- [PROBLEMA 3: ex. acesso direto a sistema]

**Requisitos:**
- Extrair protocolo para dependências
- Usar injeção de dependências
- Remover singletons
- Separar side effects de lógica pura

Gere:
1. Código refatorado
2. Protocolo(s) extraído(s)
3. Exemplo de mock
4. Exemplo de teste
```

---

## 9. Prompt: Criar Endpoint Type-Safe

```markdown
Crie um endpoint type-safe para API:

**Endpoint:** [NOME]
**URL:** [BASE_URL][PATH]
**Método:** [GET/POST/etc]

**Parâmetros:**
- Query: [LISTA]
- Body: [ESTRUTURA SE POST]

**Resposta esperada:**
```json
[EXEMPLO DE JSON]
```

**Requisitos:**
- Enum case com associated values
- Computed properties para path, method, queryItems
- Método para construir URLRequest
- DTO para resposta

Gere o código do endpoint e DTO de resposta.
```

---

## 10. Prompt: Documentação DocC

```markdown
Adicione documentação DocC completa para:

**Tipo:** [NOME DO TIPO]
**Arquivo:** [PATH]

**Seções necessárias:**
- Overview (descrição geral)
- Topics (agrupamento de membros)
- Usage example (código de exemplo)

**Requisitos:**
- Todos os membros públicos documentados
- Parâmetros de métodos documentados
- Throws documentado quando aplicável
- Returns documentado

Gere a documentação inline completa.
```

---

## Exemplos de Uso

### Exemplo 1: Criar modelo Vehicle

```
Crie um modelo Swift seguindo estas especificações:

**Nome:** Vehicle
**Propósito:** Representa um ônibus em operação na rede SPTrans

**Propriedades:**
- id: UUID (gerado automaticamente)
- prefix: String (identificador do veículo)
- coordinate: Coordinate (posição atual)
- previousCoordinate: Coordinate? (posição anterior para animação)
- accessible: Bool (acessibilidade)
- lastUpdateTime: String (horário da última atualização)
- arrivalForecast: String? (previsão de chegada)

**Mapeamento API:**
- Campo API `p` → Propriedade `prefix`
- Campo API `a` → Propriedade `accessible`
- Campo API `ta` → Propriedade `lastUpdateTime`
- Campo API `py` → Propriedade `coordinate.latitude`
- Campo API `px` → Propriedade `coordinate.longitude`
- Campo API `t` → Propriedade `arrivalForecast`

**Conformances necessárias:**
- Sendable, Identifiable, Hashable, Codable

**Computed Properties:**
- heading: Double (ângulo de direção baseado em coordinate vs previousCoordinate)
- hasMoved: Bool (se mudou de posição)

Gere o código completo do modelo.
```

### Exemplo 2: Criar SPTransClient

```
Crie um actor Swift para gerenciamento de estado:

**Nome:** SPTransClient
**Propósito:** Cliente para comunicação com a API SPTrans OlhoVivo

**Estado interno:**
- isAuthenticated: Bool
- configuration: SPTransConfiguration

**Interface pública:**
- authenticate() async throws -> Bool
- searchLines(query: String) async throws -> [TransportLine]
- fetchVehiclePositions(lineId: Int) async throws -> [Vehicle]
- fetchArrivals(lineId: Int) async throws -> [Stop]

**Dependências:**
- HTTPClient (protocolo para abstração de URLSession)
- SPTransConfiguration (struct com baseURL e token)

Gere o código completo do actor com auto-auth.
```

---

## Checklist Pré-Geração

Antes de usar qualquer prompt, verifique:

- [ ] O tipo já existe no codebase?
- [ ] Há código similar que pode ser reutilizado?
- [ ] As dependências necessárias estão especificadas?
- [ ] Os requisitos de Sendable foram considerados?
- [ ] O naming segue as convenções do projeto?
