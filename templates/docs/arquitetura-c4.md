# Arquitetura e Diagramas C4

## 1. Diagrama de Contexto (C1)

```mermaid
flowchart LR
  User["Usuário"] --> App["Sistema (<!-- Nome do Projeto -->)"]
  App --> Ext["Serviço Externo (opcional)"]
```

## 2. Diagrama de Containers (C2)

```mermaid
flowchart TB
  Client["Frontend / Cliente"] -->|HTTPS / REST| Api["Backend API"]
  Api --> Db[("Banco de Dados")]
```

## 3. Componentes e Camadas (C3)

<!-- Descreva os módulos/camadas e suas fronteiras de dependência. -->
