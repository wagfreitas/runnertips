# 🤖 Fluxo do Agente de Busca de Corridas - n8n

## 📋 Visão Geral

Este documento descreve o fluxo do n8n para o agente inteligente de busca de corridas que será acionado quando o usuário não encontrar resultados na busca local.

## 🔄 Fluxo Completo

### **1. Webhook Trigger (Entrada)**
```json
{
  "query": "Maratona de Boston",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### **2. Processamento da Query**
- **Node**: `Function` - Processar Query
- **Função**: Limpar e normalizar a query de busca
- **Saída**:
```json
{
  "originalQuery": "Maratona de Boston",
  "normalizedQuery": "maratona boston",
  "keywords": ["maratona", "boston"],
  "searchType": "race_name"
}
```

### **3. Busca em APIs Externas**

#### **3.1. Active.com API**
- **Node**: `HTTP Request`
- **URL**: `https://api.active.com/v2/search/events`
- **Parâmetros**:
  - `keywords`: query normalizada
  - `category`: "running"
  - `radius`: "100"
  - `limit`: "10"

#### **3.2. Running in the USA API**
- **Node**: `HTTP Request`
- **URL**: `https://api.runningintheusa.com/races`
- **Parâmetros**:
  - `search`: query normalizada
  - `type`: "marathon,half_marathon,10k,5k"
  - `limit`: "10"

#### **3.3. RaceRaves API**
- **Node**: `HTTP Request`
- **URL**: `https://api.racereaves.com/events/search`
- **Parâmetros**:
  - `q`: query normalizada
  - `sport`: "running"
  - `limit`: "10"

### **4. Processamento dos Resultados**

#### **4.1. Merge dos Resultados**
- **Node**: `Merge`
- **Função**: Combinar resultados de todas as APIs
- **Estratégia**: Union (manter todos os resultados únicos)

#### **4.2. Limpeza e Normalização**
- **Node**: `Function` - Processar Resultados
- **Função**: 
  - Remover duplicatas
  - Normalizar campos
  - Calcular confiança
  - Validar dados obrigatórios

```javascript
// Exemplo de função de processamento
const results = $input.all();

const processedResults = results.map(item => {
  const data = item.json;
  
  return {
    name: data.name || data.title || data.event_name,
    location: data.location || data.city || data.venue,
    distance: data.distance || data.race_type || 'Unknown',
    month: extractMonth(data.date),
    year: extractYear(data.date),
    imageUrl: data.image || data.logo || 'default_image_url',
    description: data.description || data.details || '',
    website: data.url || data.website || data.registration_url,
    organizer: data.organizer || data.race_director || '',
    confidence: calculateConfidence(data, originalQuery),
    source: data.source_api || 'unknown'
  };
});

// Remover duplicatas baseado no nome
const uniqueResults = processedResults.filter((item, index, self) => 
  index === self.findIndex(t => t.name.toLowerCase() === item.name.toLowerCase())
);

// Ordenar por confiança
uniqueResults.sort((a, b) => b.confidence - a.confidence);

return uniqueResults.slice(0, 5); // Top 5 resultados
```

### **5. Cálculo de Confiança**
- **Node**: `Function` - Calcular Confiança
- **Algoritmo**:
```javascript
function calculateConfidence(raceData, originalQuery) {
  let confidence = 0;
  const query = originalQuery.toLowerCase();
  const name = raceData.name.toLowerCase();
  const location = raceData.location.toLowerCase();
  
  // Nome exato (100%)
  if (name === query) {
    confidence = 1.0;
  }
  // Nome contém query (80%)
  else if (name.includes(query)) {
    confidence = 0.8;
  }
  // Similaridade por palavras (60%)
  else if (hasCommonWords(name, query)) {
    confidence = 0.6;
  }
  // Localização contém query (40%)
  else if (location.includes(query)) {
    confidence = 0.4;
  }
  // Similaridade geral (20%)
  else {
    confidence = calculateSimilarity(name, query) * 0.2;
  }
  
  // Penalizar se não tem dados essenciais
  if (!raceData.date || !raceData.distance) {
    confidence *= 0.5;
  }
  
  return Math.min(confidence, 1.0);
}
```

### **6. Filtro de Qualidade**
- **Node**: `IF` - Filtrar por Confiança
- **Condição**: `confidence >= 0.3`
- **Ação**: Manter apenas resultados com confiança mínima

### **7. Resposta Final**
- **Node**: `Respond to Webhook`
- **Formato**:
```json
{
  "success": true,
  "query": "Maratona de Boston",
  "suggestions": [
    {
      "name": "Boston Marathon",
      "location": "Boston, MA",
      "distance": "42.195 km",
      "month": "April",
      "year": "2024",
      "imageUrl": "https://example.com/boston-marathon.jpg",
      "description": "The Boston Marathon is the world's oldest annual marathon...",
      "website": "https://www.baa.org/races/boston-marathon",
      "organizer": "Boston Athletic Association",
      "confidence": 0.95
    },
    {
      "name": "Boston Half Marathon",
      "location": "Boston, MA",
      "distance": "21.0975 km",
      "month": "October",
      "year": "2024",
      "imageUrl": "https://example.com/boston-half.jpg",
      "description": "Join us for the Boston Half Marathon...",
      "website": "https://www.baa.org/races/boston-half-marathon",
      "organizer": "Boston Athletic Association",
      "confidence": 0.75
    }
  ],
  "totalFound": 2,
  "processingTime": "1.2s"
}
```

## 🛠️ Configuração do n8n

### **Variáveis de Ambiente**
```env
ACTIVE_API_KEY=your_active_api_key
RUNNING_IN_USA_API_KEY=your_running_in_usa_key
RACERAVES_API_KEY=your_racereaves_key
DEFAULT_IMAGE_URL=https://your-app.com/default-race-image.jpg
```

### **Webhook URL**
```
https://your-n8n-instance.com/webhook/race-search
```

### **Headers Necessários**
```
Content-Type: application/json
Authorization: Bearer your_webhook_token
```

## 🔧 Funcionalidades Avançadas

### **1. Cache de Resultados**
- **Node**: `Redis` - Cache de Resultados
- **TTL**: 1 hora
- **Chave**: `race_search:${hash(query)}`

### **2. Rate Limiting**
- **Node**: `Function` - Rate Limiting
- **Limite**: 100 requests por hora por IP
- **Ação**: Retornar erro 429 se exceder

### **3. Logs e Monitoramento**
- **Node**: `Function` - Log de Atividades
- **Log**: Query, resultados, tempo de processamento
- **Destino**: Elasticsearch ou banco de dados

### **4. Fallback para APIs**
- **Node**: `Error Trigger`
- **Ação**: Tentar APIs alternativas se principal falhar
- **Timeout**: 5 segundos por API

## 📊 Métricas e Analytics

### **KPIs Monitorados**
- Taxa de sucesso das buscas
- Tempo médio de resposta
- APIs mais utilizadas
- Queries mais populares
- Taxa de conversão (sugestões aceitas)

### **Alertas Configurados**
- Taxa de erro > 10%
- Tempo de resposta > 5s
- APIs indisponíveis
- Rate limit atingido

## 🚀 Deploy e Manutenção

### **Deploy**
1. Exportar workflow do n8n
2. Configurar variáveis de ambiente
3. Testar webhook
4. Monitorar logs

### **Manutenção**
- Atualizar APIs conforme necessário
- Ajustar algoritmo de confiança
- Adicionar novas fontes de dados
- Otimizar performance

## 🔒 Segurança

### **Autenticação**
- Webhook token obrigatório
- Rate limiting por IP
- Validação de entrada
- Sanitização de dados

### **Privacidade**
- Não armazenar dados pessoais
- Logs anônimos
- Cache temporário apenas
- Conformidade com LGPD

---

## 📝 Exemplo de Uso

### **Request**
```bash
curl -X POST https://your-n8n-instance.com/webhook/race-search \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_token" \
  -d '{
    "query": "Maratona de São Paulo",
    "timestamp": "2024-01-15T10:30:00Z"
  }'
```

### **Response**
```json
{
  "success": true,
  "query": "Maratona de São Paulo",
  "suggestions": [
    {
      "name": "Maratona Internacional de São Paulo",
      "location": "São Paulo, SP",
      "distance": "42.195 km",
      "month": "June",
      "year": "2024",
      "confidence": 0.92
    }
  ]
}
```

Este fluxo garante que os usuários sempre tenham sugestões relevantes de corridas, mesmo quando não encontram resultados na busca local! 🏃‍♂️
