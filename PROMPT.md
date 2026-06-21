# Prompt: Agenda Compartilhada para Grupos

## Conceito

Criar um site de calendário mobile-first para grupos de amigos/colegas onde todos com o link possam editar a agenda. O foco é organizar horários e dias que todos podem sair juntos, registrando disponibilidade e criando eventos com detecção de conflitos.

## Contexto do Projeto

Projeto Rails 8.1 já inicializado com estrutura completa:

### O que já existe

**Models (app/models/):**
- `Group` — grupos com share_token único para acesso via link
- `Person` — pessoas do grupo com nome, contato e cor
- `Availability` — disponibilidades (disponivel, trabalhando, ocupado, indisponivel, compromisso)
- `Event` — eventos com participantes e detecção de conflitos
- `EventParticipant` — join table eventos ↔ pessoas

**Controllers (app/controllers/):**
- `GroupsController` — home + show com feed de dados
- `PeopleController` — CRUD de pessoas
- `AvailabilitiesController` — CRUD de disponibilidades
- `EventsController` — CRUD de eventos + endpoint JSON para FullCalendar

**Views (app/views/):**
- `groups/show.html.erb` — dashboard com calendário FullCalendar + sidebars
- Formulários para pessoas, disponibilidades e eventos
- Layout com flash messages e meta tags mobile

**Rotas (config/routes.rb):**
- `GET /` → redireciona para grupo padrão
- `GET /g/:share_token` → dashboard do grupo
- `GET /g/:share_token/feed` → JSON para FullCalendar
- CRUD nesting: `/g/:share_token/people`, `/g/:share_token/availabilities`, `/g/:share_token/events`

**Banco de dados:**
- 5 migrations criadas (groups, people, availabilities, events, event_participants)
- SQLite configurado

**Testes (test/):**
- Arquivos criados mas vazios (apenas stubs)
- Capybara + Selenium configurados no Gemfile

### O que falta

1. **CSS completo** — `application.css` está vazio, precisa de toda a estilização
2. **Testes** — todos os arquivos de teste estão com stubs comentados
3. **Helpers** — `AvailabilitiesHelper` e `EventsHelper` vazios
4. **PWA** — manifest e service worker desabilitados
5. **Responsividade** — precisa de breakpoints mobile

## Requisitos

### UI/UX

1. **Mobile-first** — design responsivo que funciona bem em telas pequenas
2. **Visual consistente** — paleta de cores definida, tipografia clara
3. **Navegação intuitiva** — acesso rápido para criar pessoa, disponibilidade e evento
4. **Feedback visual** — status com cores distintas (verde=disponivel, vermelho=indisponivel, etc.)
5. **Calendário interativo** — FullCalendar funcional com navegação mês/semana/dia
6. **Formulários acessíveis** — labels, validação client-side, mensagens de erro claras
7. **Flash messages** — notificações de sucesso/erro estilizadas
8. **Compartilhamento fácil** — campo de URL do grupo com botão de copiar

### Engenharia de Software

1. **Código limpo** — seguir convenções Rails, Rubocop configurado
2. **Validações robustas** — models com validações completas
3. **Escopos** — queries otimizadas com scopes
4. **N+1 queries** — usar includes/preload onde necessário
5. **Concerns** — extrair lógica compartilhada quando necessário
6. **Helper methods** — helpers para formatação e lógica de visualização
7. **Error handling** — tratamento adequado de exceções
8. **Segurança** — share_token como única autenticação, sem login

### Testes

1. **Model tests** — validações, associações, callbacks, scopes
2. **Controller tests** — actions, params, responses, redirects
3. **Integration tests** — fluxos completos de uso
4. **System tests** — cenários E2E com Capybara (preenchimento de formulários, navegação)

## Fluxo Principal

1. Usuário acessa `/` → redireciona para grupo padrão
2. Dashboard mostra calendário + sidebar com pessoas, eventos e disponibilidades
3. Usuário adiciona pessoas ao grupo
4. Pessoas registram disponibilidades (dia/todo ou horário específico)
5. Usuário cria evento selecionando participantes
6. Sistema detecta conflitos e avisa
7. Usuário decide se salva mesmo com conflito
8. Link do grupo pode ser compartilhado para edição por todos

## Diretrizes de Implementação

- Priorizar simplicidade e clareza
- Não adicionar features extras além do escopo
- Manter o código idiomático Rails
- Testar cada funcionalidade antes de avançar
- Documentar decisões de design no README
