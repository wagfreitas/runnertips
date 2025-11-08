# 🛡️ Sistema de Moderação - Runner Tips

## 📋 Visão Geral

Sistema completo de moderação automática e manual para garantir qualidade e relevância do conteúdo, mantendo o foco em eventos esportivos.

---

## 🎯 Objetivos

1. **Garantir Relevância**: Apenas conteúdo relacionado a eventos esportivos
2. **Prevenir Toxicidade**: Detectar e remover conteúdo ofensivo
3. **Eliminar Spam**: Identificar e remover spam
4. **Manter Qualidade**: Garantir que dicas e reviews sejam úteis

---

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│              Conteúdo Criado/Atualizado                      │
│        (Tip, Review, Comment)                                │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│         Moderação Automática (IA)                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Toxicidade  │  │  Relevância  │  │     Spam     │      │
│  │  (OpenAI)    │  │  (Embedding) │  │  (Patterns)  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                ┌───────────┴───────────┐
                │                       │
        ┌───────▼───────┐       ┌───────▼───────┐
        │   Aprovado    │       │   Suspenso    │
        │  Automaticamente      │   (Fila Manual)│
        └───────────────┘       └───────────────┘
                                        │
                                        ▼
                        ┌─────────────────────────────┐
                        │  Moderação Manual           │
                        │  (Dashboard de Moderadores) │
                        └─────────────────────────────┘
```

---

## 🤖 Moderação Automática

### 1. Detecção de Toxicidade (OpenAI Moderation API)

#### Configuração no n8n

```javascript
// Node: OpenAI Moderation
const moderation = await $http.post('https://api.openai.com/v1/moderations', {
    input: contentText
});

const result = moderation.results[0];

// Categorias verificadas:
// - hate: Discursos de ódio
// - hate/threatening: Ameaças de ódio
// - harassment: Assédio
// - harassment/threatening: Ameaças de assédio
// - self-harm: Auto-flagelação
// - sexual: Conteúdo sexual
// - sexual/minors: Conteúdo sexual envolvendo menores
// - violence: Violência
// - violence/graphic: Violência gráfica

// Score de toxicidade (0-1)
const toxicityScore = Math.max(
    result.categories.hate ? result.category_scores.hate : 0,
    result.categories.harassment ? result.category_scores.harassment : 0,
    result.categories.violence ? result.category_scores.violence : 0
);

return {
    flagged: result.flagged,
    toxicityScore: toxicityScore,
    categories: result.categories,
    categoryScores: result.category_scores
};
```

#### Lógica de Decisão

```javascript
function decideModerationAction(moderationResult) {
    const { flagged, toxicityScore } = moderationResult;
    
    // Se marcado como perigoso, rejeitar automaticamente
    if (flagged) {
        return {
            action: 'reject',
            reason: 'Content flagged as toxic or inappropriate',
            requiresReview: false
        };
    }
    
    // Se score de toxicidade alto mas não flagado, enviar para revisão
    if (toxicityScore > 0.7) {
        return {
            action: 'suspend',
            reason: 'High toxicity score',
            requiresReview: true
        };
    }
    
    // Se score médio, aprovar mas monitorar
    if (toxicityScore > 0.5) {
        return {
            action: 'approve',
            reason: 'Approved with monitoring',
            requiresReview: false,
            monitor: true
        };
    }
    
    // Aprovar normalmente
    return {
        action: 'approve',
        reason: 'Content appears safe',
        requiresReview: false
    };
}
```

### 2. Verificação de Relevância (Embedding Similarity)

#### Gerar Embedding do Conteúdo

```javascript
// Node: Generate Content Embedding
const contentEmbedding = await $http.post('https://api.openai.com/v1/embeddings', {
    model: 'text-embedding-ada-002',
    input: contentText
});
```

#### Comparar com Embeddings de Referência

```sql
-- Buscar embeddings de referência (conteúdo esportivo validado)
SELECT embedding 
FROM vector_embeddings 
WHERE content_type = 'reference'
ORDER BY quality_score DESC
LIMIT 10;

-- Calcular similaridade média
SELECT AVG(1 - (embedding <=> $1::vector)) as avg_similarity
FROM (
    SELECT embedding 
    FROM vector_embeddings 
    WHERE content_type = 'reference'
    ORDER BY quality_score DESC
    LIMIT 10
) ref_embeddings;
```

#### Decisão Baseada em Similaridade

```javascript
function checkRelevance(contentEmbedding, referenceEmbeddings) {
    // Calcular similaridade média com conteúdos de referência
    const similarities = referenceEmbeddings.map(ref => 
        cosineSimilarity(contentEmbedding, ref.embedding)
    );
    
    const avgSimilarity = similarities.reduce((a, b) => a + b) / similarities.length;
    
    // Se similaridade muito baixa, conteúdo provavelmente irrelevante
    if (avgSimilarity < 0.5) {
        return {
            relevant: false,
            score: avgSimilarity,
            reason: 'Content not related to sports events'
        };
    }
    
    // Se similaridade média, verificar manualmente
    if (avgSimilarity < 0.7) {
        return {
            relevant: true,
            score: avgSimilarity,
            requiresReview: true,
            reason: 'Relevance needs verification'
        };
    }
    
    // Alta similaridade, conteúdo relevante
    return {
        relevant: true,
        score: avgSimilarity,
        requiresReview: false
    };
}
```

### 3. Detecção de Spam (Padrões e Regras)

#### Padrões de Spam

```javascript
// Node: Detect Spam Patterns
function detectSpam(content) {
    const patterns = {
        // Muitas URLs
        excessiveUrls: (content.match(/https?:\/\//g) || []).length > 3,
        
        // Muitos emojis
        excessiveEmojis: (content.match(/[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]/gu) || []).length > 10,
        
        // Muitas maiúsculas
        excessiveCaps: (content.match(/[A-Z]/g) || []).length / content.length > 0.5,
        
        // Repetição excessiva
        excessiveRepetition: /(.{10,})\1{2,}/.test(content),
        
        // Palavras suspeitas
        suspiciousWords: /(free|click|buy now|limited time|act now)/i.test(content),
        
        // Muito curto (provavelmente spam)
        tooShort: content.length < 20,
        
        // Muito longo sem estrutura
        tooLongUnstructured: content.length > 5000 && !content.includes('\n')
    };
    
    const spamScore = Object.values(patterns).filter(Boolean).length;
    
    return {
        isSpam: spamScore >= 3,
        spamScore: spamScore,
        patterns: Object.entries(patterns)
            .filter(([_, value]) => value)
            .map(([key]) => key)
    };
}
```

---

## 📊 Sistema de Scores

### Score Composto

```javascript
function calculateModerationScore(content, moderationResults) {
    const { toxicity, relevance, spam } = moderationResults;
    
    // Pesos
    const weights = {
        toxicity: 0.5,    // Toxicidade é mais importante
        relevance: 0.3,   // Relevância é importante
        spam: 0.2         // Spam é menos crítico (pode ser manual)
    };
    
    // Normalizar scores (0-1)
    const normalizedScores = {
        toxicity: 1 - toxicity.toxicityScore, // Inverter (mais tóxico = score menor)
        relevance: relevance.score,
        spam: 1 - (spam.spamScore / 6) // Normalizar spamScore (0-6) para (0-1)
    };
    
    // Calcular score composto
    const compositeScore = 
        normalizedScores.toxicity * weights.toxicity +
        normalizedScores.relevance * weights.relevance +
        normalizedScores.spam * weights.spam;
    
    return {
        compositeScore: compositeScore,
        breakdown: {
            toxicity: normalizedScores.toxicity,
            relevance: normalizedScores.relevance,
            spam: normalizedScores.spam
        },
        decision: makeDecision(compositeScore, moderationResults)
    };
}

function makeDecision(compositeScore, results) {
    // Se toxicidade flagrada, rejeitar
    if (results.toxicity.flagged) {
        return { action: 'reject', auto: true };
    }
    
    // Se spam detectado fortemente, rejeitar
    if (results.spam.isSpam && results.spam.spamScore >= 5) {
        return { action: 'reject', auto: true };
    }
    
    // Se relevância muito baixa, rejeitar
    if (!results.relevance.relevant && results.relevance.score < 0.3) {
        return { action: 'reject', auto: true };
    }
    
    // Score muito baixo, rejeitar
    if (compositeScore < 0.4) {
        return { action: 'reject', auto: true };
    }
    
    // Score médio-baixo, revisar manualmente
    if (compositeScore < 0.6) {
        return { action: 'suspend', auto: false, requiresReview: true };
    }
    
    // Score médio, aprovar mas monitorar
    if (compositeScore < 0.8) {
        return { action: 'approve', auto: true, monitor: true };
    }
    
    // Score alto, aprovar normalmente
    return { action: 'approve', auto: true, monitor: false };
}
```

---

## 🗄️ Schema do Banco de Dados

### Tabela de Moderação

```sql
CREATE TABLE moderation_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Conteúdo a moderar
    content_type VARCHAR(20) NOT NULL CHECK (content_type IN (
        'tip', 'review', 'comment'
    )),
    content_id UUID NOT NULL,
    
    -- Dados do conteúdo (cache)
    content_text TEXT NOT NULL,
    content_author_id UUID REFERENCES users(id),
    
    -- Razão da moderação
    reason VARCHAR(50) NOT NULL, -- 'auto_detected', 'user_report', 'manual'
    reported_by UUID REFERENCES users(id),
    
    -- Análise automática
    toxicity_score DECIMAL(3,2), -- 0-1
    toxicity_categories JSONB, -- {hate: true, harassment: false, ...}
    relevance_score DECIMAL(3,2), -- 0-1
    spam_score INTEGER, -- 0-6
    spam_patterns TEXT[],
    composite_score DECIMAL(3,2), -- Score final
    
    -- Decisão automática
    auto_decision VARCHAR(20), -- 'approve', 'reject', 'suspend'
    auto_decision_confidence DECIMAL(3,2),
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN (
        'pending', 'reviewing', 'approved', 'rejected', 'appealed'
    )),
    
    -- Revisão manual
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMP,
    review_notes TEXT,
    manual_decision VARCHAR(20), -- 'approve', 'reject', 'edit'
    
    -- Ações tomadas
    actions_taken JSONB, -- {hidden: true, edited: true, ...}
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(content_type, content_id)
);

CREATE INDEX idx_moderation_queue_status 
    ON moderation_queue(status) 
    WHERE status IN ('pending', 'reviewing');

CREATE INDEX idx_moderation_queue_created_at 
    ON moderation_queue(created_at DESC);
```

### Tabela de Reports

```sql
CREATE TABLE content_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Conteúdo reportado
    content_type VARCHAR(20) NOT NULL,
    content_id UUID NOT NULL,
    
    -- Report
    reported_by UUID REFERENCES users(id) NOT NULL,
    reason VARCHAR(50) NOT NULL, -- 'spam', 'offensive', 'irrelevant', 'fake'
    description TEXT,
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending',
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_content_reports_status 
    ON content_reports(status) 
    WHERE status = 'pending';
```

---

## 🔄 Fluxo Completo

### 1. Conteúdo Criado

```javascript
// Quando usuário cria tip/review/comment
const content = {
    type: 'tip',
    id: 'uuid',
    text: '...',
    author_id: 'uuid'
};
```

### 2. Moderação Automática

```javascript
// n8n workflow
const moderation = await moderateContent(content.text);

// Resultado:
{
    toxicity: { flagged: false, score: 0.1 },
    relevance: { relevant: true, score: 0.85 },
    spam: { isSpam: false, score: 0 },
    compositeScore: 0.88,
    decision: { action: 'approve', auto: true }
}
```

### 3. Decisão Automática

```javascript
if (decision.action === 'approve' && decision.auto) {
    // Aprovar automaticamente
    await approveContent(content);
} else if (decision.action === 'reject' && decision.auto) {
    // Rejeitar automaticamente
    await rejectContent(content, moderation);
} else {
    // Enviar para fila de moderação manual
    await addToModerationQueue(content, moderation);
}
```

### 4. Moderação Manual (se necessário)

```javascript
// Moderador revisa na dashboard
const review = {
    content_id: 'uuid',
    decision: 'approve', // ou 'reject', 'edit'
    notes: 'Conteúdo relevante e útil'
};

await processManualReview(review);
```

---

## 📱 Dashboard de Moderação

### Interface do Moderador

```dart
// lib/features/moderation/presentation/pages/moderation_dashboard_screen.dart

// Funcionalidades:
// - Lista de conteúdo pendente
// - Filtros: tipo, score, prioridade
// - Visualização do conteúdo
// - Ações: aprovar, rejeitar, editar
// - Histórico de moderações
```

### Priorização

```sql
-- Ordenar por prioridade
SELECT * FROM moderation_queue
WHERE status = 'pending'
ORDER BY 
    CASE 
        WHEN toxicity_score > 0.8 THEN 1
        WHEN composite_score < 0.4 THEN 2
        ELSE 3
    END,
    created_at ASC;
```

---

## 🚨 Sistema de Reports

### Usuário Reporta Conteúdo

```dart
// lib/features/moderation/presentation/widgets/report_content_widget.dart

// Opções de report:
// - Spam
// - Conteúdo ofensivo
// - Informação falsa
// - Irrelevante
// - Outro (com descrição)
```

### Processamento de Reports

```javascript
// Quando usuário reporta conteúdo
const report = {
    content_type: 'tip',
    content_id: 'uuid',
    reason: 'spam',
    reported_by: 'user_uuid'
};

// Adicionar à fila de moderação
await addToModerationQueue(content, {
    reason: 'user_report',
    reported_by: report.reported_by
});

// Se múltiplos reports, aumentar prioridade
const reportCount = await getReportCount(content_id);
if (reportCount >= 3) {
    await increasePriority(content_id);
}
```

---

## 🔒 Segurança e Privacidade

### 1. Logs de Moderação

```sql
CREATE TABLE moderation_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_type VARCHAR(20),
    content_id UUID,
    action VARCHAR(20), -- 'approve', 'reject', 'edit'
    performed_by UUID REFERENCES users(id),
    reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2. Apeals (Recursos)

```sql
CREATE TABLE moderation_appeals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    moderation_queue_id UUID REFERENCES moderation_queue(id),
    appealed_by UUID REFERENCES users(id),
    appeal_reason TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 📊 Métricas

### KPIs de Moderação

- Taxa de aprovação automática: > 70%
- Tempo médio de moderação manual: < 24h
- Precisão da moderação automática: > 90%
- Taxa de falsos positivos: < 5%
- Taxa de falsos negativos: < 10%

---

*Documento criado em: Janeiro 2024*
*Versão: 1.0*

