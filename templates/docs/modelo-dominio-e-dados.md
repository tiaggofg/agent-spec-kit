# Modelo de Domínio e Dados

## 1. Diagrama de Classes / Agregados

```mermaid
classDiagram
  class EntityExample {
    +UUID id
    +String status
  }
```

## 2. Modelo de Persistência (ER / Coleções)

```mermaid
erDiagram
  USERS ||--o{ ITEMS : owns
```

## 3. Índices e Constraints

<!-- Liste índices únicos, compostos, TTL e constraints relevantes. -->

## 4. Máquina de Estados

```mermaid
stateDiagram-v2
  [*] --> DRAFT
  DRAFT --> ACTIVE
  ACTIVE --> [*]
```
