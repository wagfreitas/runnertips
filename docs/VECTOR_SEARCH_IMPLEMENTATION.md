# 🔍 Implementação de Busca Vetorial e RAG

## 📋 Visão Geral

Este documento detalha a implementação do sistema de busca vetorial usando Supabase (PostgreSQL + pgvector) e RAG (Retrieval-Augmented Generation) com n8n.

---

## 🗄️ Configuração do Banco Vetorial

### 1. Instalar Extensão pgvector no Supabase

```sql
-- No Supabase SQL Editor
CREATE EXTENSION IF NOT EXISTS vector;

-- Verificar instalação
SELECT * FROM pg_extension WHERE extname = 'vector';
```

### 2. Criar Tabela de Embeddings

```sql
-- Tabela principal de embeddings
CREATE TABLE vector_embeddings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_type VARCHAR(20) NOT NULL CHECK (content_type IN (
        'tip', 'review', 'race', 'comment'
    )),
    content_id UUID NOT NULL,
    
    -- Texto original para reconstrução
    original_text TEXT NOT NULL,
    
    -- Embedding vetorial (OpenAI ada-002: 1536 dimensões)
    embedding vector(1536) NOT NULL,
    
    -- Metadados para filtragem rápida
    metadata JSONB NOT NULL DEFAULT '{}',
    -- Estrutura do metadata:
    -- {
    --   "race_id": "uuid",
    --   "city_id": "uuid",
    --   "user_id": "uuid",
    --   "category": "hotel|restaurant|transport|tourism",
    --   "type": "tip|review|race",
    --   "language": "pt|en|es",
    --   "quality_score": 0.0-1.0
    -- }
    
    -- Score de qualidade/relevância
    quality_score DECIMAL(3,2) DEFAULT 0.8,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(content_type, content_id)
);

-- Índice HNSW para busca vetorial eficiente
CREATE INDEX idx_vector_embeddings_embedding 
    ON vector_embeddings 
    USING hnsw (embedding vector_cosine_ops)
    WITH (m = 16, ef_construction = 64);

-- Índices para filtragem
CREATE INDEX idx_vector_embeddings_content 
    ON vector_embeddings(content_type, content_id);

CREATE INDEX idx_vector_embeddings_metadata 
    ON vector_embeddings USING GIN(metadata);

CREATE INDEX idx_vector_embeddings_quality 
    ON vector_embeddings(quality_score DESC) 
    WHERE quality_score >= 0.7;
```

### 3. Função para Busca Vetorial

```sql
-- Função para busca vetorial com filtros
CREATE OR REPLACE FUNCTION search_vector_embeddings(
    query_embedding vector(1536),
    content_types TEXT[] DEFAULT NULL,
    race_id_filter UUID DEFAULT NULL,
    city_id_filter UUID DEFAULT NULL,
    category_filter TEXT DEFAULT NULL,
    min_quality DECIMAL DEFAULT 0.7,
    similarity_threshold DECIMAL DEFAULT 0.7,
    limit_results INTEGER DEFAULT 10
)
RETURNS TABLE (
    content_type VARCHAR(20),
    content_id UUID,
    original_text TEXT,
    metadata JSONB,
    similarity DECIMAL,
    quality_score DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ve.content_type,
        ve.content_id,
        ve.original_text,
        ve.metadata,
        (1 - (ve.embedding <=> query_embedding))::DECIMAL(5,4) as similarity,
        ve.quality_score
    FROM vector_embeddings ve
    WHERE 
        -- Filtro de tipo de conteúdo
        (content_types IS NULL OR ve.content_type = ANY(content_types))
        -- Filtro de corrida
        AND (race_id_filter IS NULL OR (ve.metadata->>'race_id')::UUID = race_id_filter)
        -- Filtro de cidade
        AND (city_id_filter IS NULL OR (ve.metadata->>'city_id')::UUID = city_id_filter)
        -- Filtro de categoria
        AND (category_filter IS NULL OR ve.metadata->>'category' = category_filter)
        -- Filtro de qualidade
        AND ve.quality_score >= min_quality
        -- Filtro de similaridade
        AND (1 - (ve.embedding <=> query_embedding)) >= similarity_threshold
    ORDER BY similarity DESC
    LIMIT limit_results;
END;
$$ LANGUAGE plpgsql;
```

### 4. Função para Inserir/Atualizar Embedding

```sql
-- Função para inserir ou atualizar embedding
CREATE OR REPLACE FUNCTION upsert_vector_embedding(
    p_content_type VARCHAR(20),
    p_content_id UUID,
    p_original_text TEXT,
    p_embedding vector(1536),
    p_metadata JSONB,
    p_quality_score DECIMAL DEFAULT 0.8
)
RETURNS UUID AS $$
DECLARE
    v_id UUID;
BEGIN
    INSERT INTO vector_embeddings (
        content_type,
        content_id,
        original_text,
        embedding,
        metadata,
        quality_score
    ) VALUES (
        p_content_type,
        p_content_id,
        p_original_text,
        p_embedding,
        p_metadata,
        p_quality_score
    )
    ON CONFLICT (content_type, content_id)
    DO UPDATE SET
        original_text = p_original_text,
        embedding = p_embedding,
        metadata = p_metadata,
        quality_score = p_quality_score,
        updated_at = CURRENT_TIMESTAMP
    RETURNING id INTO v_id;
    
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;
```

---

## 🤖 Configuração do n8n para RAG

### Workflow Completo

#### 1. Webhook Trigger

```json
{
  "query": "Qual restaurante mais indicado para comer massa na Maratona de Assunção?",
  "user_id": "uuid-opcional",
  "filters": {
    "race_id": "uuid-opcional",
    "city_id": "uuid-opcional",
    "category": "restaurant"
  }
}
```

#### 2. Node: Validar Query (Function)

```javascript
// Validar se a query está relacionada a eventos esportivos
const sportsKeywords = [
    'maratona', 'marathon', 'corrida', 'race', 'triatlo', 'triathlon',
    'ironman', 'duatlo', 'duathlon', 'meia maratona', 'half marathon',
    'ultramaratona', 'ultra', 'trail', 'caminhada', 'walk', 'run',
    'corredor', 'runner', 'atleta', 'athlete'
];

const query = $input.item.json.query.toLowerCase();
const hasSportKeyword = sportsKeywords.some(keyword => 
    query.includes(keyword)
);

if (!hasSportKeyword) {
    return {
        valid: false,
        error: 'Query não está relacionada a eventos esportivos'
    };
}

return {
    valid: true,
    query: $input.item.json.query,
    filters: $input.item.json.filters || {}
};
```

#### 3. Node: Extrair Entidades (OpenAI)

```javascript
// Configurar prompt para extração de entidades
const prompt = `
Você é um assistente especializado em extrair informações de queries sobre corridas e eventos esportivos.

Query: "${$json.query}"

Extraia as seguintes informações e retorne APENAS um JSON válido:
{
    "race_name": "nome da corrida mencionada ou null",
    "city": "cidade mencionada ou null",
    "country": "país mencionado ou null",
    "query_type": "hotel|restaurant|transport|tourism|race_info|general",
    "intent": "search|compare|recommend|question",
    "keywords": ["lista", "de", "palavras", "chave"]
}

Seja preciso e retorne null para campos não encontrados.
`;

// Chamar OpenAI
const response = await $http.post('https://api.openai.com/v1/chat/completions', {
    model: 'gpt-4',
    messages: [{ role: 'user', content: prompt }],
    temperature: 0
});

return JSON.parse(response.choices[0].message.content);
```

#### 4. Node: Buscar Race ID (Supabase)

```sql
-- Se race_name foi extraído, buscar ID da corrida
SELECT id, name, city_id 
FROM races 
WHERE name ILIKE '%{{ $json.race_name }}%'
LIMIT 1;
```

#### 5. Node: Gerar Embedding (OpenAI)

```javascript
const response = await $http.post('https://api.openai.com/v1/embeddings', {
    model: 'text-embedding-ada-002',
    input: $json.query
});

return {
    query: $json.query,
    embedding: response.data[0].embedding,
    entities: $json.entities,
    race_id: $json.race_id
};
```

#### 6. Node: Busca Vetorial (Supabase)

```sql
-- Chamar função de busca vetorial
SELECT * FROM search_vector_embeddings(
    $1::vector,  -- query_embedding
    ARRAY['tip', 'review']::TEXT[],  -- content_types
    $2::UUID,  -- race_id_filter
    NULL::UUID,  -- city_id_filter
    $3::TEXT,  -- category_filter (ex: 'restaurant')
    0.7,  -- min_quality
    0.7,  -- similarity_threshold
    10  -- limit_results
);
```

**Parâmetros:**
- `$1`: Embedding da query (array de 1536 números)
- `$2`: Race ID (se encontrado)
- `$3`: Categoria (ex: 'restaurant')

#### 7. Node: Enriquecer Contexto (Supabase)

```javascript
// Para cada resultado da busca vetorial, buscar dados completos
const results = $input.all();

const enrichedResults = await Promise.all(results.map(async (item) => {
    const { content_type, content_id } = item.json;
    
    let fullData;
    if (content_type === 'tip') {
        // Buscar dica completa
        fullData = await $supabase
            .from('tips')
            .select('*')
            .eq('id', content_id)
            .single();
    } else if (content_type === 'review') {
        // Buscar review completa
        fullData = await $supabase
            .from('reviews')
            .select('*')
            .eq('id', content_id)
            .single();
    }
    
    return {
        ...item.json,
        full_data: fullData
    };
}));

return enrichedResults;
```

#### 8. Node: Gerar Resposta (OpenAI GPT-4)

```javascript
const context = $input.all().map(item => {
    return {
        type: item.json.content_type,
        text: item.json.original_text,
        metadata: item.json.metadata,
        similarity: item.json.similarity
    };
}).slice(0, 5); // Top 5 resultados

const prompt = `
Você é um assistente especializado em corridas e eventos esportivos.

Contexto encontrado:
${JSON.stringify(context, null, 2)}

Query do usuário: "${$('Gerar Embedding').item.json.query}"

Gere uma resposta natural, útil e precisa baseada no contexto fornecido.
- Seja específico e cite exemplos quando possível
- Se não houver informação suficiente no contexto, seja honesto
- Mantenha o foco em eventos esportivos
- Formate a resposta de forma clara e legível

Resposta:`;

const response = await $http.post('https://api.openai.com/v1/chat/completions', {
    model: 'gpt-4',
    messages: [{ role: 'user', content: prompt }],
    temperature: 0.7,
    max_tokens: 500
});

return {
    query: $('Gerar Embedding').item.json.query,
    answer: response.choices[0].message.content,
    sources: context.map(c => ({
        type: c.type,
        id: c.metadata.content_id,
        relevance: c.similarity
    })),
    entities: $('Extrair Entidades').item.json
};
```

#### 9. Node: Responder ao Webhook

```json
{
  "success": true,
  "query": "Qual restaurante mais indicado para comer massa na Maratona de Assunção?",
  "answer": "Baseado nas avaliações da comunidade, o restaurante La Pasta é altamente recomendado...",
  "sources": [
    {
      "type": "tip",
      "id": "uuid",
      "relevance": 0.92
    }
  ],
  "entities": {
    "race_name": "Maratona de Assunção",
    "city": "Assunção",
    "query_type": "restaurant",
    "intent": "recommend"
  }
}
```

---

## 🔄 Geração de Embeddings ao Criar Conteúdo

### Trigger no PostgreSQL

```sql
-- Função para gerar embedding quando conteúdo é criado/atualizado
CREATE OR REPLACE FUNCTION generate_embedding_for_content()
RETURNS TRIGGER AS $$
DECLARE
    v_embedding vector(1536);
    v_text_to_embed TEXT;
    v_metadata JSONB;
BEGIN
    -- Construir texto para embedding
    IF TG_TABLE_NAME = 'tips' THEN
        v_text_to_embed := NEW.title || ' ' || NEW.content;
        v_metadata := jsonb_build_object(
            'race_id', NEW.race_id,
            'city_id', NEW.city_id,
            'user_id', NEW.user_id,
            'category', NEW.category,
            'type', NEW.type
        );
    ELSIF TG_TABLE_NAME = 'reviews' THEN
        v_text_to_embed := COALESCE(NEW.title, '') || ' ' || NEW.content;
        v_metadata := jsonb_build_object(
            'race_id', NEW.race_id,
            'user_id', NEW.user_id,
            'type', 'review'
        );
    END IF;
    
    -- Chamar n8n webhook para gerar embedding
    -- (isso será feito de forma assíncrona)
    -- Por enquanto, apenas preparar os dados
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para tips
CREATE TRIGGER trigger_generate_tip_embedding
AFTER INSERT OR UPDATE ON tips
FOR EACH ROW
EXECUTE FUNCTION generate_embedding_for_content();

-- Trigger para reviews
CREATE TRIGGER trigger_generate_review_embedding
AFTER INSERT OR UPDATE ON reviews
FOR EACH ROW
EXECUTE FUNCTION generate_embedding_for_content();
```

### Webhook n8n para Gerar Embedding

```javascript
// Receber conteúdo novo
const { content_type, content_id, text, metadata } = $input.item.json;

// Gerar embedding
const embeddingResponse = await $http.post('https://api.openai.com/v1/embeddings', {
    model: 'text-embedding-ada-002',
    input: text
});

const embedding = embeddingResponse.data[0].embedding;

// Inserir no Supabase
await $supabase.rpc('upsert_vector_embedding', {
    p_content_type: content_type,
    p_content_id: content_id,
    p_original_text: text,
    p_embedding: embedding,
    p_metadata: metadata,
    p_quality_score: 0.8
});

return { success: true, content_id };
```

---

## 🧪 Testes

### Teste 1: Busca Simples

```sql
-- Inserir embedding de teste
INSERT INTO vector_embeddings (
    content_type,
    content_id,
    original_text,
    embedding,
    metadata
) VALUES (
    'tip',
    'test-uuid-1',
    'O restaurante La Pasta é excelente para comer massa antes da Maratona de Assunção. Localizado próximo à largada.',
    -- embedding gerado pelo OpenAI
    '[array de 1536 números]',
    '{"race_id": "race-uuid", "category": "restaurant"}'::jsonb
);

-- Buscar
SELECT * FROM search_vector_embeddings(
    '[query embedding]'::vector,
    ARRAY['tip']::TEXT[],
    'race-uuid'::UUID,
    NULL,
    'restaurant',
    0.7,
    0.7,
    10
);
```

### Teste 2: Busca com Filtros

```javascript
// Query: "hotel próximo à largada da Maratona de Nova York"
// Deve retornar apenas hotéis relacionados à Maratona de Nova York
```

---

## 📊 Otimizações

### 1. Cache de Embeddings

```javascript
// Cachear embeddings de queries comuns
const cacheKey = `embedding:${hash(query)}`;
const cached = await redis.get(cacheKey);
if (cached) return cached;
```

### 2. Batch Processing

```javascript
// Processar múltiplos embeddings em lote
const embeddings = await openai.embeddings.create({
    model: 'text-embedding-ada-002',
    input: textsArray // Array de textos
});
```

### 3. Índice Otimizado

```sql
-- Ajustar parâmetros do índice HNSW conforme necessário
-- m: número de conexões (maior = mais preciso, mais lento)
-- ef_construction: tamanho da lista de candidatos (maior = melhor qualidade)
```

---

## 🔒 Segurança

### 1. Validação de Input

```javascript
// Validar query antes de processar
if (query.length > 500) {
    throw new Error('Query muito longa');
}

if (!isValidQuery(query)) {
    throw new Error('Query inválida');
}
```

### 2. Rate Limiting

```javascript
// Limitar número de buscas por usuário
const rateLimit = await checkRateLimit(userId);
if (!rateLimit.allowed) {
    throw new Error('Rate limit exceeded');
}
```

### 3. Sanitização

```javascript
// Sanitizar texto antes de gerar embedding
const sanitized = sanitizeText(text);
```

---

*Documento criado em: Janeiro 2024*
*Versão: 1.0*

