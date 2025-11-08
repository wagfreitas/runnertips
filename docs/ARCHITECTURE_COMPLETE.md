# 🏗️ Arquitetura Completa - Runner Tips Ecosystem

## 🎯 Visão Geral e Diferenciais

### Diferencial Competitivo

O **Runner Tips** será o **único aplicativo que combina**:
1. **Busca Inteligente com IA** - Quando não encontramos no banco, buscamos automaticamente
2. **Base Vetorial para NLP** - Busca em linguagem natural sobre tudo relacionado à corrida
3. **Ecossistema Completo** - Não só corridas, mas hotéis, restaurantes, passeios, tudo integrado
4. **Experiências Validadas** - Sistema de reputação e moderação que garante qualidade
5. **Mapas Interativos** - Trajetos com altimetria e informações técnicas detalhadas
6. **Filtros Inteligentes** - Garantia de que apenas conteúdo relacionado a eventos esportivos seja encontrado

### Público-Alvo

- Corredores/atletas/caminheiros amadores que combinam viagem com esporte
- Perfil: Aventura, qualidade de informação, comunidade, planejamento detalhado

---

## 🏛️ Arquitetura Geral

### Stack Tecnológico Completo

```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend (Flutter)                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Mobile     │  │   Tablet     │  │    Web       │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ REST API / GraphQL
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                 Backend Services Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Firebase   │  │   Supabase   │  │     n8n      │      │
│  │  (Auth +     │  │  (PostgreSQL │  │   (RAG +     │      │
│  │   Storage)   │  │  + Vector    │  │    AI)       │      │
│  │              │  │   Search)    │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            │
┌─────────────────────────────────────────────────────────────┐
│                   Data Layer                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Firestore   │  │  PostgreSQL  │  │  Vector DB   │      │
│  │  (Real-time) │  │  (Primary)   │  │  (pgvector)  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Modelo de Dados Expandido

### 1. Races (Corridas) - Já Existe ✅

```sql
-- Já implementado no Firestore
-- Expandir com novos campos:
ALTER TABLE races ADD COLUMN IF NOT EXISTS 
  elevation_profile JSONB,           -- Perfil de altimetria
  route_coordinates JSONB,           -- Coordenadas do trajeto
  route_map_url TEXT,                -- URL do mapa do trajeto
  route_gpx_url TEXT,                -- Arquivo GPX para download
  route_kml_url TEXT,                -- Arquivo KML para Google Earth
  max_elevation DECIMAL(8,2),        -- Elevação máxima (metros)
  min_elevation DECIMAL(8,2),        -- Elevação mínima (metros)
  total_elevation_gain DECIMAL(8,2), -- Ganho total de elevação
  route_surface TEXT[],              -- ['asphalt', 'trail', 'mixed']
  verified_by UUID[],                -- IDs de usuários que verificaram
  verification_score DECIMAL(3,2);   -- Score de verificação (0-1)
```

### 2. Tips (Dicas) - NOVO

```sql
CREATE TABLE tips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    race_id UUID REFERENCES races(id) ON DELETE SET NULL,
    city_id UUID REFERENCES cities(id) ON DELETE SET NULL,
    
    -- Tipo de dica
    type VARCHAR(20) NOT NULL CHECK (type IN (
        'hotel', 'restaurant', 'transport', 'tourism', 
        'shopping', 'race_tip', 'general'
    )),
    
    -- Categoria específica
    category VARCHAR(30) NOT NULL, -- 'accommodation', 'food', etc.
    
    -- Conteúdo
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    images TEXT[],
    tags TEXT[],
    
    -- Metadados específicos por tipo
    metadata JSONB, -- {
    --   hotel: {price_range, rating, distance_to_race, amenities}
    --   restaurant: {cuisine, price_range, open_hours, carb_friendly}
    --   transport: {type, cost, duration, availability}
    --   tourism: {attraction_type, cost, duration, best_time}
    -- }
    
    -- Localização específica
    location JSONB, -- {latitude, longitude, address, city, country}
    
    -- Relacionamento com corrida
    related_race_id UUID REFERENCES races(id) ON DELETE SET NULL,
    related_race_distance_km DECIMAL(5,2), -- Distância da corrida em km
    
    -- Status e moderação
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    is_moderated BOOLEAN DEFAULT false,
    moderation_status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
    moderation_reason TEXT,
    
    -- Estatísticas
    helpful_count INTEGER DEFAULT 0,
    not_helpful_count INTEGER DEFAULT 0,
    views_count INTEGER DEFAULT 0,
    saves_count INTEGER DEFAULT 0,
    
    -- Embedding vetorial (para busca semântica)
    embedding vector(1536) -- OpenAI ada-002 ou similar
);

-- Índices
CREATE INDEX idx_tips_type ON tips(type);
CREATE INDEX idx_tips_race_id ON tips(race_id);
CREATE INDEX idx_tips_city_id ON tips(city_id);
CREATE INDEX idx_tips_user_id ON tips(user_id);
CREATE INDEX idx_tips_created_at ON tips(created_at DESC);
CREATE INDEX idx_tips_verified ON tips(is_verified) WHERE is_verified = true;
CREATE INDEX idx_tips_embedding ON tips USING ivfflat (embedding vector_cosine_ops);
```

### 3. Reviews (Avaliações de Experiências) - NOVO

```sql
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    race_id UUID REFERENCES races(id) ON DELETE CASCADE,
    
    -- Conteúdo da review
    title VARCHAR(255),
    content TEXT NOT NULL,
    images TEXT[],
    
    -- Ratings por categoria
    ratings JSONB NOT NULL, -- {
    --   overall: 5,
    --   organization: 4,
    --   course: 5,
    --   support: 4,
    --   value: 4,
    --   atmosphere: 5
    -- }
    
    -- Pontos positivos e negativos
    positives TEXT[], -- Lista de pontos positivos
    negatives TEXT[], -- Lista de pontos negativos
    
    -- Metadados
    year_participated INTEGER, -- Ano em que participou
    race_time TEXT, -- Tempo da corrida (opcional)
    weather_conditions TEXT, -- Condições climáticas no dia
    
    -- Status e moderação
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    is_moderated BOOLEAN DEFAULT false,
    moderation_status VARCHAR(20) DEFAULT 'pending',
    
    -- Estatísticas
    helpful_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    
    -- Embedding vetorial
    embedding vector(1536)
);

CREATE INDEX idx_reviews_race_id ON reviews(race_id);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_reviews_created_at ON reviews(created_at DESC);
CREATE INDEX idx_reviews_embedding ON reviews USING ivfflat (embedding vector_cosine_ops);
```

### 4. Cities (Cidades) - NOVO

```sql
CREATE TABLE cities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    country VARCHAR(100) NOT NULL,
    country_code VARCHAR(2), -- ISO 3166-1 alpha-2
    
    -- Localização
    coordinates JSONB NOT NULL, -- {latitude, longitude}
    timezone VARCHAR(50),
    
    -- Informações gerais
    currency VARCHAR(10),
    language VARCHAR(10)[],
    image_urls TEXT[],
    
    -- Estatísticas de corridas
    total_races INTEGER DEFAULT 0,
    upcoming_races INTEGER DEFAULT 0,
    total_tips INTEGER DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    
    UNIQUE(name, state, country)
);

CREATE INDEX idx_cities_country ON cities(country);
CREATE INDEX idx_cities_name ON cities(name);
```

### 5. Route Maps (Mapas de Trajeto) - NOVO

```sql
CREATE TABLE route_maps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    race_id UUID REFERENCES races(id) ON DELETE CASCADE,
    
    -- Dados do trajeto
    route_name VARCHAR(255),
    route_type VARCHAR(20), -- 'marathon', 'half', '10k', etc.
    
    -- Coordenadas
    coordinates JSONB NOT NULL, -- Array de {lat, lng, elevation}
    total_distance_km DECIMAL(8,3),
    
    -- Altimetria
    elevation_profile JSONB, -- {points: [{distance, elevation}], min, max, gain}
    max_elevation DECIMAL(8,2),
    min_elevation DECIMAL(8,2),
    total_elevation_gain DECIMAL(8,2),
    
    -- Arquivos
    gpx_file_url TEXT,
    kml_file_url TEXT,
    map_image_url TEXT, -- Imagem estática do mapa
    interactive_map_url TEXT, -- URL para mapa interativo
    
    -- Metadados
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    is_verified BOOLEAN DEFAULT false,
    
    UNIQUE(race_id, route_type)
);

CREATE INDEX idx_route_maps_race_id ON route_maps(race_id);
```

### 6. Comments (Comentários) - NOVO

```sql
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Relacionamento polimórfico
    target_type VARCHAR(20) NOT NULL CHECK (target_type IN (
        'tip', 'review', 'race'
    )),
    target_id UUID NOT NULL,
    
    -- Conteúdo
    content TEXT NOT NULL,
    
    -- Hierarquia (para respostas)
    parent_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    
    -- Status e moderação
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    is_moderated BOOLEAN DEFAULT false,
    moderation_status VARCHAR(20) DEFAULT 'pending',
    moderation_reason TEXT,
    moderation_score DECIMAL(3,2), -- Score de toxicidade (0-1)
    
    -- Estatísticas
    likes_count INTEGER DEFAULT 0,
    replies_count INTEGER DEFAULT 0,
    reports_count INTEGER DEFAULT 0,
    
    -- Embedding para detecção de toxicidade
    embedding vector(1536)
);

CREATE INDEX idx_comments_target ON comments(target_type, target_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);
CREATE INDEX idx_comments_parent_id ON comments(parent_id);
CREATE INDEX idx_comments_created_at ON comments(created_at DESC);
```

### 7. Moderation (Moderação) - NOVO

```sql
CREATE TABLE moderation_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Conteúdo a moderar
    content_type VARCHAR(20) NOT NULL, -- 'tip', 'review', 'comment'
    content_id UUID NOT NULL,
    
    -- Razão da moderação
    reason VARCHAR(50), -- 'auto_detected', 'user_report', 'manual'
    reported_by UUID REFERENCES users(id),
    
    -- Análise automática
    toxicity_score DECIMAL(3,2), -- 0-1 (0 = seguro, 1 = muito tóxico)
    category VARCHAR(50), -- 'spam', 'offensive', 'irrelevant', etc.
    detected_keywords TEXT[],
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'reviewing', 'approved', 'rejected'
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMP,
    review_notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_moderation_queue_status ON moderation_queue(status) WHERE status = 'pending';
CREATE INDEX idx_moderation_queue_content ON moderation_queue(content_type, content_id);
```

### 8. Vector Embeddings (Embeddings Vetoriais) - NOVO

```sql
-- Tabela centralizada para busca semântica
CREATE TABLE vector_embeddings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relacionamento polimórfico
    content_type VARCHAR(20) NOT NULL, -- 'tip', 'review', 'race', 'comment'
    content_id UUID NOT NULL,
    
    -- Texto original (para reconstrução)
    original_text TEXT NOT NULL,
    
    -- Embedding vetorial (OpenAI ada-002: 1536 dimensões)
    embedding vector(1536) NOT NULL,
    
    -- Metadados para filtragem
    metadata JSONB, -- {
    --   race_id: UUID,
    --   city_id: UUID,
    --   user_id: UUID,
    --   category: string,
    --   type: string,
    --   language: string
    -- }
    
    -- Índice de qualidade
    quality_score DECIMAL(3,2), -- Relevância do conteúdo
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(content_type, content_id)
);

-- Índice HNSW para busca vetorial eficiente
CREATE INDEX idx_vector_embeddings_embedding 
    ON vector_embeddings 
    USING hnsw (embedding vector_cosine_ops)
    WITH (m = 16, ef_construction = 64);

-- Índices para filtragem rápida
CREATE INDEX idx_vector_embeddings_content ON vector_embeddings(content_type, content_id);
CREATE INDEX idx_vector_embeddings_metadata ON vector_embeddings USING GIN(metadata);
```

---

## 🤖 Sistema de Busca em Linguagem Natural (NLP)

### Arquitetura RAG (Retrieval-Augmented Generation)

```
┌─────────────────────────────────────────────────────────────┐
│                    User Query (NLP)                          │
│  "Qual restaurante mais indicado para comer massa na        │
│   Maratona de Assunção?"                                     │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              Query Processing (n8n)                          │
│  1. Extrair entidades (corrida, cidade, tipo)                │
│  2. Classificar intenção (buscar, comparar, recomendar)      │
│  3. Validar contexto (apenas eventos esportivos?)            │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│            Embedding Generation (OpenAI)                     │
│  - Converter query em vetor 1536 dimensões                   │
│  - Usar modelo: text-embedding-ada-002                       │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│         Vector Search (Supabase pgvector)                    │
│  1. Busca por similaridade (cosine similarity)               │
│  2. Filtros: race_id, city_id, type, category                │
│  3. Top K resultados (K=10)                                  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│         Context Enrichment (n8n)                             │
│  1. Buscar dados completos no PostgreSQL                     │
│  2. Adicionar contexto de corrida/cidade                     │
│  3. Filtrar por relevância e qualidade                       │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│         Response Generation (OpenAI GPT-4)                   │
│  1. Construir prompt com contexto                            │
│  2. Gerar resposta natural                                   │
│  3. Incluir referências e fontes                             │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              Formatted Response                              │
│  "O restaurante La Pasta é altamente recomendado..."         │
└─────────────────────────────────────────────────────────────┘
```

### Fluxo n8n para RAG

#### 1. Webhook de Entrada
```javascript
// Input: { query: "Qual o melhor hotel próximo à largada da Maratona de Nova York?" }
```

#### 2. Validação de Query (Filtro de Conteúdo)
```javascript
// Node: Function - Validate Query
const sportsKeywords = [
    'maratona', 'marathon', 'corrida', 'race', 'triatlo', 'triathlon',
    'ironman', 'duatlo', 'duathlon', 'meia maratona', 'half marathon',
    'ultramaratona', 'ultra', 'trail', 'caminhada', 'walk', 'run',
    'corredor', 'runner', 'atleta', 'athlete'
];

function validateQuery(query) {
    const lowerQuery = query.toLowerCase();
    const hasSportKeyword = sportsKeywords.some(keyword => 
        lowerQuery.includes(keyword)
    );
    
    // Verificar se menciona eventos esportivos ou cidades conhecidas por corridas
    const raceCities = ['nova york', 'boston', 'berlim', 'londres', ...];
    const mentionsRaceCity = raceCities.some(city => 
        lowerQuery.includes(city)
    );
    
    if (!hasSportKeyword && !mentionsRaceCity) {
        return {
            valid: false,
            reason: 'Query não está relacionada a eventos esportivos'
        };
    }
    
    return { valid: true };
}
```

#### 3. Extração de Entidades
```javascript
// Node: OpenAI - Extract Entities
const prompt = `
Extraia entidades da seguinte query sobre corridas/eventos esportivos:

Query: "${query}"

Extraia:
- race_name: Nome da corrida mencionada
- city: Cidade mencionada
- country: País mencionado
- query_type: 'hotel', 'restaurant', 'transport', 'tourism', 'race_info'
- intent: 'search', 'compare', 'recommend', 'question'

Retorne JSON válido.
`;
```

#### 4. Geração de Embedding
```javascript
// Node: OpenAI - Generate Embedding
const embedding = await openai.embeddings.create({
    model: 'text-embedding-ada-002',
    input: query
});
```

#### 5. Busca Vetorial no Supabase
```sql
-- Query SQL no Supabase
SELECT 
    ve.content_type,
    ve.content_id,
    ve.original_text,
    ve.metadata,
    1 - (ve.embedding <=> $1::vector) as similarity
FROM vector_embeddings ve
WHERE 
    -- Filtrar apenas conteúdo relacionado a eventos esportivos
    (ve.metadata->>'race_id')::uuid IS NOT NULL
    OR (ve.metadata->>'city_id')::uuid IS NOT NULL
    AND ve.quality_score >= 0.7
ORDER BY similarity DESC
LIMIT 10;
```

#### 6. Enriquecimento de Contexto
```javascript
// Node: PostgreSQL - Get Full Content
// Buscar dados completos dos IDs encontrados
```

#### 7. Geração de Resposta
```javascript
// Node: OpenAI - Generate Response
const prompt = `
Você é um assistente especializado em corridas e eventos esportivos.

Contexto encontrado:
${context}

Query do usuário: "${query}"

Gere uma resposta natural e útil baseada no contexto.
Se não houver informação suficiente, seja honesto.
Sempre mencione as fontes quando possível.
`;
```

---

## 🗺️ Sistema de Mapas e Trajetos

### Integração com Google Maps / Mapbox

```dart
// lib/core/models/route_map_model.dart
class RouteMapModel {
  final String id;
  final String raceId;
  final String routeName;
  final RouteType routeType;
  
  // Coordenadas do trajeto
  final List<RoutePoint> coordinates;
  
  // Altimetria
  final ElevationProfile elevationProfile;
  
  // Arquivos
  final String? gpxFileUrl;
  final String? kmlFileUrl;
  final String? mapImageUrl;
  
  // Métricas
  final double totalDistanceKm;
  final double maxElevation;
  final double minElevation;
  final double totalElevationGain;
}

class RoutePoint {
  final double latitude;
  final double longitude;
  final double? elevation;
  final double? distanceFromStart; // em km
}

class ElevationProfile {
  final List<ElevationPoint> points;
  final double maxElevation;
  final double minElevation;
  final double totalGain;
}

class ElevationPoint {
  final double distance; // km desde o início
  final double elevation; // metros
}
```

### Tela de Mapa Interativo

```dart
// lib/features/race/presentation/pages/race_route_map_screen.dart
// - Mapa interativo com trajeto
// - Gráfico de altimetria abaixo do mapa
// - Marcadores de pontos importantes (largada, chegada, postos de água)
// - Opções: ver em 2D, 3D, satélite
// - Download de GPX/KML
```

---

## 🛡️ Sistema de Moderação

### Moderação Automática (IA)

#### 1. Detecção de Toxicidade
```javascript
// n8n Node: OpenAI Moderation API
const moderation = await openai.moderations.create({
    input: commentContent
});

// Retorna scores para:
// - hate
// - harassment
// - self-harm
// - sexual
// - violence
// - spam
```

#### 2. Detecção de Conteúdo Irrelevante
```javascript
// Verificar se o conteúdo está relacionado a eventos esportivos
const relevantKeywords = [...]; // Lista de palavras-chave
const relevanceScore = calculateRelevance(content, relevantKeywords);

if (relevanceScore < 0.3) {
    // Marcar como irrelevante
}
```

#### 3. Detecção de Spam
```javascript
// Verificar padrões de spam:
// - Muitas URLs
// - Repetição excessiva
// - Palavras em maiúsculas excessivas
// - Emojis excessivos
```

### Moderação Manual

- Dashboard para moderadores
- Fila de moderação priorizada
- Sistema de flags e reports
- Histórico de ações de moderação

---

## 🔍 Filtros de Conteúdo (Garantir Relevância)

### Camadas de Filtragem

#### 1. Filtro de Entrada (n8n)
```javascript
// Validar query ANTES de processar
function validateContentQuery(query) {
    // Lista de palavras-chave relacionadas a eventos esportivos
    const sportEventKeywords = [
        // Corridas
        'maratona', 'marathon', 'corrida', 'race', 'run', 'running',
        'meia maratona', 'half marathon', '21k', '42k',
        'ultramaratona', 'ultra marathon', 'ultra',
        
        // Triatlos
        'triatlo', 'triathlon', 'ironman', 'iron man',
        'duatlo', 'duathlon',
        
        // Trail
        'trail', 'trail running', 'mountain running',
        
        // Caminhadas
        'caminhada', 'walk', 'walking', 'hiking',
        
        // Eventos
        'evento', 'event', 'prova', 'competition',
        'largada', 'start', 'chegada', 'finish',
        
        // Atletas
        'corredor', 'runner', 'atleta', 'athlete',
        'participante', 'participant'
    ];
    
    // Cidades famosas por corridas (whitelist)
    const raceCities = [
        'boston', 'nova york', 'new york', 'londres', 'london',
        'berlim', 'berlin', 'tóquio', 'tokyo', 'chicago',
        'são paulo', 'rio de janeiro', 'buenos aires',
        // ... lista completa
    ];
    
    const lowerQuery = query.toLowerCase();
    
    // Verificar se contém palavras-chave de eventos esportivos
    const hasSportKeyword = sportEventKeywords.some(keyword =>
        lowerQuery.includes(keyword)
    );
    
    // Verificar se menciona cidade conhecida por corridas
    const mentionsRaceCity = raceCities.some(city =>
        lowerQuery.includes(city)
    );
    
    // Verificar se menciona distâncias típicas de corridas
    const raceDistances = ['5k', '10k', '21k', '42k', 'marathon', 'half'];
    const mentionsDistance = raceDistances.some(dist =>
        lowerQuery.includes(dist)
    );
    
    return hasSportKeyword || mentionsRaceCity || mentionsDistance;
}
```

#### 2. Filtro no Banco de Dados
```sql
-- Função para validar conteúdo
CREATE OR REPLACE FUNCTION is_sports_related(content_text TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    -- Verificar palavras-chave
    RETURN content_text ~* 'maratona|marathon|corrida|race|triatlo|triathlon|ironman|trail|runner|atleta';
END;
$$ LANGUAGE plpgsql;

-- Aplicar em inserções
CREATE TRIGGER validate_tip_content
BEFORE INSERT ON tips
FOR EACH ROW
EXECUTE FUNCTION validate_sports_related();
```

#### 3. Filtro no Frontend
```dart
// lib/core/utils/content_validator.dart
class ContentValidator {
  static final List<String> sportKeywords = [
    'maratona', 'marathon', 'corrida', 'race', 'triatlo', 'triathlon',
    // ... lista completa
  ];
  
  static bool isSportsRelated(String content) {
    final lowerContent = content.toLowerCase();
    return sportKeywords.any((keyword) => lowerContent.contains(keyword));
  }
  
  static ValidationResult validateTip(TipModel tip) {
    // Validar título
    if (!isSportsRelated(tip.title)) {
      return ValidationResult(
        valid: false,
        reason: 'O título deve estar relacionado a eventos esportivos'
      );
    }
    
    // Validar conteúdo
    if (!isSportsRelated(tip.content)) {
      return ValidationResult(
        valid: false,
        reason: 'O conteúdo deve estar relacionado a eventos esportivos'
      );
    }
    
    // Validar se está vinculado a uma corrida ou cidade com corridas
    if (tip.raceId == null && tip.cityId == null) {
      return ValidationResult(
        valid: false,
        reason: 'A dica deve estar vinculada a uma corrida ou cidade'
      );
    }
    
    return ValidationResult(valid: true);
  }
}
```

---

## 🔄 Fluxos Principais

### Fluxo 1: Busca em Linguagem Natural

```
Usuário digita: "Qual restaurante mais indicado para comer massa na Maratona de Assunção?"
    ↓
Frontend valida: conteúdo relacionado a eventos esportivos? ✅
    ↓
n8n recebe query
    ↓
Extrai entidades: {race: "Maratona de Assunção", type: "restaurant", intent: "recommend"}
    ↓
Gera embedding da query
    ↓
Busca vetorial no Supabase (filtrado por race_id + type)
    ↓
Encontra top 10 resultados mais relevantes
    ↓
Enriquece com dados completos do PostgreSQL
    ↓
Gera resposta natural com GPT-4
    ↓
Retorna resposta formatada ao usuário
```

### Fluxo 2: Criação de Dica

```
Usuário cria dica sobre hotel
    ↓
Frontend valida: conteúdo relacionado? ✅
    ↓
Envia para backend
    ↓
Backend valida novamente
    ↓
Gera embedding do conteúdo
    ↓
Insere no PostgreSQL (tips table)
    ↓
Insere embedding no vector_embeddings
    ↓
Envia para fila de moderação
    ↓
Moderação automática (IA) analisa
    ↓
Se aprovado: marca como moderado e ativa
    ↓
Se rejeitado: envia para revisão manual
```

### Fluxo 3: Moderação de Comentário

```
Usuário posta comentário
    ↓
Sistema gera embedding
    ↓
Moderação automática verifica:
    - Toxicidade (OpenAI Moderation API)
    - Relevância (similaridade com eventos esportivos)
    - Spam (padrões conhecidos)
    ↓
Se seguro: aprova automaticamente
    ↓
Se duvidoso: envia para fila de moderação manual
    ↓
Moderador revisa e aprova/rejeita
```

---

## 📱 Implementação no Flutter

### Novas Features a Implementar

#### 1. Tela de Busca NLP
```dart
// lib/features/search/presentation/pages/natural_language_search_screen.dart
// - Campo de busca em linguagem natural
// - Sugestões enquanto digita
// - Resultados em tempo real
// - Filtros contextuais
```

#### 2. Tela de Dicas
```dart
// lib/features/tips/presentation/pages/tips_screen.dart
// - Lista de dicas por categoria
// - Filtros: hotel, restaurante, transporte, turismo
// - Busca e ordenação
```

#### 3. Tela de Criar Dica
```dart
// lib/features/tips/presentation/pages/create_tip_screen.dart
// - Formulário dinâmico baseado no tipo
// - Upload de imagens
// - Validação em tempo real
// - Preview antes de publicar
```

#### 4. Tela de Avaliações
```dart
// lib/features/reviews/presentation/pages/reviews_screen.dart
// - Lista de avaliações de uma corrida
// - Filtros: ano, rating, útil
// - Formulário para criar avaliação
```

#### 5. Tela de Mapa de Trajeto
```dart
// lib/features/race/presentation/pages/race_route_map_screen.dart
// - Mapa interativo
// - Gráfico de altimetria
// - Download de GPX/KML
```

---

## 🚀 Plano de Implementação

### Fase 1: Infraestrutura (2 semanas)
- [ ] Configurar Supabase com pgvector
- [ ] Criar schema completo do PostgreSQL
- [ ] Configurar n8n para RAG
- [ ] Integrar OpenAI para embeddings e moderação
- [ ] Criar APIs de backend

### Fase 2: Modelos e Serviços (2 semanas)
- [ ] Criar modelos Dart para Tips, Reviews, Cities
- [ ] Implementar serviços de busca vetorial
- [ ] Implementar serviços de moderação
- [ ] Criar validadores de conteúdo

### Fase 3: Features Core (3 semanas)
- [ ] Tela de busca NLP
- [ ] Tela de dicas
- [ ] Tela de criar dica
- [ ] Tela de avaliações
- [ ] Sistema de mapas e trajetos

### Fase 4: Moderação e Qualidade (2 semanas)
- [ ] Dashboard de moderação
- [ ] Sistema de reports
- [ ] Fila de moderação
- [ ] Notificações para moderadores

### Fase 5: Polimento e Otimização (2 semanas)
- [ ] Testes end-to-end
- [ ] Otimização de performance
- [ ] Melhorias de UX
- [ ] Documentação

---

## 🎯 Diferenciais Únicos

1. **Busca em Linguagem Natural** - Primeiro app de corridas com busca verdadeiramente natural
2. **Ecossistema Completo** - Não só corridas, mas toda a experiência da viagem
3. **IA Integrada** - Busca automática quando não encontra, moderação inteligente
4. **Mapas Técnicos** - Trajetos com altimetria detalhada
5. **Qualidade Garantida** - Sistema robusto de moderação e validação
6. **Comunidade Validadora** - Sistema de reputação e verificação

---

## 📊 Métricas de Sucesso

- Taxa de sucesso da busca NLP: > 85%
- Precisão da moderação automática: > 90%
- Tempo médio de resposta da busca: < 2s
- Satisfação dos usuários com dicas: > 4.5/5
- Taxa de conteúdo aprovado automaticamente: > 70%

---

*Documento criado em: Janeiro 2024*
*Versão: 1.0*

