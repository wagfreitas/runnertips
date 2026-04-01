# Runner Tips v2 - Arquitetura com RAG & Agentes IA

## Visao Geral

O Runner Tips evolui de um app de busca de corridas para uma **plataforma de inteligencia coletiva** para corredores e trilheiros, alimentada por RAG (Retrieval Augmented Generation) e agentes de IA especializados.

---

## 1. Stack Tecnologico

```
+------------------------------------------------------------------+
|                        FLUTTER APP                                |
|  (Auth, UI, Maps, Chat com Agentes, Perfil, Comunidade)          |
+------------------------------------------------------------------+
         |                    |                    |
         v                    v                    v
+----------------+  +------------------+  +------------------+
|  FIREBASE      |  |  SUPABASE        |  |  CLOUD FUNCTIONS |
|  - Auth        |  |  - pgvector      |  |  - RAG Pipeline  |
|  - Firestore   |  |  - Embeddings    |  |  - Agentes IA    |
|  - Storage     |  |  - Hybrid Search |  |  - Moderacao     |
|  - Crashlytics |  |  - Geo queries   |  |  - Webhooks n8n  |
+----------------+  +------------------+  +------------------+
                           |                       |
                           v                       v
                    +------------------+  +------------------+
                    |  VERTEX AI /     |  |  CLAUDE API /    |
                    |  OpenAI          |  |  Gemini          |
                    |  (Embeddings)    |  |  (Generation)    |
                    +------------------+  +------------------+
```

### Por que dois bancos?

| Camada | Firebase (Firestore) | Supabase (pgvector) |
|--------|---------------------|---------------------|
| **Uso** | Dados transacionais | Base de conhecimento |
| **Conteudo** | Usuarios, corridas, tips (CRUD), sessoes | Embeddings, chunks de conhecimento, busca semantica |
| **Vantagem** | Realtime, auth nativo, regras de seguranca | SQL + vector search + full-text search hibrido |
| **Custo** | Free tier generoso | Free tier, ~$25/mo pro |

---

## 2. Modelo de Dados Expandido

### 2.1 Firestore (dados transacionais)

```
users/
  {userId}/
    - name, email, avatar, experienceLevel
    - stats: { totalRaces, totalDistance, prs }
    - favorites: [raceId1, raceId2]
    - badges: [badge1, badge2]

races/
  {raceId}/
    - name, location, date, distance, type
    - description, website, imageUrl
    - gpxUrl          # Firebase Storage ref
    - elevationGain, elevationLoss
    - routeCoordinates: [GeoPoint]  # resumo do trajeto
    - status: upcoming | past | cancelled
    - stats: { totalTips, avgRating, totalParticipants }

tips/
  {tipId}/
    - raceId, userId, type, category
    - title, content, images[], tags[]
    - rating, likes, views, helpfulness
    - status: pending | approved | rejected
    - isVerified: bool
    - embeddingStatus: not_embedded | embedded | failed
    - vectorId: string  # ref no Supabase
    - createdAt, updatedAt

reviews/
  {reviewId}/
    - raceId, userId
    - ratings: { overall, route, organization, support, scenery }
    - content, images[]
    - status: pending | approved

moderation_queue/
  {itemId}/
    - type: tip | review | post
    - refId, userId
    - autoScore: float
    - status: pending | approved | rejected
    - reviewedBy, reviewedAt
```

### 2.2 Supabase (base de conhecimento vetorial)

```sql
-- Tabela principal de chunks de conhecimento
CREATE TABLE knowledge_chunks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_type TEXT NOT NULL,        -- 'tip', 'race_info', 'curated', 'scraped'
  source_id TEXT NOT NULL,          -- ref ao Firestore doc
  race_id TEXT,                     -- filtro por corrida
  category TEXT NOT NULL,           -- 'altimetry', 'route', 'hotel', 'food',
                                    -- 'tourism', 'safety', 'shopping',
                                    -- 'travel_package', 'race_kit', 'general'
  title TEXT,
  content TEXT NOT NULL,
  metadata JSONB,                   -- dados extras (localizacao, preco, etc)
  embedding VECTOR(768),            -- Vertex AI multilingual
  language TEXT DEFAULT 'pt',       -- pt, en, es
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indice HNSW para busca vetorial rapida
CREATE INDEX ON knowledge_chunks
  USING hnsw (embedding vector_cosine_ops);

-- Indice full-text para busca hibrida
ALTER TABLE knowledge_chunks
  ADD COLUMN fts TSVECTOR
  GENERATED ALWAYS AS (
    to_tsvector('portuguese', coalesce(title,'') || ' ' || content)
  ) STORED;
CREATE INDEX ON knowledge_chunks USING gin(fts);

-- Tabela de rotas GPX
CREATE TABLE race_routes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  race_id TEXT NOT NULL UNIQUE,
  gpx_data TEXT,                    -- GPX raw XML
  coordinates JSONB,                -- [[lat, lng, elevation], ...]
  total_distance FLOAT,
  elevation_gain FLOAT,
  elevation_loss FLOAT,
  max_elevation FLOAT,
  min_elevation FLOAT,
  difficulty_score FLOAT,
  terrain_types JSONB,              -- ['asfalto', 'trilha', 'terra']
  aid_stations JSONB,               -- [{km, name, services}]
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Funcao de busca hibrida (vector + text + filtros)
CREATE OR REPLACE FUNCTION search_knowledge(
  query_embedding VECTOR(768),
  query_text TEXT DEFAULT '',
  filter_race_id TEXT DEFAULT NULL,
  filter_category TEXT DEFAULT NULL,
  filter_language TEXT DEFAULT 'pt',
  match_count INT DEFAULT 10
)
RETURNS TABLE (
  id UUID,
  source_type TEXT,
  race_id TEXT,
  category TEXT,
  title TEXT,
  content TEXT,
  metadata JSONB,
  similarity FLOAT,
  text_rank FLOAT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    kc.id,
    kc.source_type,
    kc.race_id,
    kc.category,
    kc.title,
    kc.content,
    kc.metadata,
    1 - (kc.embedding <=> query_embedding) AS similarity,
    CASE
      WHEN query_text = '' THEN 0
      ELSE ts_rank(kc.fts, plainto_tsquery('portuguese', query_text))
    END AS text_rank
  FROM knowledge_chunks kc
  WHERE kc.is_verified = true
    AND (filter_race_id IS NULL OR kc.race_id = filter_race_id)
    AND (filter_category IS NULL OR kc.category = filter_category)
    AND kc.language = filter_language
  ORDER BY
    (0.7 * (1 - (kc.embedding <=> query_embedding))) +
    (0.3 * CASE
      WHEN query_text = '' THEN 0
      ELSE ts_rank(kc.fts, plainto_tsquery('portuguese', query_text))
    END) DESC
  LIMIT match_count;
END;
$$ LANGUAGE plpgsql;
```

---

## 3. Pipeline RAG

### 3.1 Fluxo de Ingestao (Write Path)

```
Usuario cria Tip/Review
        |
        v
Firestore (status: pending)
        |
        v
Cloud Function (trigger: onCreate)
        |
   +----+----+
   |         |
   v         v
Moderacao   Moderacao
de Texto    de Imagem
(Gemini/    (Cloud Vision
Perspective) SafeSearch)
   |         |
   +----+----+
        |
        v
   Score < 0.3?  ──> Auto-approve
   Score 0.3-0.8? ──> Fila de moderacao (admin review)
   Score > 0.8?  ──> Auto-reject
        |
        v (se aprovado)
   Gerar Embedding (Vertex AI multilingual)
        |
        v
   Inserir no Supabase (knowledge_chunks)
        |
        v
   Atualizar Firestore (embeddingStatus: embedded, vectorId)
```

### 3.2 Fluxo de Consulta (Read Path)

```
Usuario faz pergunta no chat
  "Onde me hospedar perto da Maratona de Berlin?"
        |
        v
Cloud Function (RAG Orchestrator)
        |
        v
1. Classificar Intent (Router Agent)
   -> categoria: "hotel"
   -> raceId: "berlin_marathon"
        |
        v
2. Gerar Embedding da query
   -> Vertex AI embed("hospedar perto maratona berlin")
        |
        v
3. Busca Hibrida no Supabase
   -> search_knowledge(embedding, "hotel berlin",
        race_id="berlin_marathon",
        category="hotel")
        |
        v
4. Re-ranking (top-k mais relevantes)
        |
        v
5. Montar Contexto + System Prompt do Agente
        |
        v
6. Gerar Resposta (Claude / Gemini)
   -> Resposta estruturada com:
      - Lista de hoteis recomendados
      - Precos aproximados
      - Distancia do ponto de largada
      - Dicas dos corredores
      - Links uteis
        |
        v
7. Retornar ao Flutter App
   -> Renderizar cards, mapa, lista
```

---

## 4. Sistema de Agentes

### Router Agent (Classificador de Intent)

```
Query do usuario
      |
      v
[Router Agent] ──> Classifica em:
      |
      +──> "race_info"    -> Race Info Agent
      +──> "accommodation"-> Travel Agent
      +──> "food"         -> Travel Agent
      +──> "safety"       -> Safety Agent
      +──> "shopping"     -> Local Expert Agent
      +──> "tourism"      -> Local Expert Agent
      +──> "training"     -> Training Agent
      +──> "route"        -> Race Info Agent
      +──> "general"      -> General Agent
```

### Agentes Especializados

| Agente | Dominio | Fontes de Dados | Exemplos de Perguntas |
|--------|---------|-----------------|----------------------|
| **Race Info** | Altimetria, percurso, kit, inscricao | race_routes + knowledge_chunks(race_info) | "Qual a altimetria da UTMB?", "O que vem no kit?" |
| **Travel** | Hoteis, restaurantes, transporte | knowledge_chunks(hotel, food, transport) | "Onde comer perto da largada?", "Melhor hotel custo-beneficio?" |
| **Safety** | Clima, terreno, equipamento, saude | knowledge_chunks(safety, climate) | "Que roupa levar?", "Preciso de bastao de trekking?" |
| **Local Expert** | Compras, turismo, pacotes de viagem | knowledge_chunks(shopping, tourism, travel_package) | "O que vale comprar em Berlin?", "Tem pacote com inscricao?" |
| **Training** | Treinos, preparacao, nutricao | knowledge_chunks(training) | "Como treinar para meia maratona?", "Estrategia de hidratacao?" |
| **General** | Qualquer assunto | todos os chunks | Perguntas que nao se encaixam em nenhum agente |

---

## 5. Mapas e Rotas

### Fluxo de Exibicao de Rotas

```
race_detail_screen.dart
        |
        v
Buscar GPX do Supabase (race_routes)
        |
        v
Parser GPX -> List<LatLng> + List<double> elevations
        |
        +──> Google Maps Widget
        |      - Polyline colorida por elevacao
        |      - Markers: largada, chegada, postos de hidratacao
        |      - Camera bounds automatico
        |
        +──> Elevation Chart (fl_chart)
               - X: distancia acumulada (km)
               - Y: altitude (m)
               - Marcadores de postos de hidratacao
               - Gradiente de cor por dificuldade
```

### Campos adicionais no RaceModel

```dart
class RaceModel {
  // ... campos existentes ...

  // Novos campos para mapa
  final String? gpxUrl;
  final double? elevationGain;
  final double? elevationLoss;
  final double? maxElevation;
  final double? minElevation;
  final List<GeoPoint>? routeCoordinates;
  final List<AidStation>? aidStations;
  final List<String>? terrainTypes;
  final double? difficultyScore;
}

class AidStation {
  final double km;
  final String name;
  final List<String> services; // ['water', 'food', 'medical']
  final GeoPoint location;
}
```

---

## 6. Categorias de Conhecimento

```dart
enum KnowledgeCategory {
  altimetry,       // Altimetria e perfil de elevacao
  route,           // Percurso, terreno, dificuldades
  problems,        // Problemas comuns, armadilhas
  accommodation,   // Hoteis, hostels, airbnb
  food,            // Restaurantes, alimentacao
  tourism,         // Pontos turisticos
  safety,          // Cuidados, clima, equipamento
  shopping,        // Compras, o que vale a pena
  travelPackage,   // Pacotes de viagem
  raceKit,         // Kit da prova, obrigatorios
  training,        // Treinos e preparacao
  general,         // Informacoes gerais
}
```

---

## 7. Estrutura do Projeto (Revisada)

```
lib/
+-- core/
|   +-- models/
|   |   +-- race_model.dart        # + campos de rota/mapa
|   |   +-- tip_model.dart         # + embeddingStatus, vectorId
|   |   +-- user_model.dart
|   |   +-- knowledge_chunk.dart   # NOVO: modelo do chunk
|   |   +-- aid_station.dart       # NOVO: postos de apoio
|   |   +-- chat_message.dart      # NOVO: mensagens do chat IA
|   +-- services/
|   |   +-- auth_service.dart
|   |   +-- race_service.dart
|   |   +-- tip_service.dart
|   |   +-- rag_service.dart       # NOVO: interface com RAG
|   |   +-- map_service.dart       # NOVO: GPX, rotas, elevacao
|   |   +-- supabase_service.dart  # NOVO: client Supabase
|   |   +-- embedding_service.dart # NOVO: geracao de embeddings
|   |   +-- moderation_service.dart# NOVO: moderacao de conteudo
|   +-- constants/
|   +-- theme/
|   +-- utils/
|
+-- features/
|   +-- auth/          # Existente (manter)
|   +-- home/          # Existente (manter)
|   +-- race/
|   |   +-- presentation/
|   |       +-- pages/
|   |       |   +-- races_screen.dart
|   |       |   +-- race_detail_screen.dart  # + mapa + elevacao
|   |       +-- widgets/
|   |           +-- race_map_widget.dart      # NOVO
|   |           +-- elevation_chart.dart      # NOVO
|   |           +-- aid_stations_list.dart    # NOVO
|   +-- tips/          # Existente (manter + moderacao)
|   +-- chat/          # NOVO: Chat com agentes IA
|   |   +-- presentation/
|   |       +-- pages/
|   |       |   +-- chat_screen.dart
|   |       |   +-- chat_history_screen.dart
|   |       +-- providers/
|   |       |   +-- chat_provider.dart
|   |       +-- widgets/
|   |           +-- chat_bubble.dart
|   |           +-- suggestion_chips.dart
|   |           +-- source_card.dart
|   +-- community/     # NOVO: Hub da comunidade
|   +-- profile/       # Existente (expandir)
|
+-- shared/
    +-- widgets/       # Existente (manter)
```

---

## 8. Novas Dependencias

```yaml
# Supabase
supabase_flutter: ^2.0.0

# GPX parsing
gpx: ^2.2.0

# Markdown rendering (para respostas do RAG)
flutter_markdown: ^0.7.0

# Geolocation
geolocator: ^12.0.0

# Image picker (para tips com fotos)
image_picker: ^1.0.0
```

---

## 9. Cloud Functions (Backend)

```
functions/
+-- src/
|   +-- rag/
|   |   +-- query.ts          # Endpoint principal de consulta RAG
|   |   +-- router-agent.ts   # Classificador de intent
|   |   +-- agents/
|   |       +-- race-info.ts
|   |       +-- travel.ts
|   |       +-- safety.ts
|   |       +-- local-expert.ts
|   |       +-- training.ts
|   +-- moderation/
|   |   +-- moderate-tip.ts   # Trigger: tips/{tipId} onCreate
|   |   +-- moderate-review.ts
|   +-- embedding/
|   |   +-- generate.ts       # Gera embedding e insere no Supabase
|   +-- ingestion/
|       +-- scrape-race.ts    # Scraping de dados de corridas
|       +-- import-gpx.ts     # Importar GPX e processar rota
```

---

## 10. Fases de Implementacao

### Fase 1 - Fundacao (2-3 semanas)
- [ ] Setup Supabase + pgvector
- [ ] Criar tabelas knowledge_chunks e race_routes
- [ ] Cloud Function: moderacao basica de tips
- [ ] Cloud Function: geracao de embeddings
- [ ] Expandir RaceModel com campos de rota
- [ ] Integrar supabase_flutter no app

### Fase 2 - RAG Core (2-3 semanas)
- [ ] Implementar search_knowledge no Supabase
- [ ] Cloud Function: RAG query endpoint
- [ ] Router Agent (classificacao de intent)
- [ ] Race Info Agent + Travel Agent
- [ ] Chat screen no Flutter
- [ ] Popular base com dados curados iniciais

### Fase 3 - Mapas e Rotas (1-2 semanas)
- [ ] Parser GPX no Flutter
- [ ] Race Map Widget com polyline
- [ ] Elevation Chart com fl_chart
- [ ] Aid Stations no mapa
- [ ] Integrar na race_detail_screen

### Fase 4 - Agentes Especializados (2 semanas)
- [ ] Safety Agent
- [ ] Local Expert Agent
- [ ] Training Agent
- [ ] Suggestion chips contextuais
- [ ] Source cards (mostrar fontes das respostas)

### Fase 5 - Comunidade e UGC (2-3 semanas)
- [ ] Community Hub (feed, posts)
- [ ] Pipeline completo de moderacao
- [ ] Fluxo de aprovacao admin
- [ ] UGC -> embedding automatico apos aprovacao
- [ ] Sistema de reputacao de contribuidores

### Fase 6 - Polish e Launch (1-2 semanas)
- [ ] Riverpod migration
- [ ] GoRouter
- [ ] Performance (cache, paginacao)
- [ ] Analytics
- [ ] Testes

---

## 11. Decisoes Arquiteturais

| Decisao | Escolha | Motivo |
|---------|---------|--------|
| Vector DB | Supabase pgvector | Hybrid search, SQL power, custo baixo |
| Embedding Model | Vertex AI multilingual (768d) | Ja no GCP, multilingual nativo |
| LLM para RAG | Claude API | Qualidade superior em portugues |
| Auth | Firebase Auth (manter) | Ja funcional, sem motivo para mudar |
| Realtime data | Firestore (manter) | Melhor para CRUD e realtime |
| Maps | Google Maps Flutter | Ja no pubspec, nativo Android/iOS |
| Charts | fl_chart (manter) | Ja no pubspec, flexivel |
| Moderacao | Gemini + Cloud Vision | Custo baixo, integrado ao GCP |
| Backend functions | Cloud Functions (Firebase) | Integrado, triggers Firestore |
