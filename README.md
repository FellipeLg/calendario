# Agenda Compartilhada para Grupos

Calendário mobile-first para grupos de amigos/colegas. Todos com o link podem editar a agenda, registrando disponibilidade e criando eventos com detecção de conflitos.

## Como usar

1. Acesse `/` — redireciona para o grupo padrão
2. Compartilhe o link `g/<token>` com o grupo
3. Adicione pessoas ao grupo
4. Registre disponibilidades (dia todo ou horário específico)
5. Crie eventos selecionando participantes
6. O sistema detecta conflitos automaticamente

## Stack

- **Ruby on Rails 8.1** — backend e views
- **SQLite** — banco de dados
- **FullCalendar 6** — componente de calendário
- **Propshaft** — asset pipeline

## Estrutura

```
app/
├── models/       # Group, Person, Availability, Event, EventParticipant
├── controllers/  # Groups, People, Availabilities, Events
├── views/        # Templates ERB com layout mobile-first
└── assets/       # CSS com tema escuro responsivo
test/
├── models/       # 58 testes de modelo
├── controllers/  # 29 testes de controller
└── integration/  # 7 testes de integração
```

## Testes

```bash
bin/rails test
```

94 testes cobrindo models, controllers e fluxos de integração.

## Desenvolvimento

```bash
bin/dev
```

## Modelo de dados

- **Group** — grupo com share_token único
- **Person** — pessoa do grupo com nome, contato e cor
- **Availability** — disponibilidade (disponivel, trabalhando, ocupado, indisponivel, compromisso)
- **Event** — evento com participantes e detecção de conflitos
- **EventParticipant** — join table eventos ↔ pessoas
