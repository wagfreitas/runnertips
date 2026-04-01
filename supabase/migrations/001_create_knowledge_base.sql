-- ============================================================
-- Runner Tips - Schema do Supabase (pgvector)
-- Migração 001: Criar tabelas da base de conhecimento
-- ============================================================

-- Habilitar extensao pgvector
CREATE EXTENSION IF NOT EXISTS vector;

-- ============================================================
-- 1. Tabela principal: knowledge_chunks
-- Armazena todos os chunks de conhecimento com embeddings
-- ============================================================
CREATE TABLE knowledge_chunks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_type TEXT NOT NULL CHECK (source_type IN ('tip', 'race_info', 'curated', 'scraped')),
  source_id TEXT NOT NULL,
  race_id TEXT,
  category TEXT NOT NULL CHECK (category IN (
    'altimetry', 'route', 'problems', 'accommodation', 'food',
    'tourism', 'safety', 'shopping', 'travel_package', 'race_kit',
    'training', 'general'
  )),
  title TEXT,
  content TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  embedding VECTOR(768),
  language TEXT DEFAULT 'pt' CHECK (language IN ('pt', 'en', 'es')),
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indice HNSW para busca vetorial rapida
CREATE INDEX idx_knowledge_chunks_embedding
  ON knowledge_chunks
  USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64);

-- Indice full-text para busca hibrida (portugues)
ALTER TABLE knowledge_chunks
  ADD COLUMN fts TSVECTOR
  GENERATED ALWAYS AS (
    setweight(to_tsvector('portuguese', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('portuguese', content), 'B')
  ) STORED;

CREATE INDEX idx_knowledge_chunks_fts ON knowledge_chunks USING gin(fts);

-- Indices para filtros comuns
CREATE INDEX idx_knowledge_chunks_race_id ON knowledge_chunks(race_id);
CREATE INDEX idx_knowledge_chunks_category ON knowledge_chunks(category);
CREATE INDEX idx_knowledge_chunks_source ON knowledge_chunks(source_type, source_id);
CREATE INDEX idx_knowledge_chunks_verified ON knowledge_chunks(is_verified);

-- Trigger para updated_at automatico
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_knowledge_chunks_updated_at
  BEFORE UPDATE ON knowledge_chunks
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();


-- ============================================================
-- 2. Tabela de rotas GPX
-- ============================================================
CREATE TABLE race_routes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  race_id TEXT NOT NULL UNIQUE,
  gpx_data TEXT,
  coordinates JSONB,
  total_distance FLOAT DEFAULT 0,
  elevation_gain FLOAT DEFAULT 0,
  elevation_loss FLOAT DEFAULT 0,
  max_elevation FLOAT DEFAULT 0,
  min_elevation FLOAT DEFAULT 0,
  difficulty_score FLOAT,
  terrain_types JSONB DEFAULT '[]',
  aid_stations JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_race_routes_race_id ON race_routes(race_id);

CREATE TRIGGER trigger_race_routes_updated_at
  BEFORE UPDATE ON race_routes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();


-- ============================================================
-- 3. Tabela de historico de chat
-- ============================================================
CREATE TABLE chat_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL,
  race_id TEXT,
  race_name TEXT,
  title TEXT NOT NULL DEFAULT 'Nova conversa',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES chat_sessions(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
  content TEXT NOT NULL,
  agent_type TEXT,
  race_id TEXT,
  sources JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_chat_sessions_user ON chat_sessions(user_id);
CREATE INDEX idx_chat_messages_session ON chat_messages(session_id);

CREATE TRIGGER trigger_chat_sessions_updated_at
  BEFORE UPDATE ON chat_sessions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();


-- ============================================================
-- 4. Funcao de busca hibrida (vector + full-text + filtros)
-- ============================================================
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
  source_id TEXT,
  race_id TEXT,
  category TEXT,
  title TEXT,
  content TEXT,
  metadata JSONB,
  language TEXT,
  is_verified BOOLEAN,
  similarity FLOAT,
  text_rank FLOAT,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    kc.id,
    kc.source_type,
    kc.source_id,
    kc.race_id,
    kc.category,
    kc.title,
    kc.content,
    kc.metadata,
    kc.language,
    kc.is_verified,
    (1 - (kc.embedding <=> query_embedding))::FLOAT AS similarity,
    CASE
      WHEN query_text = '' THEN 0::FLOAT
      ELSE ts_rank_cd(kc.fts, plainto_tsquery('portuguese', query_text))::FLOAT
    END AS text_rank
  FROM knowledge_chunks kc
  WHERE kc.is_verified = true
    AND (filter_race_id IS NULL OR kc.race_id = filter_race_id)
    AND (filter_category IS NULL OR kc.category = filter_category)
    AND kc.language = filter_language
    AND kc.embedding IS NOT NULL
  ORDER BY
    (0.7 * (1 - (kc.embedding <=> query_embedding))) +
    (0.3 * CASE
      WHEN query_text = '' THEN 0
      ELSE ts_rank_cd(kc.fts, plainto_tsquery('portuguese', query_text))
    END) DESC
  LIMIT match_count;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- 5. Row Level Security (RLS)
-- ============================================================

-- Habilitar RLS
ALTER TABLE knowledge_chunks ENABLE ROW LEVEL SECURITY;
ALTER TABLE race_routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Politicas: leitura publica para chunks verificados
CREATE POLICY "Chunks verificados sao publicos"
  ON knowledge_chunks FOR SELECT
  USING (is_verified = true);

-- Politicas: leitura publica para rotas
CREATE POLICY "Rotas sao publicas"
  ON race_routes FOR SELECT
  USING (true);

-- Politicas: chat sessions so para o dono
CREATE POLICY "Usuario ve suas sessoes"
  ON chat_sessions FOR SELECT
  USING (user_id = auth.uid()::TEXT);

CREATE POLICY "Usuario cria suas sessoes"
  ON chat_sessions FOR INSERT
  WITH CHECK (user_id = auth.uid()::TEXT);

-- Politicas: mensagens vinculadas a sessao do usuario
CREATE POLICY "Usuario ve mensagens de suas sessoes"
  ON chat_messages FOR SELECT
  USING (
    session_id IN (
      SELECT id FROM chat_sessions WHERE user_id = auth.uid()::TEXT
    )
  );

CREATE POLICY "Usuario cria mensagens em suas sessoes"
  ON chat_messages FOR INSERT
  WITH CHECK (
    session_id IN (
      SELECT id FROM chat_sessions WHERE user_id = auth.uid()::TEXT
    )
  );

-- Service role pode inserir chunks (usado pelas Cloud Functions)
CREATE POLICY "Service role insere chunks"
  ON knowledge_chunks FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Service role atualiza chunks"
  ON knowledge_chunks FOR UPDATE
  USING (true);

CREATE POLICY "Service role insere rotas"
  ON race_routes FOR ALL
  USING (true);


-- ============================================================
-- 6. Dados iniciais de exemplo (curated)
-- ============================================================
-- NOTA: Embeddings serao gerados via Cloud Function
-- Aqui inserimos o conteudo sem embedding para referencia

INSERT INTO knowledge_chunks (source_type, source_id, race_id, category, title, content, language, is_verified)
VALUES
  ('curated', 'seed_001', 'sao_silvestre', 'route',
   'Percurso da Sao Silvestre',
   'A Corrida de Sao Silvestre tem 15km com largada na Av. Paulista e chegada no mesmo local. O percurso passa por ruas iconicas de Sao Paulo, incluindo a descida da Brigadeiro e subida da 23 de Maio. O terreno e 100% asfalto com algumas subidas moderadas.',
   'pt', true),

  ('curated', 'seed_002', 'sao_silvestre', 'accommodation',
   'Hospedagem perto da Sao Silvestre',
   'Para a Sao Silvestre, recomenda-se hospedar na regiao da Av. Paulista ou Jardins. Hoteis como Ibis Paulista, Mercure Paulista e Tivoli Mofarrej tem otima localizacao. Reserve com antecedencia pois a demanda e alta no fim de ano. Precos variam de R$200 a R$800 a diaria.',
   'pt', true),

  ('curated', 'seed_003', 'sao_silvestre', 'food',
   'Alimentacao na regiao da Sao Silvestre',
   'Na regiao da Paulista ha diversas opcoes para carbo-loading na vespera: Outback, Spoleto, e diversos restaurantes japoneses na Liberdade (15min de metro). No dia da prova, evite alimentos pesados. Ha pontos de hidratacao a cada 3km no percurso.',
   'pt', true),

  ('curated', 'seed_004', 'sao_silvestre', 'safety',
   'Cuidados para a Sao Silvestre',
   'A corrida acontece em 31 de dezembro, geralmente com calor intenso (30-35C). Use protetor solar, bone e roupas leves. Hidrate-se bem nas 24h anteriores. Cuidado com o piso molhado caso chova. Chegue cedo pois o transito fica complicado. Use transporte publico (metro Trianon-MASP).',
   'pt', true),

  ('curated', 'seed_005', 'maratona_sp', 'altimetry',
   'Altimetria da Maratona de Sao Paulo',
   'A Maratona de SP tem um percurso com ganho de elevacao total de aproximadamente 250m. Os pontos mais desafiadores sao a subida da Av. Reboucas (km 15) e a subida do Parque Ibirapuera (km 35). O ponto mais alto e na Av. Paulista (860m) e o mais baixo na marginal Pinheiros (720m).',
   'pt', true),

  ('curated', 'seed_006', 'utmb', 'race_kit',
   'Kit obrigatorio UTMB',
   'O kit obrigatorio da UTMB inclui: mochila de hidratacao (minimo 1L), copo pessoal (minimo 150ml), 2 lanternas frontais com baterias extras, apito de emergencia, cobertor de sobrevivencia, bandagem elastica, telefone celular carregado, documento de identidade, dinheiro (minimo 20 euros), jaqueta impermeavel com costuras seladas, calcas impermeaveis, agasalho quente, luvas, gorro, e alimento de reserva (800kcal minimo).',
   'pt', true),

  ('curated', 'seed_007', 'utmb', 'accommodation',
   'Hospedagem para UTMB em Chamonix',
   'Em Chamonix para a UTMB, as opcoes mais populares sao: Hotel Le Morgane (proximo a largada), Chalet Hotel Le Prieure, ou Airbnb no centro. Reserve com 6+ meses de antecedencia pois a cidade lota. Alternativas mais baratas: Les Houches (10min de trem) ou Argentiere. Campings tambem sao opcao no verao.',
   'pt', true),

  ('curated', 'seed_008', 'berlin_marathon', 'shopping',
   'Compras em Berlim durante a Maratona',
   'Berlim e otima para compras de artigos esportivos. A Expo da Maratona no Tempelhof tem diversas lojas com precos especiais. A Runnerspoint na Kurfurstendamm tem grande variedade. Para souvenirs, visite a KaDeWe (maior loja de departamentos da Europa). Tenis de corrida podem ser ate 30% mais baratos que no Brasil.',
   'pt', true);
